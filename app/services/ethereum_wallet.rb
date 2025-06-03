# app/services/ethereum_wallet.rb
require "eth"
require "net/http"
require "json"

class EthereumWallet
  # Returns the platform key (from Rails credentials)
  def self.platform_key
    env = Rails.env.production? ? :production : :development
    private_key = Rails.application.credentials.dig(env, :ethereum, :private_key) ||
                  Rails.application.credentials.dig(:ethereum, :private_key) ||
                  ENV["ETHEREUM_PRIVATE_KEY"]
    if private_key.blank?
      Rails.logger.error("[EthereumWallet] No private key configured! Check your credentials or ETHEREUM_PRIVATE_KEY env var.")
      raise "Ethereum private key not configured!"
    end

    # Security: Validate private key format and never log it
    unless private_key.match?(/\A[a-fA-F0-9]{64}\z/)
      Rails.logger.error("[EthereumWallet] Invalid private key format - must be 64 hex characters")
      raise "Invalid Ethereum private key format!"
    end

    Eth::Key.new priv: private_key
  end

  def self.platform_address
    env = Rails.env.production? ? :production : :development
    address = Rails.application.credentials.dig(env, :ethereum, :address) ||
              Rails.application.credentials.dig(:ethereum, :address) ||
              ENV["ETHEREUM_ADDRESS"]
    if address.blank?
      Rails.logger.error("[EthereumWallet] platform_address is nil or blank! Check your credentials or ETHEREUM_ADDRESS env var.")
      raise "Platform Ethereum address not configured!"
    end
    address
  end

  def self.rpc_url
    # Check credentials under environment-specific keys
    env = Rails.env.production? ? :production : :development
    configured_url = Rails.application.credentials.dig(env, :ethereum, :rpc_url) ||
                     Rails.application.credentials.dig(:ethereum, :rpc_url) ||
                     ENV["ETHEREUM_RPC_URL"]
    return configured_url if configured_url.present?

    # Fallback to public endpoints if nothing is set
    url = Rails.env.production? ? "https://ethereum.drpc.org" : "https://sepolia.drpc.org"
    Rails.logger.info("[EthereumWallet] Using fallback RPC URL: #{url}")
    url
  end

  def self.chain_id
    if Rails.env.production?
      1 # Ethereum Mainnet
    else
      11155111 # Sepolia Testnet
    end
  end

  # Get ETH balance (in Ether)
  def self.balance(address = nil)
    address ||= platform_address
    data = {
      jsonrpc: "2.0",
      method: "eth_getBalance",
      params: [ address, "latest" ],
      id: 1
    }
    resp = post_rpc(data)
    return 0 unless resp && resp["result"]
    (resp["result"].to_i(16) / 1e18).to_f
  end

  # Send ETH from platform to recipient_address
  def self.send_eth(to, amount)
    key = platform_key
    from = platform_address
    Rails.logger.info("[EthereumWallet] Initiating payout: to=#{to}, amount=#{amount}")
    Rails.logger.info("[EthereumWallet] Using from address: #{from}")

    # Check balance first
    begin
      bal = self.balance(from)
      Rails.logger.info("[EthereumWallet] Balance for #{from}: #{bal} ETH")

      # Verify we have enough funds
      wei_amount = (amount.to_f * 10**18).to_i
      estimated_gas = 21000 # Standard ETH transfer gas
      estimated_gas_price = 5_000_000_000 # 5 gwei fallback

      # Get fee data for better gas price estimate
      begin
        fee_data = get_fee_data
        estimated_gas_price = fee_data[:max_fee_per_gas].to_i
      rescue => e
        Rails.logger.warn("[EthereumWallet] Error getting fee data, using fallback: #{e.message}")
      end

      estimated_cost_wei = wei_amount + (estimated_gas * estimated_gas_price)
      bal_wei = (bal * 10**18).to_i

      if bal_wei < estimated_cost_wei
        error_msg = "Insufficient funds: have #{bal} ETH, need ~#{estimated_cost_wei.to_f / 10**18} ETH"
        Rails.logger.error("[EthereumWallet] #{error_msg}")
        raise error_msg
      end
    rescue => e
      Rails.logger.error("[EthereumWallet] Error checking balance for #{from}: #{e}")
      # Continue anyway, the RPC call will fail if there are insufficient funds
    end

    nonce = get_nonce(from)
    Rails.logger.info("[EthereumWallet] Nonce for #{from}: #{nonce}")
    gas_limit = 21000
    value = (amount.to_f * 10**18).to_i # Integer, not hex string!
    Rails.logger.info("[EthereumWallet] Value (wei): #{value}")

    # Get gas price (use legacy pricing with validation)
    gas_price = 5_000_000_000 # 5 gwei default
    begin
      fee_data = get_fee_data
      proposed_gas_price = fee_data[:max_fee_per_gas].to_i

      # Validate gas price is reasonable (between 1 gwei and 100 gwei)
      min_gas_price = 1_000_000_000  # 1 gwei
      max_gas_price = 100_000_000_000 # 100 gwei

      if proposed_gas_price >= min_gas_price && proposed_gas_price <= max_gas_price
        gas_price = proposed_gas_price
        Rails.logger.info("[EthereumWallet] Using network gas price: #{gas_price} wei (#{gas_price.to_f / 10**9} gwei)")
      else
        Rails.logger.warn("[EthereumWallet] Network gas price #{proposed_gas_price} wei is outside safe range (#{min_gas_price}-#{max_gas_price}), using default")
      end
    rescue => e
      Rails.logger.warn("[EthereumWallet] Error getting fee data, using default gas price: #{e.message}")
    end

    # Create a legacy transaction
    tx_params = {
      data: "",
      gas_limit: gas_limit,
      gas_price: gas_price,
      nonce: nonce,
      to: to,
      value: value,
      chain_id: chain_id
    }

    Rails.logger.info("[EthereumWallet] Params for Eth::Tx.new: gas_limit=#{tx_params[:gas_limit]}, gas_price=#{tx_params[:gas_price]}, nonce=#{tx_params[:nonce]}, chain_id=#{tx_params[:chain_id]}")

    begin
      tx = Eth::Tx.new(tx_params)
      tx.sign key
      raw_tx = Eth::Util.bin_to_hex tx.encoded
      Rails.logger.info("[EthereumWallet] Transaction signed and ready for broadcast (hash redacted for security)")

      data = {
        jsonrpc: "2.0",
        method: "eth_sendRawTransaction",
        params: [ "0x#{raw_tx}" ],
        id: 1
      }
      resp = post_rpc(data)
      Rails.logger.info("[EthereumWallet] RPC Response: #{resp}")

      if resp["error"]
        Rails.logger.error("[EthereumWallet] Error sending transaction: #{resp['error']}")

        # Try to provide more helpful error messages
        if resp["error"]["message"].include?("insufficient funds")
          error_details = "Transaction requires #{(gas_limit * gas_price + value).to_f / 10**18} ETH but account only has #{bal} ETH"
          Rails.logger.error("[EthereumWallet] #{error_details}")
          raise "Ethereum payout failed: Insufficient funds. #{error_details}"
        else
          raise "Ethereum payout failed: #{resp}"
        end
      end

      resp["result"]
    rescue => e
      Rails.logger.error("[EthereumWallet] Exception during transaction: #{e.message}")
      raise e
    end
  end

  def self.get_nonce(address)
    data = {
      jsonrpc: "2.0",
      method: "eth_getTransactionCount",
      params: [ address, "pending" ],
      id: 1
    }
    resp = post_rpc(data)
    resp["result"].to_i(16)
  end

  # Fetch EIP-1559 fee data from the network
  def self.get_fee_data
    # Fetch base fee and priority fee from the network
    base_fee = nil
    priority_fee = 1_000_000_000 # 1 gwei default
    begin
      # eth_feeHistory is the best source for recent base fee
      data = {
        jsonrpc: "2.0",
        method: "eth_feeHistory",
        params: [ "0x1", "latest", [] ],
        id: 1
      }
      resp = post_rpc(data)
      if resp && resp["result"] && resp["result"]["baseFeePerGas"]
        base_fee = resp["result"]["baseFeePerGas"].last.to_i(16)
      end
    rescue => e
      Rails.logger.error("[EthereumWallet] Error fetching base fee: #{e}")
    end
    # Try eth_maxPriorityFeePerGas for priority fee
    begin
      data = {
        jsonrpc: "2.0",
        method: "eth_maxPriorityFeePerGas",
        params: [],
        id: 1
      }
      resp = post_rpc(data)
      if resp && resp["result"]
        priority_fee = resp["result"].to_i(16)
      end
    rescue => e
      Rails.logger.error("[EthereumWallet] Error fetching priority fee: #{e}")
    end
    # Fallback if base_fee is missing
    base_fee ||= 20_000_000_000 # 20 gwei default
    {
      max_fee_per_gas: base_fee + priority_fee,
      max_priority_fee_per_gas: priority_fee
    }
  end

  # Fetch a transaction by hash (returns details from RPC)
  def self.get_transaction(tx_hash)
    data = {
      jsonrpc: "2.0",
      method: "eth_getTransactionByHash",
      params: [ tx_hash ],
      id: 1
    }
    resp = post_rpc(data)
    tx = resp["result"]
    return nil unless tx
    # Add confirmations (requires eth_blockNumber)
    if tx["blockNumber"]
      block_data = {
        jsonrpc: "2.0",
        method: "eth_blockNumber",
        params: [],
        id: 1
      }
      block_resp = post_rpc(block_data)
      latest_block = block_resp["result"].to_i(16)
      tx_block = tx["blockNumber"].to_i(16)
      tx["confirmations"] = latest_block - tx_block
    else
      tx["confirmations"] = 0
    end
    tx
  end

  def self.post_rpc(data)
    # Security: Never log request data as it may contain sensitive information
    Rails.logger.info("[EthereumWallet] Making RPC request to: #{rpc_url}")
    uri = URI(rpc_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = data.to_json
    resp = http.request(req)

    # Security: Only log response for non-sensitive methods
    sensitive_methods = [ "eth_sendRawTransaction" ]
    method_name = data[:method] || data["method"]
    if sensitive_methods.include?(method_name)
      Rails.logger.info("[EthereumWallet] RPC Response: [REDACTED - sensitive method]")
    else
      Rails.logger.info("[EthereumWallet] RPC Response: #{resp.body}")
    end

    JSON.parse(resp.body)
  rescue => e
    Rails.logger.error("[EthereumWallet] Ethereum RPC error: #{e.message}")
    nil
  end
end
