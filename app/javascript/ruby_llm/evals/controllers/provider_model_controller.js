import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["provider", "modelSelect", "modelSelectWrapper", "modelInput"]
  static values = {
    modelsByProvider: Object
  }

  connect() {
    this.updateModelField()
  }

  "provider-changed"() {
    this.updateModelField()
  }

  updateModelField() {
    const selectedProvider = this.providerTarget.value

    if (!selectedProvider) {
      this.showModelInput()
      this.modelInputTarget.value = ""
      return
    }

    const models = this.modelsByProviderValue[selectedProvider]

    if (!models || models.length === 0) {
      this.showModelInput()
    } else {
      this.showModelSelect(models)
    }
  }

  showModelInput() {
    if (!this.hasModelSelectWrapperTarget || !this.hasModelInputTarget) return

    this.modelSelectWrapperTarget.classList.add("is-hidden")
    this.modelInputTarget.classList.remove("is-hidden")

    if (this.hasModelSelectTarget) {
      this.modelSelectTarget.disabled = true
    }
    this.modelInputTarget.disabled = false
  }

  showModelSelect(models) {
    if (!this.hasModelSelectTarget || !this.hasModelInputTarget || !this.hasModelSelectWrapperTarget) return

    const currentValue = this.modelInputTarget.value

    // Build options HTML string for better performance
    const optionsHTML = [
      '<option value="">Select a model</option>',
      ...models.map(model => {
        const escaped = this.escapeHtml(model.name)
        return `<option value="${this.escapeHtml(model.id)}">${escaped}</option>`
      })
    ].join('')

    this.modelSelectTarget.innerHTML = optionsHTML

    // Preserve current value if it matches a model in the list
    if (currentValue && models.some(m => m.id === currentValue)) {
      this.modelSelectTarget.value = currentValue
    }

    this.modelInputTarget.classList.add("is-hidden")
    this.modelSelectWrapperTarget.classList.remove("is-hidden")
    this.modelSelectTarget.disabled = false
  }

  syncToInput() {
    if (!this.hasModelSelectTarget || !this.hasModelInputTarget) return

    // When select changes, sync value to input
    this.modelInputTarget.value = this.modelSelectTarget.value
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
