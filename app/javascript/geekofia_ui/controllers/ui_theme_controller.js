import { Controller } from "@hotwired/stimulus"

const ORDER = ["light", "dark", "system"]

// Cycles light → dark → system. The pre-paint script from ui_head_tags owns
// applying the class; this controller stores the choice and re-applies it.
export default class extends Controller {
  connect() {
    this.render()
  }

  cycle(event) {
    event?.preventDefault()
    const next = ORDER[(ORDER.indexOf(this.current) + 1) % ORDER.length]
    this.choice = next
    try { localStorage.setItem(this.key, next) } catch {}
    this.apply(next)
    this.render()
  }

  apply(choice) {
    const api = window.GeekofiaUI
    if (typeof api?.applyTheme === "function") {
      api.applyTheme(choice)
    } else {
      const dark = choice === "dark" || (choice === "system" && matchMedia("(prefers-color-scheme: dark)").matches)
      document.documentElement.classList.toggle("dark", dark)
    }
  }

  get key() {
    return window.GeekofiaUI?.storageKey || "geekofia-ui-theme"
  }

  get current() {
    try {
      return localStorage.getItem(this.key) || this.choice || "system"
    } catch {
      return this.choice || "system"
    }
  }

  render() {
    const current = this.current
    this.element.dataset.theme = current
    this.element.title = `Theme: ${current}`
    this.element.setAttribute("aria-label", `Theme: ${current}`)
  }
}
