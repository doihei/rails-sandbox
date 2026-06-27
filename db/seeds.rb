# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 既存データをクリア（開発環境のみ）
if Rails.env.development?
  puts "🗑️  既存データをクリア中..."
  Like.destroy_all
  ArticleTag.destroy_all
  Comment.destroy_all
  Article.destroy_all
  Tag.destroy_all
  User.destroy_all
  puts "✅ クリア完了"
end

puts "\n👤 ユーザーを作成中..."

# ユーザー作成
users = [
  { name: "山田太郎", email: "yamada@example.com", password: "password" },
  { name: "佐藤花子", email: "sato@example.com", password: "password" },
  { name: "鈴木一郎", email: "suzuki@example.com", password: "password" },
  { name: "田中美咲", email: "tanaka@example.com", password: "password" },
  { name: "伊藤健二", email: "ito@example.com", password: "password" },
  { name: "渡辺さくら", email: "watanabe@example.com", password: "password" }
].map do |attrs|
  User.create!(attrs)
end

puts "✅ #{users.count}人のユーザーを作成しました"

puts "\n🏷️  タグを作成中..."

# タグ作成
tag_names = %w[rails ruby javascript react vue postgresql redis docker kubernetes aws typescript graphql testing ci-cd linux]
tags = tag_names.map do |name|
  Tag.find_or_create_by_name!(name)
end

puts "✅ #{tags.count}個のタグを作成しました"

puts "\n📝 記事を作成中..."

# 固定記事データ（人気記事・特集記事）
fixed_articles = [
  {
    title: "Rails 8の新機能まとめ",
    body: "Rails 8では多くの新機能が追加されました。Solid Queue、Solid Cache、Solid Cableなどのsolid系gemが標準搭載され、Redisなしでも高機能なアプリケーションが構築できるようになりました。",
    status: "published",
    user: users[0],
    tags: [ "rails", "ruby" ],
    comments_count: 15
  },
  {
    title: "PostgreSQLのパフォーマンスチューニング",
    body: "PostgreSQLのパフォーマンスを最大化するためのベストプラクティスを紹介します。インデックスの最適化、クエリプランの分析、コネクションプーリングの設定など。",
    status: "published",
    user: users[1],
    tags: [ "postgresql", "rails" ],
    comments_count: 8
  },
  {
    title: "Dockerで開発環境を構築する",
    body: "Docker Composeを使った開発環境の構築方法を解説します。Rails、PostgreSQL、Redisをコンテナで管理し、チーム全体で統一された環境を実現します。",
    status: "published",
    user: users[2],
    tags: [ "docker", "rails", "postgresql" ],
    comments_count: 12
  },
  {
    title: "React HooksでState管理をシンプルに",
    body: "React Hooksを使ったState管理のベストプラクティスを紹介します。useState、useEffect、useContextなどの基本的なHooksから、カスタムHooksの作り方まで。",
    status: "published",
    user: users[3],
    tags: [ "react", "javascript" ],
    comments_count: 6
  },
  {
    title: "Vue.js 3の新機能",
    body: "Vue.js 3ではComposition APIが導入され、より柔軟なコンポーネント設計が可能になりました。TypeScriptとの連携も強化されています。",
    status: "published",
    user: users[0],
    tags: [ "vue", "javascript" ],
    comments_count: 5
  },
  {
    title: "Kubernetesで本番環境を構築",
    body: "Kubernetesを使った本番環境の構築と運用について解説します。Pod、Service、Deployment、Ingressなどの基本概念から、スケーリング戦略まで。",
    status: "published",
    user: users[1],
    tags: [ "kubernetes", "docker", "aws" ],
    comments_count: 10
  },
  {
    title: "Redisをキャッシュとして活用する",
    body: "Redisの基本的な使い方から、Railsでのキャッシュ戦略まで解説します。セッションストア、フラグメントキャッシュ、低レイテンシ実現のためのテクニック。",
    status: "published",
    user: users[2],
    tags: [ "redis", "rails" ],
    comments_count: 7
  },
  {
    title: "AWSで始めるサーバーレスアーキテクチャ",
    body: "AWS LambdaとAPI Gatewayを使ったサーバーレスアーキテクチャの構築方法を紹介します。コスト削減とスケーラビリティを両立する設計パターン。",
    status: "published",
    user: users[3],
    tags: [ "aws" ],
    comments_count: 4
  },
  {
    title: "Rubyのメタプログラミング入門",
    body: "Rubyの強力な機能であるメタプログラミングについて解説します。define_method、method_missing、evalなどを使った動的なコード生成テクニック。",
    status: "published",
    user: users[0],
    tags: [ "ruby" ],
    comments_count: 9
  },
  {
    title: "JavaScriptの非同期処理を理解する",
    body: "JavaScriptの非同期処理の基本から、Promise、async/awaitまで詳しく解説します。コールバック地獄を回避し、読みやすいコードを書くためのベストプラクティス。",
    status: "published",
    user: users[1],
    tags: [ "javascript" ],
    comments_count: 2
  },
  {
    title: "下書き記事のサンプル",
    body: "これは下書き記事です。公開前の記事として保存されています。",
    status: "draft",
    user: users[2],
    tags: [ "rails" ],
    comments_count: 0
  }
]

