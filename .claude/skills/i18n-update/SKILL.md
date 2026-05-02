---
name: i18n-update
description: View・ControllerへのI18n対応を支援するスキル。新しい文言を追加したとき、ja.yml と en.yml（Devise関連は devise.ja.yml / devise.en.yml）に漏れなくキーを追加する。ハードコード文字列の検出・t()未定義キーの検出・キー名の提案・ロケールファイルへの書き込みまでを一括でおこなう。「i18nを更新して」「ロケールに追加して」「翻訳キーが足りない」「ja.ymlに追加して」「en.ymlが抜けてる」「文言をi18n化して」などのフレーズ、またはView・Controllerに文言を追加した直後に使うこと。
---

## i18n ロケールファイル更新スキル

このプロジェクトの i18n 規約（`.claude/rules/i18n.md`）に従い、ロケールファイルを漏れなく更新する。

### ロケールファイルの全体構成

```
config/locales/
  ja.yml          # 日本語（正典）← ユーザーが主に管理
  en.yml          # 英語（フォールバック）← 欠損キーを自動補完
  devise.ja.yml   # Devise メッセージ（日本語）
  devise.en.yml   # Devise メッセージ（英語フォールバック）
```

---

## Step 1: スコープの確認

スキル起動時にユーザーへ確認する：

```
対象ファイルをどう指定しますか？
  A) git diff の変更ファイルを自動検出（デフォルト）
  B) ファイルを個別に指定する
```

**A の場合**: `git diff HEAD` で変更ファイルを取得し、`app/views/` 配下の `.erb` と `app/controllers/` 配下の `.rb` に絞り込む。
**B の場合**: ユーザーからファイルパスを受け取る。

---

## Step 2: 対象ファイルのスキャン

対象ファイルを読み込み、以下の2パターンを検出する。

### パターン A: ハードコードされた文字列（i18n 未対応）

`t()` を使わずリテラルで書かれた表示文字列を検出する。

```erb
<%# 検出対象の例 %>
<h1>記事一覧</h1>
<%= link_to "新規作成", ... %>
<%= f.label :title, "タイトル" %>
<%= button_to "削除", ... %>
```

ただし以下は除外する：
- コメント（`<%# ... %>`）
- URL・パス・クラス名などの技術的な文字列
- `data:` 属性の値

### パターン B: ロケールファイルに未定義の `t()` キー

`t('.')` や `t('flash.xxx')` が使われているが、対応するキーが `ja.yml`（または `devise.ja.yml`）に存在しない場合。

現在のロケールファイルを読み込んでキーの有無を確認する。

---

## Step 3: キー名の提案

ファイルパスと `.claude/rules/i18n.md` の規約に基づいてキー名を提案する。

### View のキー命名（Lazy lookup）

ファイルパスからキーの階層を決める：

| ファイルパス | キー階層 |
|---|---|
| `app/views/articles/index.html.erb` | `articles.index.*` |
| `app/views/articles/_form.html.erb` | `articles.form.*` |
| `app/views/articles/show.html.erb` | `articles.show.*` |
| `app/views/layouts/application.html.erb` | 絶対パス（`app_name`, `nav.*`） |
| `app/views/devise/**/*.erb` | → devise.ja.yml の対応キー |

### Controller のキー命名

```ruby
# flash メッセージ → flash.<controller_name>.<action>
redirect_to @article, notice: t("flash.article.created")
```

### Devise の扱い

`app/views/devise/` 配下または devise 関連のコントローラが対象の場合、キーは `devise.ja.yml` / `devise.en.yml` に追加する。`ja.yml` には追加しない。

---

## Step 4: ユーザー確認

検出結果とキー提案をまとめてユーザーに提示し、承認を得てから書き込む。

```
以下のキーを追加します：

【ja.yml】
  articles.show.published_at: "公開日"

【devise.ja.yml】（自動）
  devise.registrations.updated_name: "名前を更新しました。"

確認できたら「ok」と教えてください。キー名や日本語テキストの修正があれば指示してください。
```

---

## Step 5: ロケールファイルへの書き込み

ユーザーの承認後、以下の順で書き込む。

### ja.yml / devise.ja.yml への追加

YAML の階層構造を維持して適切な位置に挿入する。既存のキーと重複しないよう確認してから追加する。

### en.yml / devise.en.yml の自動補完

`ja.yml`（または `devise.ja.yml`）に追加したキーが `en.yml`（または `devise.en.yml`）に存在しない場合、自動で英語訳を補完する。ユーザーへの再確認は不要。

英語訳の方針：
- フラッシュメッセージは過去形（"Article was created."）
- ラベル・ボタンは名詞または動詞原形（"Title", "Create"）
- 短く自然な英語にする

---

## Step 6: ja.yml の肥大化チェック

書き込み後、`ja.yml` の行数を確認する。**100行を超えた場合**、ユーザーに分割を提案する：

```
ja.yml が XXX 行になっています。
コントローラ別にファイルを分割すると管理しやすくなります：

  config/locales/articles.ja.yml  ← articles キーを移動
  config/locales/articles.en.yml  ← 対応する英語キーも移動
  config/locales/ja.yml           ← app_name / nav / flash など共通キーのみ残す

Rails は config/locales/ 内のすべての .yml を自動ロードするため、
分割しても動作は変わりません。Devise がすでに別ファイルになっているのと同じ仕組みです。

分割しますか？
```

---

## Step 7: 完了報告

追加・補完したキーの一覧をまとめて報告する：

```
完了しました。

追加したキー:
  ja.yml:
    articles.show.published_at: "公開日"
  en.yml（自動補完）:
    articles.show.published_at: "Published at"
```