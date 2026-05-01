#sessionsHelperをテストする個別のテストファイル

require "test_helper"

class SessionsHelperTest < ActionView::TestCase
  #テストは, その層に対応するメソッドは使える
  #helper用のてすとだからhelperにあるメソッドは使える
  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest,User.digest(User.new_token))
    assert_nil current_user
  end
end