fixed_articles.each do |data|
  article = Article.create!(
    title: data[:title],
    body: data[:body],
    status: data[:status],
    user: data[:user],
    comments_count: data[:comments_count]
  )
  data[:tags].each do |tag_name|
    tag = Tag.find_by(name: tag_name)
    article.tags << tag if tag
  end
  print "."
end

# ページネーション確認用の大量記事を自動生成
generated_topics = [
  { title_prefix: "RailsのActive Record入門", tech: "rails", tags: %w[rails ruby] },
  { title_prefix: "TypeScriptで型安全なAPIを作る", tech: "typescript", tags: %w[typescript javascript] },
  { title_prefix: "GraphQL APIの設計パターン", tech: "graphql", tags: %w[graphql rails] },
  { title_prefix: "RSpecによるテスト駆動開発", tech: "testing", tags: %w[testing rails ruby] },
  { title_prefix: "GitHub ActionsでCI/CDパイプラインを構築", tech: "ci-cd", tags: %w[ci-cd docker] },
  { title_prefix: "Linuxサーバーのセキュリティ設定", tech: "linux", tags: %w[linux aws] },
  { title_prefix: "Reactのパフォーマンス最適化テクニック", tech: "react", tags: %w[react javascript typescript] },
  { title_prefix: "PostgreSQLのインデックス設計", tech: "postgresql", tags: %w[postgresql rails] },
  { title_prefix: "DockerイメージのサイズをSlimにする方法", tech: "docker", tags: %w[docker ci-cd] },
  { title_prefix: "Rubyの並行処理とスレッドセーフ設計", tech: "ruby", tags: %w[ruby rails] },
  { title_prefix: "AWS ECSでコンテナを本番運用する", tech: "aws", tags: %w[aws docker kubernetes] },
  { title_prefix: "Vue.jsとNuxtで作るSSRアプリ", tech: "vue", tags: %w[vue javascript] },
  { title_prefix: "Redisのデータ構造を使いこなす", tech: "redis", tags: %w[redis] },
  { title_prefix: "KubernetesのHelm Chartで環境管理", tech: "kubernetes", tags: %w[kubernetes docker] },
  { title_prefix: "JavaScriptのデザインパターン実践", tech: "javascript", tags: %w[javascript typescript] }
]

