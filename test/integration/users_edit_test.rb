require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    #このuser_path(@user)は,
    #PATCH /users/1で, RailsはURLに対してリクエストを送る
    #(routeで設定したresources :users)
    # その結果, controllerのUsersController#updateが呼ばれる
    patch user_path(@user),params: {user:{name: "",
                                          email: "foo@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"}}
    assert_template "users/edit"
    assert_select "div.alert", "The form contains 4 errors"
    #エラーの個数が正しい?
    #editviewでrenderしてる_error_messages.html.erbにある
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    name = "Foo Bar"
    email = "foo@bar.com"

    patch user_path(@user),params: {user: { name: name,
                                            email: email,
                                            password: "",
                                            password_confirmation: ""}}
  assert_not flash.empty?
  assert_redirected_to @user
  @user.reload
  assert_equal name, @user.name
  assert_equal email,@user.email  
  end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),params: {user: {name: name,
                                          email: email,
                                          password: "",
                                          password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "friendly forwarding only once" do
    get edit_user_path(@user)
    assert_equal edit_user_url(@user), session[:forwarding_url]

    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    delete logout_path
    log_in_as(@user)
    assert_redirected_to @user

  end

end