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
    body: <<~'MD',
      # Rails 8 の新機能まとめ

      Rails 8 では多くの新機能が追加され、より少ない依存関係で高機能なアプリを構築できるようになりました。

      ## Solid 系 gem の標準搭載

      Redis なしで以下の機能が利用可能になりました。

      | gem | 役割 |
      |---|---|
      | Solid Queue | バックグラウンドジョブ |
      | Solid Cache | キャッシュストア |
      | Solid Cable | Action Cable アダプタ |

      ## Kamal 2 との統合

      デプロイツール **Kamal 2** が Rails にバンドルされ、`bin/kamal` コマンドでゼロダウンタイムデプロイが実現できます。

      ```bash
      # 初回セットアップ
      bin/kamal setup

      # デプロイ
      bin/kamal deploy
      ```

      ## その他の変更点

      - **Propshaft** がデフォルトのアセットパイプラインに
      - **SQLite** 本番利用のサポート強化
      - **Brakeman** がデフォルトで有効化

      ## まとめ

      Rails 8 はインフラ依存を減らしつつ、スモールチームでも本番運用できる構成を目指した大きなリリースです。
    MD
    status: "published",
    user: users[0],
    tags: [ "rails", "ruby" ],
    comments_count: 15
  },
  {
    title: "PostgreSQLのパフォーマンスチューニング",
    body: <<~'MD',
      # PostgreSQL のパフォーマンスチューニング

      本番環境での PostgreSQL を最大限に活かすためのベストプラクティスをまとめます。

      ## インデックスの最適化

      最も効果的なチューニングはインデックス設計です。

      ### 複合インデックスの列順序

      ```sql
      -- NG: カーディナリティの低い列を先にしている
      CREATE INDEX ON articles (status, user_id);

      -- OK: 検索条件に合わせて user_id を先に
      CREATE INDEX ON articles (user_id, status);
      ```

      ### 部分インデックス

      ```sql
      -- 公開記事のみ対象にして index サイズを削減
      CREATE INDEX ON articles (created_at) WHERE status = 'published';
      ```

      ## EXPLAIN ANALYZE の読み方

      クエリプランを確認して**Seq Scan**を**Index Scan**に変えることが基本です。

      ```sql
      EXPLAIN ANALYZE
      SELECT * FROM articles WHERE user_id = 1 AND status = 'published';
      ```

      > **ポイント**: `cost=` の右側の数値が実際のコストです。1000 を超えていたら要改善。

      ## コネクションプーリング

      Rails では `database.yml` の `pool` 設定と PgBouncer を組み合わせることで効率的なコネクション管理ができます。

      ## まとめ

      1. まず `EXPLAIN ANALYZE` でボトルネックを特定する
      2. インデックスを追加・見直す
      3. クエリを書き直す
      4. 設定パラメータを調整する
    MD
    status: "published",
    user: users[1],
    tags: [ "postgresql", "rails" ],
    comments_count: 8
  },
  {
    title: "Dockerで開発環境を構築する",
    body: <<~'MD',
      # Docker で開発環境を構築する

      Docker Compose を使って Rails + PostgreSQL + Redis の開発環境をコンテナ化する手順を解説します。

      ## ディレクトリ構成

      ```
      project/
      ├── docker-compose.yml
      ├── Dockerfile
      └── .env
      ```

      ## Dockerfile

      ```dockerfile
      FROM ruby:3.3-slim

      RUN apt-get update && apt-get install -y \
        build-essential \
        libpq-dev \
        && rm -rf /var/lib/apt/lists/*

      WORKDIR /app
      COPY Gemfile Gemfile.lock ./
      RUN bundle install

      COPY . .
      CMD ["bin/rails", "server", "-b", "0.0.0.0"]
      ```

      ## docker-compose.yml

      ```yaml
      services:
        app:
          build: .
          ports:
            - "3000:3000"
          depends_on:
            - db
          environment:
            DATABASE_URL: postgres://postgres:password@db:5432/myapp_development

        db:
          image: postgres:16
          environment:
            POSTGRES_PASSWORD: password
          volumes:
            - pgdata:/var/lib/postgresql/data

      volumes:
        pgdata:
      ```

      ## よくあるトラブル

      - **`bundle install` が遅い**: `.bundle` をボリュームでマウントしてキャッシュする
      - **DB 接続エラー**: `depends_on` だけでは起動順序を保証できないため `wait-for-it.sh` を使う

      ## まとめ

      チーム全体で同じ環境を使うことで「自分のマシンでは動く」問題を防げます。
    MD
    status: "published",
    user: users[2],
    tags: [ "docker", "rails", "postgresql" ],
    comments_count: 12
  },
  {
    title: "React HooksでState管理をシンプルに",
    body: <<~'MD',
      # React Hooks で State 管理をシンプルに

      Class コンポーネントから Hooks へ。関数コンポーネントだけでほぼすべてのケースに対応できます。

      ## 基本の Hooks

      ### useState

      ```tsx
      const [count, setCount] = useState(0)

      return (
        <button onClick={() => setCount(c => c + 1)}>
          {count} 回クリック
        </button>
      )
      ```

      ### useEffect

      副作用（API 呼び出し・タイマー）はここに書きます。

      ```tsx
      useEffect(() => {
        fetch('/api/articles').then(res => res.json()).then(setArticles)
      }, []) // [] = マウント時のみ実行
      ```

      ### useCallback / useMemo

      > **使いすぎ注意**: 最適化は計測してから。

      ```tsx
      // 子コンポーネントへ渡す関数は useCallback でメモ化
      const handleSubmit = useCallback((values) => {
        // ...
      }, [])
      ```

      ## カスタム Hooks

      ロジックを関数として切り出せます。

      ```tsx
      function useArticles() {
        const [articles, setArticles] = useState([])
        const [loading, setLoading] = useState(true)

        useEffect(() => {
          fetchArticles().then(data => {
            setArticles(data)
            setLoading(false)
          })
        }, [])

        return { articles, loading }
      }
      ```

      ## まとめ

      - シンプルなケースから始めて、複雑になったらカスタム Hooks に抽出する
      - グローバルな State が必要になったら Zustand や Jotai を検討する
    MD
    status: "published",
    user: users[3],
    tags: [ "react", "javascript" ],
    comments_count: 6
  },
  {
    title: "TypeScriptで型安全なGraphQL Clientを作る",
    body: <<~'MD',
      # TypeScript で型安全な GraphQL Client を作る

      `graphql-codegen` を使えば、GraphQL スキーマから TypeScript 型を自動生成できます。

      ## セットアップ

      ```bash
      npm install -D @graphql-codegen/cli @graphql-codegen/typescript
      npm install @apollo/client graphql
      ```

      `codegen.ts` を作成します。

      ```ts
      import type { CodegenConfig } from '@graphql-codegen/cli'

      const config: CodegenConfig = {
        schema: 'http://localhost:8080/graphql',
        documents: ['src/**/*.tsx'],
        generates: {
          './lib/gql/': {
            preset: 'client',
          },
        },
      }

      export default config
      ```

      ## クエリの書き方

      ```tsx
      import { gql } from '@/lib/gql'

      const GET_ARTICLES = gql(`
        query GetArticles($first: Int) {
          articles(first: $first) {
            nodes {
              id
              title
              body
            }
          }
        }
      `)
      ```

      `npm run codegen` を実行すると `lib/gql/` に型が生成されます。

      ## useQuery で型安全に取得

      ```tsx
      const { data, loading } = useQuery(GET_ARTICLES, {
        variables: { first: 10 },
      })

      // data.articles.nodes は ArticlesQuery['articles']['nodes'] 型
      ```

      ## まとめ

      - スキーマを変更したら必ず `codegen` を再実行する
      - 手動型定義は書かない
    MD
    status: "published",
    user: users[0],
    tags: [ "typescript", "graphql" ],
    comments_count: 5
  },
  {
    title: "Kubernetesで本番環境を構築",
    body: <<~'MD',
      # Kubernetes で本番環境を構築する

      Kubernetes の基本概念から実際の運用まで、Rails アプリを例に解説します。

      ## 基本リソース

      | リソース | 役割 |
      |---|---|
      | Pod | コンテナの最小実行単位 |
      | Deployment | Pod のレプリカ管理・ローリングアップデート |
      | Service | Pod への内部ロードバランシング |
      | Ingress | 外部 HTTP トラフィックのルーティング |

      ## Deployment マニフェスト

      ```yaml
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: rails-app
      spec:
        replicas: 3
        selector:
          matchLabels:
            app: rails-app
        template:
          spec:
            containers:
              - name: rails
                image: myrepo/rails-app:latest
                ports:
                  - containerPort: 3000
                env:
                  - name: DATABASE_URL
                    valueFrom:
                      secretKeyRef:
                        name: rails-secrets
                        key: database-url
      ```

      ## スケーリング

      ```bash
      # 手動スケール
      kubectl scale deployment rails-app --replicas=5

      # HPA（水平自動スケール）
      kubectl autoscale deployment rails-app --min=2 --max=10 --cpu-percent=70
      ```

      ## ヘルスチェック

      ```yaml
      livenessProbe:
        httpGet:
          path: /healthz
          port: 3000
        initialDelaySeconds: 30
      ```

      ## まとめ

      小規模なら Cloud Run の方がシンプルですが、細かい制御が必要なら Kubernetes が強力です。
    MD
    status: "published",
    user: users[1],
    tags: [ "kubernetes", "docker", "aws" ],
    comments_count: 10
  },
  {
    title: "Rubyのメタプログラミング入門",
    body: <<~'MD',
      # Ruby のメタプログラミング入門

      Ruby はコードがコードを生成する「メタプログラミング」が強力な言語です。

      ## define_method

      動的にメソッドを定義できます。

      ```ruby
      class Article
        %i[draft published archived].each do |status|
          define_method("#{status}?") do
            self.status == status.to_s
          end
        end
      end

      article.published? # => true / false
      ```

      ## method_missing

      存在しないメソッドを呼んだときの挙動をカスタマイズできます。

      ```ruby
      class FlexibleRecord
        def method_missing(name, *args)
          if name.to_s.start_with?('find_by_')
            attribute = name.to_s.sub('find_by_', '')
            where(attribute => args.first)
          else
            super
          end
        end

        def respond_to_missing?(name, include_private = false)
          name.to_s.start_with?('find_by_') || super
        end
      end
      ```

      > **注意**: `method_missing` を使う場合は必ず `respond_to_missing?` もオーバーライドすること。

      ## open class（モンキーパッチ）

      既存クラスにメソッドを追加できます。

      ```ruby
      class String
        def to_slug
          downcase.strip.gsub(/\s+/, '-').gsub(/[^\w-]/, '')
        end
      end

      "Hello World!".to_slug # => "hello-world"
      ```

      ## まとめ

      メタプログラミングは強力ですが**濫用は禁物**です。コードが読みにくくなるため、DSL 構築など明確な目的がある場合のみ使いましょう。
    MD
    status: "published",
    user: users[0],
    tags: [ "ruby" ],
    comments_count: 9
  },
  {
    title: "JavaScriptの非同期処理を理解する",
    body: <<~'MD',
      # JavaScript の非同期処理を理解する

      コールバックから Promise、async/await まで、非同期処理の進化を追います。

      ## コールバック地獄

      ```js
      fetchUser(id, (user) => {
        fetchArticles(user.id, (articles) => {
          fetchComments(articles[0].id, (comments) => {
            // ネストが深くなる...
          })
        })
      })
      ```

      ## Promise

      チェーンで書けるようになりました。

      ```js
      fetchUser(id)
        .then(user => fetchArticles(user.id))
        .then(articles => fetchComments(articles[0].id))
        .then(comments => console.log(comments))
        .catch(err => console.error(err))
      ```

      ## async / await

      さらに同期的に書けます。

      ```js
      async function loadComments(userId) {
        try {
          const user = await fetchUser(userId)
          const articles = await fetchArticles(user.id)
          const comments = await fetchComments(articles[0].id)
          return comments
        } catch (err) {
          console.error(err)
        }
      }
      ```

      ## 並列実行

      順序依存がない処理は `Promise.all` でまとめて待ちます。

      ```js
      const [user, tags] = await Promise.all([
        fetchUser(id),
        fetchTags(),
      ])
      ```

      ## まとめ

      - 単一の非同期処理 → `await`
      - 並列処理 → `Promise.all`
      - エラーは `try/catch` で統一
    MD
    status: "published",
    user: users[1],
    tags: [ "javascript" ],
    comments_count: 2
  },
  {
    title: "RSpecによるテスト駆動開発入門",
    body: <<~'MD',
      # RSpec によるテスト駆動開発入門

      テストを先に書いてコードを育てる TDD のサイクルを RSpec で実践します。

      ## Red → Green → Refactor

      1. **Red**: 失敗するテストを書く
      2. **Green**: テストをパスする最小限のコードを書く
      3. **Refactor**: コードをきれいにする

      ## 基本の書き方

      ```ruby
      # spec/models/article_spec.rb
      RSpec.describe Article, type: :model do
        describe 'validations' do
          it 'タイトルが必須' do
            article = Article.new(title: nil)
            expect(article).not_to be_valid
            expect(article.errors[:title]).to include("can't be blank")
          end
        end

        describe 'scopes' do
          let!(:published) { create(:article, status: :published) }
          let!(:draft) { create(:article, status: :draft) }

          it '.published は公開済み記事のみ返す' do
            expect(Article.published).to include(published)
            expect(Article.published).not_to include(draft)
          end
        end
      end
      ```

      ## FactoryBot との組み合わせ

      ```ruby
      # spec/factories/articles.rb
      FactoryBot.define do
        factory :article do
          title { "テスト記事" }
          body { "本文です" }
          status { :published }
          association :user
        end
      end
      ```

      ## まとめ

      - テストはコードの**仕様書**でもある
      - `let!` は遅延評価しないため DB に即時挿入される
      - `create` は DB に保存、`build` は保存しない
    MD
    status: "published",
    user: users[2],
    tags: [ "testing", "rails", "ruby" ],
    comments_count: 7
  },
  {
    title: "GitHub ActionsでCI/CDパイプラインを構築する",
    body: <<~'MD',
      # GitHub Actions で CI/CD パイプラインを構築する

      プッシュのたびにテスト・Lint・デプロイを自動化するワークフローを作ります。

      ## 基本構成

      ```
      .github/
      └── workflows/
          ├── ci.yml      # PR 時にテスト・Lint
          └── deploy.yml  # main へのマージ時にデプロイ
      ```

      ## ci.yml

      ```yaml
      name: CI

      on:
        pull_request:
          branches: [main]

      jobs:
        test:
          runs-on: ubuntu-latest
          services:
            postgres:
              image: postgres:16
              env:
                POSTGRES_PASSWORD: password
              options: >-
                --health-cmd pg_isready
                --health-interval 10s

          steps:
            - uses: actions/checkout@v4
            - uses: ruby/setup-ruby@v1
              with:
                bundler-cache: true
            - run: bin/rails db:create db:schema:load
            - run: bundle exec rspec
            - run: bundle exec rubocop
      ```

      ## キャッシュで高速化

      ```yaml
      - uses: actions/cache@v4
        with:
          path: vendor/bundle
          key: ${{ runner.os }}-gems-${{ hashFiles('Gemfile.lock') }}
      ```

      ## まとめ

      - `on: push` より `on: pull_request` で PR ごとに検証するのが基本
      - Secrets は GitHub リポジトリの Settings から設定する
      - `needs:` でジョブの依存関係を定義できる
    MD
    status: "published",
    user: users[3],
    tags: [ "ci-cd", "docker" ],
    comments_count: 4
  },
  {
    title: "下書き：GraphQL N+1問題の解決策",
    body: <<~'MD',
      # GraphQL N+1 問題の解決策（下書き）

      ## 問題

      GraphQL で記事一覧を取得すると、各記事のユーザーを取得するクエリが N 回走る。

      ## 解決策候補

      - `batch-loader` gem を使う
      - `dataloader` を使う
      - `includes` で eager loading する

      ## TODO

      - [ ] コードサンプルを追加する
      - [ ] ベンチマーク結果を載せる
    MD
    status: "draft",
    user: users[2],
    tags: [ "graphql", "rails" ],
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
  <<~'MD',
    ## はじめに

    この記事では基礎から応用まで丁寧に解説します。初心者でも理解できるよう、具体的なコード例を交えながら進めます。

    ## 基本的な使い方

    まずは簡単なサンプルから始めましょう。

    ```ruby
    # シンプルな例
    def hello(name)
      "Hello, #{name}!"
    end

    puts hello("World") # => Hello, World!
    ```

    ## まとめ

    - 基本を押さえれば応用は自然と身につく
    - 公式ドキュメントを積極的に参照しよう
  MD
  <<~'MD',
    ## 背景

    実務経験をもとに、現場で使えるノウハウをまとめました。

    ## よくある落とし穴

    > 焦って実装するより、設計に時間をかける方が結果的に速い。

    ### アンチパターン例

    ```python
    # NG: 毎回 DB に問い合わせている
    for user in users:
        print(user.articles.count())

    # OK: 事前に集計する
    counts = Article.group(:user_id).count
    ```

    ## パフォーマンスと保守性のバランス

    | アプローチ | パフォーマンス | 保守性 |
    |---|---|---|
    | 生 SQL | ◎ | △ |
    | ORM | ○ | ◎ |
    | キャッシュ | ◎ | ○ |

    ## まとめ

    早すぎる最適化は避け、計測してから改善する。
  MD
  <<~'MD',
    ## チームの生産性を上げる

    コードレビュー・ドキュメント・自動化の三本柱でアプローチします。

    ## コードレビューの効率化

    レビュー前のチェックリストを用意しましょう。

    - [ ] テストが通っているか
    - [ ] 変更理由がコミットメッセージに書かれているか
    - [ ] 不要なコメントが残っていないか

    ## 自動化できること

    ```yaml
    # .github/workflows/lint.yml
    - run: bundle exec rubocop --format github
    - run: yarn eslint src/
    ```

    ## まとめ

    自動化できることは自動化し、人間はより高度な判断に集中する。
  MD
  <<~'MD',
    ## アップグレードガイド

    最新バージョンへの移行で気をつけるべき Breaking Change をまとめます。

    ## 主な変更点

    1. **設定ファイルの形式変更** - YAML から TOML に
    2. **非推奨 API の削除** - v2 で警告が出ていたメソッドが v3 で削除
    3. **デフォルト値の変更** - タイムゾーンのデフォルトが UTC に統一

    ## 移行手順

    ```bash
    # 1. 依存関係を更新
    bundle update rails

    # 2. 非推奨 API の置き換え
    bundle exec rails app:update

    # 3. テストを実行して確認
    bundle exec rspec
    ```

    > **注意**: ステージング環境で十分に検証してから本番に適用すること。

    ## まとめ

    Breaking Change は `CHANGELOG.md` を必ず確認してから対応する。
  MD
  <<~'MD'
    ## よくある問題と解決策

    現場で遭遇しやすいトラブルを厳選してまとめました。

    ## 問題 1: N+1 クエリ

    ```ruby
    # NG
    Article.all.each { |a| puts a.user.name }

    # OK
    Article.includes(:user).each { |a| puts a.user.name }
    ```

    ## 問題 2: タイムゾーンのズレ

    ```ruby
    # NG: サーバーのローカル時刻を使ってしまう
    Time.now

    # OK: UTC 基準で扱う
    Time.current
    ```

    ## 問題 3: メモリリーク

    大量データを処理する場合は `find_each` を使いましょう。

    ```ruby
    # NG: 全件をメモリに読み込む
    Article.all.each { |a| process(a) }

    # OK: バッチ処理
    Article.find_each(batch_size: 1000) { |a| process(a) }
    ```

    ## まとめ

    計測なしの最適化は禁物。まず `Bullet` gem や `rack-mini-profiler` で問題を特定する。
  MD
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
