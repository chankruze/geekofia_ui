import { Controller } from "@hotwired/stimulus"

// Copies textValue, or the textContent of the element matched by sourceValue,
// then sets data-copied="true" on the button for a moment.
export default class extends Controller {
  static values = { text: String, source: String, duration: { type: Number, default: 2000 } }

  async copy(event) {
    event.preventDefault()
    const text = this.sourceValue ? (document.querySelector(this.sourceValue)?.textContent ?? "") : this.textValue
    try {
      await navigator.clipboard.writeText(text)
    } catch {
      this.fallback(text)
    }
    this.element.dataset.copied = "true"
    clearTimeout(this.timer)
    this.timer = setTimeout(() => { delete this.element.dataset.copied }, this.durationValue)
  }

  fallback(text) {
    const area = document.createElement("textarea")
    area.value = text
    area.setAttribute("readonly", "")
    area.style.position = "fixed"
    area.style.opacity = "0"
    document.body.appendChild(area)
    area.select()
    document.execCommand("copy")
    area.remove()
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
