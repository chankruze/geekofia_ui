import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Replaces Turbo's window.confirm with this <dialog>. Reads optional
// data-confirm-title / -button / -variant from the submitter or the element.
export default class extends Controller {
  static targets = ["title", "message", "confirm", "cancel"]
  static values = { defaultClass: String, destructiveClass: String }

  connect() {
    this.forms = Turbo.config?.forms
    if (!this.forms) return
    this.previous = this.forms.confirm
    this.forms.confirm = (message, element, submitter) => this.ask(message, element, submitter)
  }

  disconnect() {
    this.finish(false)
    if (this.forms) this.forms.confirm = this.previous
  }

  ask(message, element, submitter) {
    const read = (key) => submitter?.dataset?.[key] || element?.dataset?.[key]
    this.titleTarget.textContent = read("confirmTitle") || "Are you sure?"
    this.messageTarget.textContent = message
    this.confirmTarget.textContent = read("confirmButton") || "Confirm"
    this.style(read("confirmVariant") === "destructive")
    this.finish(false)
    this.element.returnValue = ""
    this.element.showModal()
    this.cancelTarget.focus()
    return new Promise((resolve) => { this.resolve = resolve })
  }

  style(destructive) {
    const words = (value) => value.split(/\s+/).filter(Boolean)
    const [remove, add] = destructive
      ? [this.defaultClassValue, this.destructiveClassValue]
      : [this.destructiveClassValue, this.defaultClassValue]
    this.confirmTarget.classList.remove(...words(remove))
    this.confirmTarget.classList.add(...words(add))
  }

  backdrop(event) {
    if (event.target === this.element) this.element.close("cancel")
  }

  closed() {
    this.finish(this.element.returnValue === "confirm")
  }

  finish(result) {
    const resolve = this.resolve
    this.resolve = null
    resolve?.(result)
  }
}
