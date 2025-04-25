import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { collapsed: Boolean, maxHeight: Number }

  connect() {
    this.update()
  }

  toggle() {
    this.collapsedValue = !this.collapsedValue
    this.update()
  }

  update() {
    if (this.collapsedValue) {
      this.element.style.maxHeight = this.maxHeightValue + "px"
      this.element.style.overflow = "hidden"
      this.element.classList.add("expandable-collapsed")
    } else {
      this.element.style.maxHeight = null
      this.element.style.overflow = null
      this.element.classList.remove("expandable-collapsed")
    }
    if (this.toggleButton()) {
      this.toggleButton().textContent = this.collapsedValue ? "Expand" : "Collapse"
    }
  }

  toggleButton() {
    return this.element.querySelector(".expand-toggle")
  }
}
