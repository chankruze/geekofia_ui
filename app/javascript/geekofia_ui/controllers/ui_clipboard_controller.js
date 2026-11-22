import { Controller } from "@hotwired/stimulus"

// Copies textValue, or the value/textContent of the element matched by
// sourceValue. Sets data-copied="true" on success or data-copy-failed="true"
// on failure for a moment, and announces the result for screen readers.
export default class extends Controller {
  static values = { text: String, source: String, duration: { type: Number, default: 2000 } }
  static targets = ["status"]

  async copy(event) {
    event?.preventDefault()
    let ok = false
    try {
      const text = this.resolveText()
      if (!text) throw new Error("Nothing to copy")
      try {
        await navigator.clipboard.writeText(text)
        ok = true
      } catch {
        ok = this.fallback(text)
      }
    } catch {
      ok = false
    }
    if (!this.element.isConnected) return
    this.announce(ok)
  }

  resolveText() {
    if (!this.sourceValue) return this.textValue
    const el = document.querySelector(this.sourceValue)
    if (!el) throw new Error(`No element matches ${this.sourceValue}`)
    const field = el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement || el instanceof HTMLSelectElement
    return field ? el.value : el.textContent
  }

  announce(ok) {
    const attr = ok ? "copied" : "copyFailed"
    const label = ok ? "Copied" : "Copy failed"
    this.clear()
    this.element.dataset[attr] = "true"
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
      this.statusTimer = setTimeout(() => { this.statusTarget.textContent = label }, 50)
    } else {
      this.previousLabel = this.element.getAttribute("aria-label")
      this.element.setAttribute("aria-label", label)
    }
    this.timer = setTimeout(() => this.clear(), this.durationValue)
  }

  clear() {
    clearTimeout(this.timer)
    clearTimeout(this.statusTimer)
    delete this.element.dataset.copied
    delete this.element.dataset.copyFailed
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
    } else if (this.previousLabel !== undefined) {
      if (this.previousLabel === null) this.element.removeAttribute("aria-label")
      else this.element.setAttribute("aria-label", this.previousLabel)
      this.previousLabel = undefined
    }
  }

  fallback(text) {
    const previous = document.activeElement
    const area = document.createElement("textarea")
    area.value = text
    area.setAttribute("readonly", "")
    area.style.position = "fixed"
    area.style.top = "0"
    area.style.left = "0"
    area.style.opacity = "0"
    ;(this.element.closest("dialog") || document.body).appendChild(area)
    area.select()
    let ok = false
    try { ok = document.execCommand("copy") } catch { ok = false }
    area.remove()
    previous?.focus?.({ preventScroll: true })
    return ok
  }

  disconnect() {
    this.clear()
  }
}
