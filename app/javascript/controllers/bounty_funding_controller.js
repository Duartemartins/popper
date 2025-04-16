import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bounty-funding"
export default class extends Controller {
  static targets = ["button", "amount"]

  connect() {
    this.pollAttempts = 0;
    this.maxAttempts = 20; // ~100 seconds
    this.pollInterval = 5000;
    this.initialDelay = 8000;
  }

  async fundBounty() {
    if (!window.ethereum) {
      alert('MetaMask is not installed.');
      return;
    }
    const amount = this.amountTarget.value;
    if (!amount || parseFloat(amount) <= 0) {
      alert('Enter a valid ETH amount.');
      return;
    }
    const platformWallet = this.data.get("platformWallet");
    const endpoint = this.data.get("endpoint");
    const ethAmount = (parseFloat(amount) * 1e18).toString(16);
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const tx = await window.ethereum.request({
        method: 'eth_sendTransaction',
        params: [{
          from: accounts[0],
          to: platformWallet,
          value: '0x' + ethAmount,
        }],
      });
      this.buttonTarget.disabled = true;
      this.buttonTarget.textContent = 'Waiting for confirmation...';
      setTimeout(() => this.pollForConfirmation(tx, amount, endpoint), this.initialDelay);
    } catch (err) {
      alert('MetaMask transaction failed: ' + err.message);
    }
  }

  pollForConfirmation(tx, amount, endpoint) {
    fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
      body: JSON.stringify({ tx_hash: tx, amount: amount })
    }).then(resp => resp.json()).then(data => {
      if (data.success) {
        alert('Bounty funded!');
        window.location.reload();
      } else if (!data.success && this.pollAttempts < this.maxAttempts) { 
        this.pollAttempts++;
        setTimeout(() => this.pollForConfirmation(tx, amount, endpoint), this.pollInterval);
      } else {
        this.buttonTarget.disabled = false;
        this.buttonTarget.textContent = 'Fund with MetaMask';
        alert('Error: ' + (data.error || 'Could not verify transaction.'));
      }
    }).catch(() => {
      this.buttonTarget.disabled = false;
      this.buttonTarget.textContent = 'Fund with MetaMask';
      alert('Network error. Please try again.');
    });
  }
}
