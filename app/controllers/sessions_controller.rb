class SessionsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user &.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session #セキュリティ
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user) #チェックボックスの処理
      log_in @user
      redirect_to @user 
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
