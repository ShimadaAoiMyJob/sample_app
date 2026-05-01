ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  #ここは,いろんなtestで使える処理かくとこ
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include ApplicationHelper

  #テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  #テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
  
  class ActionDispatch::IntegrationTest 
  #integrationテストはセッション使えないからユーザーの動きに沿って定義
  #テストユーザとしてログインする
  def log_in_as(user,password: "password",remember_me: "1")
    post login_path, params: {session: { email: user.email,
                                        password: password,
                                        remember_me: remember_me}}
  end
    
  end

end