bodies = [
  "この記事では基礎から応用まで丁寧に解説します。初心者でも理解できるよう、具体的なコード例を交えながら説明していきます。実際のプロジェクトでも即座に活用できる知識を身につけましょう。",
  "実務経験をもとに、現場で使えるノウハウをまとめました。パフォーマンスと保守性を両立するアプローチを中心に、よくある落とし穴と回避策も紹介します。",
  "チームの生産性を上げるためのベストプラクティスを紹介します。コードレビューの効率化、ドキュメント管理、自動化など、多角的な視点でアプローチします。",
  "最新バージョンの新機能を網羅的に解説します。アップグレードの際に注意すべきBreaking Changeと、新機能の活用方法を具体的なサンプルコードで示します。",
  "よくある問題とその解決策を厳選してまとめました。Stack Overflowで頻出の質問から、経験者でも陥りやすいトラップまで、実例とともに解説します。"
]

statuses = %w[published published published published draft]

50.times do |i|
  topic = generated_topics[i % generated_topics.size]
  article = Article.create!(
    title: "#{topic[:title_prefix]}（第#{i + 1}回）",
    body: bodies[i % bodies.size],
    status: statuses[i % statuses.size],
    user: users[i % users.size],
    comments_count: [ 0, 0, 1, 2, 3, 5, 8 ].sample
  )
  topic[:tags].each do |tag_name|
    tag = Tag.find_by(name: tag_name)
    article.tags << tag if tag
  end
  print "."
end

puts "\n✅ #{Article.count}件の記事を作成しました"

puts "\n💬 コメントを作成中..."

# コメント作成（人気記事になるように）
comment_texts = [
  "とても参考になりました！",
  "詳しい解説ありがとうございます。",
  "実際に試してみたいと思います。",
  "素晴らしい記事ですね。",
  "もっと詳しく知りたいです。",
  "次回の記事も楽しみにしています。",
  "実装してみました、うまくいきました！",
  "初心者にもわかりやすい説明でした。",
  "このアプローチは目から鱗でした。",
  "プロダクションでも使えそうです。"
]

# Counter Cacheに合わせて実際のコメントを作成
Article.where("comments_count > 0").each do |article|
  article.comments_count.times do |i|
    Comment.create!(
      article: article,
      user: users.sample,
      body: comment_texts.sample
    )
    print "."
  end
end

puts "\n✅ #{Comment.count}件のコメントを作成しました"

puts "\n❤️  いいねを作成中..."

# 記事へのいいね（著者本人を除くユーザーがいいね）
Article.published.each do |article|
  other_users = users.reject { |u| u.id == article.user_id }
  other_users.sample(rand(0..other_users.length)).each do |user|
    Like.create!(likeable: article, user: user)
    print "."
  end
end

# コメントへのいいね（著者本人を除く一部ユーザーがいいね）
Comment.all.sample(Comment.count / 2).each do |comment|
  other_users = users.reject { |u| u.id == comment.user_id }
  other_users.sample(rand(0..[ other_users.length, 2 ].min)).each do |user|
    Like.find_or_create_by!(likeable: comment, user: user)
    print "."
  end
end

puts "\n✅ #{Like.count}件のいいねを作成しました"

puts "\n" + "="*50
puts "🎉 シードデータの作成が完了しました！"
puts "="*50
puts "\n📊 作成されたデータ:"
puts "  - ユーザー: #{User.count}人"
puts "  - 記事: #{Article.count}件（公開: #{Article.published.count}件、下書き: #{Article.where(status: 'draft').count}件）"
puts "  - タグ: #{Tag.count}個"
puts "  - コメント: #{Comment.count}件"
puts "  - いいね: #{Like.count}件（記事: #{Like.where(likeable_type: 'Article').count}件、コメント: #{Like.where(likeable_type: 'Comment').count}件）"
puts "\n🔥 人気記事（コメント3件以上）: #{Article.popular.count}件"
puts "\n📝 確認用URL:"
puts "  - 記事一覧: http://localhost:8080/articles"
puts "  - 人気記事: http://localhost:8080/articles/popular"
puts "  - タグ一覧: http://localhost:8080/tags"
puts "\n👤 ログイン情報:"
puts "  Email: yamada@example.com"
puts "  Password: password"
puts ""
