class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:rails)
    sign_in users(:one)
  end

  test "タグ別記事一覧を取得できる" do
    get tag_url(@tag)
    assert_response :success
  end

  test "該当タグの記事だけ表示される" do
    get tag_url(@tag)
    # fixture の article :one は rails タグ付き
    assert_select "a", text: articles(:one).title
  end

  test "タグのない記事は表示されない" do
    # article :two は fixture でタグなし
    get tag_url(tags(:ruby))
    assert_select "a[href='#{article_path(articles(:two))}']", count: 0
  end

  test "存在しないタグは 404" do
    get tag_url(id: 999999)
    assert_response :not_found
  end

  test "未ログインはログインページへリダイレクト" do
    sign_out :user
    get tag_url(@tag)
    assert_redirected_to new_user_session_path
  end
end
