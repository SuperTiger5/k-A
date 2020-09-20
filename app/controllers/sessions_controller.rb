class SessionsController < ApplicationController
  before_action :not_relogin, only: :create
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      flash[:success] = "ログインしました。"
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_back_or user.admin? ? root_url : user
    else
      # レンダリングとflash.nowはset
      flash.now[:danger] = '認証に失敗しました。' 
      render :new
    end
  end
  
  def destroy
    log_out if logged_in?
    flash[:success] = "ログアウトしました。"
    redirect_to root_url
  end
  
  private
    
    def not_relogin
      if logged_in?
        flash[:info] = "すでにログインしています。"
        redirect_to current_user
      end
    end
end
