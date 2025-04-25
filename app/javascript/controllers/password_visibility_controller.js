import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ["input", "toggleIconShow", "toggleIconHide"];

  toggle() {
    const isPassword = this.inputTarget.type === 'password';
    this.inputTarget.type = isPassword ? 'text' : 'password';

    if (this.hasToggleIconShowTarget && this.hasToggleIconHideTarget) {
      this.toggleIconShowTarget.classList.toggle('hidden', isPassword);
      this.toggleIconHideTarget.classList.toggle('hidden', !isPassword);
    }
  }
}
