module SessionsHelper
  
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # 永続的セッションを記憶します
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 永続的セッションを破棄します
  def forget(user)
    user.forget 
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # セッションと@current_userを破棄します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 一時的セッションにいるユーザーを返します。
  # それ以外の場合はcookiesに対応するユーザーを返します。
  # 現在ログイン中のユーザー」
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        login user
        @current_user = user
      end
    end
  end
  
  #ログインチェック
  def logged_in?
    !current_user.nil?
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def redirect_back_or(default_url)
    redirect_to(session[:fowarding_url] || default_url)
    session.delete(:fowarding_url)
  end
  
  def store_location
    session[:fowarding_url] = request.original_url if request.get?
  end
end
