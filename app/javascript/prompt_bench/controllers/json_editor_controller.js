import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "editor", "error"]
  static values = {
    height: { type: String, default: "200px" }
  }

  async connect() {
    await this.initializeEditor()
    this.setupThemeListener()
  }

  disconnect() {
    if (this.editor) {
      this.editor.session.off("change", this.syncToTextarea)
      this.editor.session.off("changeAnnotation", this.validateJSON)
      this.editor.destroy()
      this.editor = null
    }

    if (this.mediaQueryList) {
      this.mediaQueryList.removeEventListener('change', this.handleThemeChange)
    }
  }

  setupThemeListener() {
    this.mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)')
    this.mediaQueryList.addEventListener('change', this.handleThemeChange)
  }

  handleThemeChange = async (e) => {
    if (this.editor) {
      const theme = e.matches ? 'github_dark' : 'github'
      if (theme === 'github_dark') {
        await import("ace-theme-github-dark")
      } else {
        await import("ace-theme-github")
      }
      this.editor.setTheme(`ace/theme/${theme}`)
    }
  }

  getCurrentTheme() {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    return prefersDark ? 'github_dark' : 'github'
  }

  async initializeEditor() {
    if (typeof window.ace === 'undefined') {
      await import("ace-builds")
    }

    await import("ace-mode-json")
    const theme = this.getCurrentTheme()
    if (theme === 'github_dark') {
      await import("ace-theme-github-dark")
    } else {
      await import("ace-theme-github")
    }

    const ace = window.ace
    ace.config.set("workerPath", "https://cdn.jsdelivr.net/npm/ace-builds@1.35.5/src-min-noconflict/")

    this.textareaTarget.classList.add("is-hidden")
    this.editorTarget.style.height = this.heightValue

    this.editor = ace.edit(this.editorTarget)
    this.editor.setTheme(`ace/theme/${this.getCurrentTheme()}`)
    this.editor.session.setMode("ace/mode/json")
    this.editor.setOptions({
      fontSize: "14px",
      showPrintMargin: false,
      highlightActiveLine: true,
      enableBasicAutocompletion: true,
      enableLiveAutocompletion: false,
      tabSize: 2,
      useSoftTabs: true
    })

    this.loadInitialValue()
    this.editor.session.on("change", this.syncToTextarea)
    this.editor.session.on("changeAnnotation", this.validateJSON)
  }

  loadInitialValue() {
    const value = this.textareaTarget.value.trim()

    if (value) {
      try {
        const parsed = JSON.parse(value)
        const formatted = JSON.stringify(parsed, null, 2)
        this.editor.setValue(formatted, -1)
      } catch (e) {
        this.editor.setValue(value, -1)
      }
    } else {
      this.editor.setValue("", -1)
    }
  }

  syncToTextarea = () => {
    const content = this.editor.getValue().trim()

    if (content && content !== "{}") {
      this.textareaTarget.value = content
    } else {
      this.textareaTarget.value = ""
    }
  }

  validateJSON = () => {
    const annotations = this.editor.session.getAnnotations()
    const errors = annotations.filter(a => a.type === "error")

    if (this.hasErrorTarget) {
      if (errors.length > 0) {
        const errorMessages = errors.map(e => `Line ${e.row + 1}: ${e.text}`).join(", ")
        this.errorTarget.textContent = errorMessages
        this.errorTarget.classList.remove("is-hidden")
        this.editorTarget.classList.add("is-danger")
      } else {
        this.errorTarget.textContent = ""
        this.errorTarget.classList.add("is-hidden")
        this.editorTarget.classList.remove("is-danger")
      }
    }
  }
}
