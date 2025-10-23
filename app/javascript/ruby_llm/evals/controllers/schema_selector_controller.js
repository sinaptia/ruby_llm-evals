import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["schemaSelect", "schemaOtherField"]

  connect() {
    this.toggleSchemaOtherField()
  }

  schemaChanged() {
    this.toggleSchemaOtherField()
  }

  toggleSchemaOtherField() {
    if (!this.hasSchemaSelectTarget || !this.hasSchemaOtherFieldTarget) return

    const select = this.schemaSelectTarget
    const selectedOption = select.options[select.selectedIndex]
    const selectedText = selectedOption ? selectedOption.text : ""

    if (selectedText === "Other") {
      this.schemaOtherFieldTarget.classList.remove("is-hidden")
    } else {
      this.schemaOtherFieldTarget.classList.add("is-hidden")
      const textarea = this.schemaOtherFieldTarget.querySelector("textarea")
      if (textarea) {
        textarea.value = ""
      }
    }
  }
}
