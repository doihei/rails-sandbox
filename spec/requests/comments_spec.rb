require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:article) { create(:article) }

  before { sign_in user }

  describe "POST /articles/:article_id/comments" do
    it "コメントを投稿できる" do
      expect { post article_comments_path(article), params: { comment: { body: "新しいコメント" } } }
        .to change(Comment, :count).by(1)
    end

    it "投稿後に記事詳細へリダイレクトする" do
      post article_comments_path(article), params: { comment: { body: "新しいコメント" } }
      expect(response).to redirect_to(article_path(article))
    end

    it "本文なしはコメントが増えない" do
      expect { post article_comments_path(article), params: { comment: { body: "" } } }
        .not_to change(Comment, :count)
    end
  end

  describe "DELETE /articles/:article_id/comments/:id" do
    it "自分のコメントを削除できる" do
      comment = create(:comment, article: article, user: user)
      expect { delete article_comment_path(article, comment) }
        .to change(Comment, :count).by(-1)
    end

    it "他人のコメントは削除できない" do
      other_comment = create(:comment, article: article, user: other_user)
      expect { delete article_comment_path(article, other_comment) }
        .not_to change(Comment, :count)
      expect(flash[:alert]).to eq(I18n.t("flash.comment.unauthorized"))
    end
  end
end
