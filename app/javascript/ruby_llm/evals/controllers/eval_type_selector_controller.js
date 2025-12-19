import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "expectedOutput", "judgeFields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const evalType = this.selectTarget.value

    if (this.hasExpectedOutputTarget) {
      if (evalType === "human") {
        this.expectedOutputTarget.style.display = "none"
        const textarea = this.expectedOutputTarget.querySelector("textarea")
        if (textarea) textarea.value = ""
      } else {
        this.expectedOutputTarget.style.display = ""
      }
    }

    if (this.hasJudgeFieldsTarget) {
      if (evalType === "llm_judge") {
        this.judgeFieldsTarget.style.display = ""
      } else {
        this.judgeFieldsTarget.style.display = "none"
        const providerSelect = this.judgeFieldsTarget.querySelector("select[name*='judge_provider']")
        const modelSelect = this.judgeFieldsTarget.querySelector("select[name*='judge_model']")
        const modelInput = this.judgeFieldsTarget.querySelector("input[type='text']")
        if (providerSelect) providerSelect.value = ""
        if (modelSelect) modelSelect.value = ""
        if (modelInput) modelInput.value = ""
      }
    }
  }
}
