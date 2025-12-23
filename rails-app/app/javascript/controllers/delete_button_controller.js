import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    method: String
  }

  openModal(event) {
    event.preventDefault()
    
    const modal = document.querySelector('[data-controller="modal"]')
    if (modal) {
      const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
      if (modalController) {
        modalController.deleteUrl = this.urlValue
        modalController.deleteMethod = this.methodValue || "delete"
        modalController.open(event)
      }
    }
  }
}

