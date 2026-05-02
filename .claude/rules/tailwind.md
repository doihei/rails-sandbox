---
paths:
  - "app/views/**/*.erb"
---

## Tailwind CSS 規約

このプロジェクトは Tailwind CSS を使用する。インラインの `style=` 属性は使わない。

### 共通クラスセット

**カード（コンテンツ枠）**
```
bg-white border border-gray-200 rounded-lg p-6
```

**ページヘッダー（タイトル + 右ボタン）**
```
flex justify-between items-center mb-6
```

**見出し**
```
text-2xl font-semibold text-gray-800   # ページタイトル（index / new / edit）
text-xl font-semibold text-gray-800    # カード内タイトル（show / devise）
```

**フォームラベル**
```
block text-sm font-medium text-gray-700 mb-1
```

**フォーム入力フィールド**
```
w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:border-gray-500
```

**補助テキスト（文字数・ヒント）**
```
text-xs text-gray-400
```

**ボタン**
```
# プライマリ（送信・公開）
bg-gray-800 text-white px-4 py-2 rounded text-sm hover:bg-gray-700 cursor-pointer

# セカンダリ（編集・キャンセル）
text-gray-600 border border-gray-300 px-4 py-1.5 rounded hover:bg-gray-50

# デンジャー（削除）
text-red-600 border border-red-200 px-4 py-1.5 rounded hover:bg-red-50 cursor-pointer bg-white
```

**エラーメッセージ（フォーム内）**
```
bg-red-50 border-l-4 border-red-400 text-red-700 px-4 py-3 text-sm mb-4 rounded
```

### Devise フォームの幅

```
max-w-sm mx-auto   # ログイン・登録など認証系は幅を絞る
```