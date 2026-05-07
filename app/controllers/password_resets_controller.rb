class PasswordResetsController < ApplicationController

  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit,:update]
  before_action :check_expiration, only: [:edit,:update]

  def new #パスワードを再設定したい
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new" , status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
      if params[:user][:password].empty?
        @user.errors.add(:password, "can't be empty")
        #<%= f.password_field :password%> これでparams[:user][:password]に入る
        #から,新しく設定したパスワード.生のデータはDBに保存されてない
        #paramsはHTTPリクエストから送られてきたデータ
        render "edit",status: :unprocessable_entity

        #長さチェックはmodelでやってる
      elsif @user.update(user_params)#update(ActiveRecordに入ってる)が成功したらtrue
        @user.forget
        reset_session
        log_in @user
        @user.update_attribute(:reset_digest, nil)
        flash[:success] = "Password has been reset"
        redirect_to @user
      else #modelのinvalidに引っかかってupdateがufalseを返した時
        render "edit", status: :unprocessable_entity
      end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end


    def get_user
      @user = User.find_by(email: params[:email])
      #html.erbでhiddenタグを使ってparams[:email]の情報を送った
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
