import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "chips"]

  connect() {
    // 初期値（編集時）を chip として描画する
    const initial = this.hiddenTarget.value
    if (initial) {
      initial.split(",").map(t => t.trim()).filter(Boolean).forEach(name => this.addChip(name))
    }
  }

  keydown(event) {
    if (["Enter", ",", " "].includes(event.key)) {
      event.preventDefault()
      this.confirm()
    }
    if (event.key === "Backspace" && this.inputTarget.value === "") {
      this.removeLast()
    }
  }

  blur() {
    this.confirm()
  }

  confirm() {
    const value = this.inputTarget.value.trim().toLowerCase().replace(/,/g, "")
    if (value) {
      this.addChip(value)
      this.inputTarget.value = ""
    }
  }

  removeChip(event) {
    const chip = event.currentTarget.closest("[data-tag]")
    const name = chip.dataset.tag
    chip.remove()
    this.syncHidden()
  }

  addChip(name) {
    // 重複チェック
    const existing = [...this.chipsTarget.querySelectorAll("[data-tag]")]
      .map(el => el.dataset.tag)
    if (existing.includes(name)) return

    const chip = document.createElement("span")
    chip.dataset.tag = name
    chip.className = "inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-medium bg-blue-50 text-blue-700 border border-blue-100"
    chip.innerHTML = `
      <span>${name}</span>
      <button type="button" data-action="click->tag-input#removeChip"
              class="text-blue-400 hover:text-blue-700 leading-none">×</button>
    `
    this.chipsTarget.appendChild(chip)
    this.syncHidden()
  }

  removeLast() {
    const chips = this.chipsTarget.querySelectorAll("[data-tag]")
    if (chips.length > 0) {
      chips[chips.length - 1].remove()
      this.syncHidden()
    }
  }

  syncHidden() {
    const names = [...this.chipsTarget.querySelectorAll("[data-tag]")]
      .map(el => el.dataset.tag)
    this.hiddenTarget.value = names.join(", ")
  }
}
