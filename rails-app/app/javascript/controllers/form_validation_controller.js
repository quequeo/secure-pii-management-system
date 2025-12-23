import { Controller } from "@hotwired/stimulus"

// Provides real-time form validation feedback
export default class extends Controller {
  static targets = ["field", "error"]
  
  connect() {
    console.log("Form validation controller connected")
  }

  validate(event) {
    const field = event.target
    const errorElement = this.findErrorElement(field)
    
    if (!field.checkValidity()) {
      this.showError(field, errorElement)
    } else {
      this.hideError(field, errorElement)
    }
  }

  findErrorElement(field) {
    return field.parentElement.querySelector('.error-message')
  }

  showError(field, errorElement) {
    field.classList.add('border-red-500')
    field.classList.remove('border-gray-300')
    
    if (errorElement) {
      errorElement.classList.remove('hidden')
    }
  }

  hideError(field, errorElement) {
    field.classList.remove('border-red-500')
    field.classList.add('border-gray-300')
    
    if (errorElement) {
      errorElement.classList.add('hidden')
    }
  }
}

