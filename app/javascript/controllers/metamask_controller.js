import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="metamask"
export default class extends Controller {
  static targets = ["button", "address", "disconnect"]

  connect() {
    console.log("Metamask Stimulus controller connected!");
    // On load, check localStorage and update UI
    const savedAddr = window.localStorage.getItem('wallet_address');
    this.showAddress(savedAddr);
    if (window.ethereum) {
      // Listen for account changes
      window.ethereum.on('accountsChanged', (accounts) => {
        this.handleAccountsChanged(accounts);
      });
    }
    // Also update the input field if a saved address exists
    const input = document.getElementById('user_wallet_address') || document.getElementById('wallet_address');
    if (savedAddr && input) {
      input.value = savedAddr;
    }
  }

  async connectMetaMask() {
    if (window.ethereum) {
      try {
        // Always prompt the account picker
        await window.ethereum.request({
          method: 'wallet_requestPermissions',
          params: [{ eth_accounts: {} }]
        });
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const addr = accounts[0];
        window.localStorage.setItem('wallet_address', addr);
        // Update the input field
        const input = document.getElementById('user_wallet_address') || document.getElementById('wallet_address');
        if (input) input.value = addr;
        this.showAddress(addr);
      } catch (err) {
        alert('MetaMask connection failed: ' + err.message);
      }
    } else {
      alert('MetaMask is not installed. Please install MetaMask to continue.');
    }
  }

  disconnectMetaMask() {
    window.localStorage.removeItem('wallet_address');
    const input = document.getElementById('user_wallet_address') || document.getElementById('wallet_address');
    if (input) input.value = '';
    this.showAddress('');
    // Reload the page to fully reset MetaMask connection state
    window.location.reload();
  }

  async switchWallet() {
    if (window.ethereum && window.ethereum.request) {
      try {
        await window.ethereum.request({
          method: 'wallet_requestPermissions',
          params: [{ eth_accounts: {} }]
        });
        // After switching, update UI
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        const addr = accounts[0];
        window.localStorage.setItem('wallet_address', addr);
        const input = document.getElementById('user_wallet_address') || document.getElementById('wallet_address');
        if (input) input.value = addr;
        this.showAddress(addr);
      } catch (err) {
        alert('MetaMask switch account failed: ' + err.message);
      }
    } else {
      alert('MetaMask is not installed.');
    }
  }

  showAddress(addr) {
    const input = document.getElementById('user_wallet_address') || document.getElementById('wallet_address');
    if (addr) {
      this.addressTarget.textContent = `${addr.slice(0, 6)}...${addr.slice(-4)}`;
      this.buttonTarget.classList.add('hidden');
      if (this.hasDisconnectTarget) this.disconnectTarget.classList.remove('hidden');
      if (input) input.value = addr;
    } else {
      this.addressTarget.textContent = '';
      this.buttonTarget.classList.remove('hidden');
      if (this.hasDisconnectTarget) this.disconnectTarget.classList.add('hidden');
      if (input) input.value = '';
    }
  }

  handleAccountsChanged(accounts) {
    const addr = accounts[0] || '';
    if (addr) {
      window.localStorage.setItem('wallet_address', addr);
    } else {
      window.localStorage.removeItem('wallet_address');
    }
    this.showAddress(addr);
  }
}
