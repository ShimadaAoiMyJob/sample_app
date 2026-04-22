require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "should get home" do#ホームページのテスト
    get root_path #GetアクションをHomeアクションに対して発行(送信)せよ
    assert_response :success#リクエストに対するレスポンスは[成功]になるはず
    assert_select "title", "Ruby on Rails Tutorial Sample App"
    #home.html.erbのtitleというタグ<title>の中に
    #Ruby on Rails Tutorial Sample Appがあるか
  end


  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end
  test "should get root" do
    get root_url
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

end