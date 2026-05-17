require "rails_helper"

RSpec.describe Article, type: :model do
  let(:article) { create(:article) }

  describe "バリデーション" do
    context "有効なデータの場合" do
      it '保存できる' do
        expect(article).to be_valid
      end
    end

    context "titleの空の場合" do
      it '無効になる' do
        article.title = ""
        expect(article).not_to be_valid
      end
    end

    context "titleの100文字以上の場合" do
      it '無効になる' do
        article.title = "test123456" * 11
        expect(article).not_to be_valid
      end
    end

    context "bodyの空の場合" do
      it '無効になる' do
        article.body = ""
        expect(article).not_to be_valid
      end
    end

    context "userがない場合" do
      it '無効になる' do
        article = build(:article, user: nil)
        expect(article).not_to be_valid
      end
    end
  end

  describe "コールバック" do
    it "before_save でタイトル前後の空白が除去される" do
      article = create(:article, title: "  タイトル  ")
      expect(article.title).to eq("タイトル")
    end
  end

  describe "スコープ" do
    context ".published" do
      it '公開済み記事だけ返す' do
        published = create(:article, :published)
        draft = article
        expect(Article.published).to include(published)
        expect(Article.published).not_to include(draft)
      end
    end

    context ".popular" do
      it 'コメント3件以上の記事を返す' do
        popular = create(:article, :published)
        3.times { create(:comment, article: popular) }
        unpopular = create(:article, :published)
        expect(Article.popular).to include(popular)
        expect(Article.popular).not_to include(unpopular)
      end
    end

    context ".tagged_with" do
      it '指定タグを持つ記事を返す' do
        tagged = create(:article, :with_tags)
        untagged = article
        tag_name = tagged.tags.first.name
        expect(Article.tagged_with(tag_name)).to include(tagged)
        expect(Article.tagged_with(tag_name)).not_to include(untagged)
      end
    end

    context ".tagged_with_all" do
      it '複数タグをすべて持つ記事だけ返す（AND 検索）' do
        tag_a = create(:tag, name: "ruby")
        tag_b = create(:tag, name: "rails")
        both = create(:article)
        both.tags << [ tag_a, tag_b ]
        only_a = create(:article)
        only_a.tags << tag_a

        result = Article.tagged_with_all("ruby", "rails")
        expect(result).to include(both)
        expect(result).not_to include(only_a)
      end
    end

    context ".by_latest_comment" do
      it '最新コメントが新しい順に並び、コメントなし記事は末尾になる' do
        no_comment = create(:article)
        old_comment_article = create(:article)
        create(:comment, article: old_comment_article, created_at: 2.days.ago)
        new_comment_article = create(:article)
        create(:comment, article: new_comment_article, created_at: 1.day.ago)

        result = Article.by_latest_comment.to_a
        expect(result.index(new_comment_article)).to be < result.index(old_comment_article)
        expect(result.last).to eq(no_comment)
      end
    end

    context ".above_average_comments" do
      it 'コメント数が平均より多い記事を返す' do
        high = create(:article)
        3.times { create(:comment, article: high) }
        high.reload

        low = create(:article)
        create(:comment, article: low)
        low.reload

        result = Article.above_average_comments
        expect(result).to include(high)
        expect(result).not_to include(low)
      end
    end
  end

  describe "Optimistic Locking" do
    it "古いlock_versionで保存するとStaleObjectErrorが発生する" do
      a = Article.find(article.id)
      b = Article.find(article.id)

      a.update!(title: "Aの更新")

      expect { b.update!(title: "Bの更新") }
        .to raise_error(ActiveRecord::StaleObjectError)
    end

    it '正しいlock_versionなら連続更新できる' do
      article.update!(title: "1回目")
      expect { article.update!(title: "2回目") }.not_to raise_error
    end
  end
end
