import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "name"]

  connect() {
    this.defaultText = this.nameTarget.textContent.trim() || "No files selected"
  }

  update() {
    const files = this.inputTarget.files || []

    if (files.length === 0) {
      this.nameTarget.textContent = this.defaultText
    } else if (files.length === 1) {
      this.nameTarget.textContent = files[0].name
    } else {
      this.nameTarget.textContent = `${files.length} files selected`
    }
  }
}
