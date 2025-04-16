# Placeholder model for Popper's platform wallet logic
# In production, this should be backed by a database table and proper accounting
class PopperWallet
  # Simulate a platform wallet balance (for demo only)
  @balances = Hash.new(0)

  class << self
    # Add funds to the platform wallet in given currency
    def add_funds(amount_cents, currency)
      @balances[currency] += amount_cents
    end

    # Release funds from platform wallet to a recipient (user)
    def release_funds(recipient, amount_cents, currency)
      if @balances[currency] >= amount_cents
        @balances[currency] -= amount_cents
        # In real implementation, credit recipient's wallet here
        true
      else
        false
      end
    end

    # For debugging/testing: get current balance
    def balance(currency)
      @balances[currency]
    end
  end
end
