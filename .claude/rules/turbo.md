## Turbo Frame の規約

- Frame ID は複数形リソース名に統一する（例: `turbo_frame_tag "articles"`）
- index / show / new / edit で同じ Frame ID を使うことで、リンク遷移時に同じ Frame が差し替わる
- `turbo_frame_tag` の開きと閉じは対象のフォーム/コンテンツを "完全に包む" こと。ビューの外側に置くと "Content missing" エラーになる（過去 bug fix: commit `3a97acb`）
