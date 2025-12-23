import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "panel"]

  connect() {
    this.element.classList.add("hidden")
  }

  open(event) {
    if (event) event.preventDefault()
    
    this.element.classList.remove("hidden")
    
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("opacity-0", "scale-95")
      this.panelTarget.classList.add("opacity-100", "scale-100")
    })
  }

  close(event) {
    if (event) event.preventDefault()
    
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("opacity-100", "scale-100")
    this.panelTarget.classList.add("opacity-0", "scale-95")
    
    setTimeout(() => {
      this.element.classList.add("hidden")
    }, 200)
  }

  confirm(event) {
    event.preventDefault()
    
    if (this.deleteUrl) {
      const form = document.createElement("form")
      form.method = "POST"
      form.action = this.deleteUrl
      
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
      
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = this.deleteMethod
      form.appendChild(methodInput)

      form.setAttribute("data-turbo-frame", "_top")
      
      document.body.appendChild(form)
      form.submit()
    }
    
    this.close(event)
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close(event)
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }
}

