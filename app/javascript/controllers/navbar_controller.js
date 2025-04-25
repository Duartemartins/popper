import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static classes = ["hidden"];

  toggle(event) {
    console.log("[NAVBAR] toggle");
    this.menuTarget.classList.toggle(this.hiddenClass);
  }
}
