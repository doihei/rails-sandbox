import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.update()
  }

  update() {
    this.countTarget.textContent = this.inputTarget.value.length
  }
}