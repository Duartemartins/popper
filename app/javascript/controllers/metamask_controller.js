import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="metamask"
export default class extends Controller {
  static targets = ["button", "address"]

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
  }

  async connectMetaMask() {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const addr = accounts[0];
        window.localStorage.setItem('wallet_address', addr);
        this.showAddress(addr);
      } catch (err) {
        alert('MetaMask connection failed: ' + err.message);
      }
    } else {
      alert('MetaMask is not installed. Please install MetaMask to continue.');
    }
  }

  showAddress(addr) {
    if (addr) {
      this.addressTarget.textContent = `${addr.slice(0, 6)}...${addr.slice(-4)}`;
      this.buttonTarget.classList.add('hidden');
    } else {
      this.addressTarget.textContent = '';
      this.buttonTarget.classList.remove('hidden');
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
