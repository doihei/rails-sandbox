---
paths:
  - "app/views/**/*.erb"
---

## Turbo の方針

- **Turbo Drive のみ使用する**（デフォルト有効）
  - リンク遷移を自動で fetch に置き換え、フルリロードなしで画面を更新する
- **Turbo Frame は使わない**
  - フレーム外の notice・`<title>`・ナビと整合を取るのが難しく、レイアウトバグの原因になるため
- 非 GET リクエスト（PATCH / DELETE）は `link_to method:` ではなく `button_to` を使う
  - Turbo は `<a>` の `method:` を正しくハンドルしないため
