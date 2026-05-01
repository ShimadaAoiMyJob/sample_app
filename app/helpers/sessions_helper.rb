module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    #セッション攻撃から保護するためにtokenをつくる
    session[:session_token] = user.session_token
  end

  #永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    user.remember #modelに書いた処理を呼び出している
    cookies.permanent.encrypted[:user_id] = user.id #
    cookies.permanent[:remember_token] = user.remember_token
    
  end

  #記憶トークンcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id]) #sessionのなかにuser_idが存在するか
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end

    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token) #remember_tokenを消してる
  end

  def log_out
    forget(current_user) #このcurrent_userはメソッドdef current_userの帰り値
    reset_session
    @current_user = nil
  end
end
