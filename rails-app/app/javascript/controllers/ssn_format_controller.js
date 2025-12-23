import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  format(event) {
    let value = event.target.value.replace(/\D/g, '')
    
    if (value.length > 9) {
      value = value.slice(0, 9)
    }
    
    let formatted = value
    if (value.length >= 4) {
      formatted = value.slice(0, 3) + '-' + value.slice(3)
    }
    if (value.length >= 6) {
      formatted = value.slice(0, 3) + '-' + value.slice(3, 5) + '-' + value.slice(5)
    }
    
    event.target.value = formatted
  }
}

