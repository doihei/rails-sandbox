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

## Stimulus の使い方

インタラクティブな UI は Turbo Frame ではなく Stimulus コントローラで実装する。

- ファイル配置: `app/javascript/controllers/<name>_controller.js`
- ファイル名はスネークケース、HTML の `data-controller` はケバブケース（例: `tag-input`）
- `targets` で DOM 要素を宣言し、`connect()` で初期化処理を行う

既存コントローラ:

| コントローラ | 用途 |
|---|---|
| `flash` | フラッシュメッセージの自動消去 |
| `character-count` | 文字数カウント表示 |
| `tag-input` | タグ入力チップ UI |
