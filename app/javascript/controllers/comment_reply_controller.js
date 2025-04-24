import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  show(event) {
    event.preventDefault();
    const commentId = event.currentTarget.dataset.commentId;
    const form = document.getElementById(`reply_form_${commentId}`);
    if (form) {
      form.style.display = form.style.display === "none" ? "block" : "none";
    }
  }
}
