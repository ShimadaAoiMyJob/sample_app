class SessionsController < ApplicationController

  def new
  end

  #session : サーバー側で持ってるログイン状態で, reset_sessionで消える
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user &.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      #これ def logged_inで実行されるから，editとかupdateとかに
      #アクセスした時以外はnilになる.
      
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session #セキュリティ.セッション新しくすると
      #forwarding_urlは消える.だから,forwarding_urlより後に書く
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user) #チェックボックスの処理
      log_in @user
      redirect_to forwarding_url || @user 
      #@user => remember_tokenをtestで読み込みたいから,ローカル変数以外の形にしてる
    else
      flash.now[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in? #current_user != nil 一回ログアウトすると, current_userがnilになる
    redirect_to root_url,status: :see_other
  end
end
