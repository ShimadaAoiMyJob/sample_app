class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    #debugger書くと処理が一時止まる
  end
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save#保存の成功
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render "new",status: :unprocessable_entity
      #render : この画面(ビュー)を表示する
      #users/new.html.erbを表示
    end
  end
  
  private
    
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end
end
