import { Controller } from "@hotwired/stimulus"

// Menu button: opens a role=menu popover, roves focus with arrows, closes on
// Escape (returning focus), Tab, an outside click or an item activation.
export default class extends Controller {
  static targets = ["trigger", "menu"]

  connect() {
    this.outside = (event) => { if (!this.element.contains(event.target)) this.close() }
  }

  disconnect() {
    this.close()
  }

  get isOpen() {
    return this.hasMenuTarget && !this.menuTarget.hidden
  }

  get items() {
    return Array.from(this.menuTarget.querySelectorAll('[role="menuitem"]:not([disabled])'))
  }

  toggle(event) {
    event?.preventDefault()
    this.isOpen ? this.close() : this.show("first")
  }

  show(focus = "first") {
    this.menuTarget.hidden = false
    this.triggerTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.outside, true)
    const items = this.items
    ;(focus === "last" ? items[items.length - 1] : items[0])?.focus()
  }

  close(options = {}) {
    if (!this.isOpen) return
    const restore = options.restoreFocus === true || this.menuTarget.contains(document.activeElement)
    this.menuTarget.hidden = true
    this.triggerTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.outside, true)
    if (restore) this.triggerTarget.focus()
  }

  select() {
    this.close({ restoreFocus: true })
  }

  triggerKeydown(event) {
    if (["ArrowDown", "Enter", " "].includes(event.key)) {
      event.preventDefault()
      this.show("first")
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.show("last")
    }
  }

  menuKeydown(event) {
    const items = this.items
    const index = items.indexOf(document.activeElement)
    switch (event.key) {
      case "ArrowDown": event.preventDefault(); items[(index + 1) % items.length]?.focus(); break
      case "ArrowUp": event.preventDefault(); items[(index - 1 + items.length) % items.length]?.focus(); break
      case "Home": event.preventDefault(); items[0]?.focus(); break
      case "End": event.preventDefault(); items[items.length - 1]?.focus(); break
      case "Escape": event.preventDefault(); event.stopPropagation(); this.close({ restoreFocus: true }); break
      case "Tab": this.close(); break
    }
  }
}
