class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include UsersHelper
  include AttendancesHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def logged_in_user
    unless logged_in?
      store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
    end
  end
  
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = 
    params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    $first_day = @first_day
    @last_day = @first_day.end_of_month
    $last_day = @last_day
    one_month = [*@first_day..@last_day]
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。<br>"
    redirect_to root_url
  end
end
