import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease-out"
    this.element.style.opacity = "0"
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

