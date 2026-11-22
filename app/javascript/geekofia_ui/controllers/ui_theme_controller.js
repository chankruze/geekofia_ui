import { Controller } from "@hotwired/stimulus"

const ORDER = ["light", "dark", "system"]

// Cycles light → dark → system. The pre-paint script from ui_head_tags owns
// applying the class; this controller only stores the choice and re-applies.
export default class extends Controller {
  connect() {
    this.render()
  }

  cycle(event) {
    event.preventDefault()
    const next = ORDER[(ORDER.indexOf(this.current) + 1) % ORDER.length]
    try { localStorage.setItem(this.key, next) } catch {}
    window.GeekofiaUI?.applyTheme()
    this.render()
  }

  get key() {
    return window.GeekofiaUI?.storageKey || "geekofia-ui-theme"
  }

  get current() {
    try { return localStorage.getItem(this.key) || "system" } catch { return "system" }
  }

  render() {
    this.element.dataset.theme = this.current
    this.element.title = `Theme: ${this.current}`
  }
}
