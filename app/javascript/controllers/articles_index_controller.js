import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "loading", "error"]

  async connect() {
    await this.fetchArticles()
  }

  async fetchArticles() {
    this.loadingTarget.hidden = false
    this.errorTarget.hidden   = true

    const query = `
      query {
        articles {
          id
          title
          body
          status
          createdAt
          user { name email }
          tags { id name }
        }
      }
    `

    try {
      const res = await fetch("/graphql", {
        method:  "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ query })
      })

      const json = await res.json()

      if (json.errors?.length) {
        throw new Error(json.errors[0].message)
      }

      this.render(json.data.articles)
    } catch (err) {
      this.errorTarget.hidden      = false
      this.errorTarget.textContent = `読み込みに失敗しました: ${err.message}`
    } finally {
      this.loadingTarget.hidden = true
    }
  }

  render(articles) {
    if (!articles.length) {
      this.listTarget.innerHTML = `
        <p class="text-sm text-gray-400 text-center py-12">記事がありません</p>
      `
      return
    }

    this.listTarget.innerHTML = articles.map(a => this.articleHTML(a)).join("")
  }

  articleHTML(article) {
    const statusLabel = { draft: "下書き", published: "公開済み", archived: "アーカイブ" }
    const statusClass = {
      draft:     "bg-gray-100 text-gray-600",
      published: "bg-green-100 text-green-700",
      archived:  "bg-orange-100 text-orange-700"
    }

    const authorName = article.user.name || article.user.email
    const tags = article.tags.map(t =>
      `<a href="/tags/${t.id}"
          class="inline-flex items-center text-xs px-2 py-0.5 rounded-full font-medium
                 bg-blue-50 text-blue-700 border border-blue-100 hover:bg-blue-100 transition-colors">
         ${this.escape(t.name)}
       </a>`
    ).join("")

    return `
      <div class="bg-white border border-gray-200 rounded-lg p-5 hover:border-gray-300 transition-colors">
        <div class="flex justify-between items-start gap-4">
          <div class="flex-1 min-w-0">
            <h2 class="text-base font-medium text-gray-800 truncate">
              <a href="/articles/${article.id}" class="hover:text-gray-600">
                ${this.escape(article.title)}
              </a>
            </h2>
            <p class="text-sm text-gray-500 mt-1 line-clamp-2">${this.escape(article.body)}</p>
            ${tags ? `<div class="flex flex-wrap gap-1 mt-2">${tags}</div>` : ""}
          </div>
          <div class="flex flex-col items-end gap-1 shrink-0">
            <span class="text-xs px-2 py-0.5 rounded-full font-medium ${statusClass[article.status] || ""}">
              ${statusLabel[article.status] || article.status}
            </span>
            <span class="text-xs text-gray-400">${this.escape(authorName)}</span>
          </div>
        </div>
      </div>
    `
  }

  escape(str) {
    return String(str ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content ?? ""
  }
}
