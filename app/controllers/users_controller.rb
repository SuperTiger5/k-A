require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :show_check, :destroy, :edit, :update, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:show, :show_check, :index, :destroy, :edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :show_check]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def index
    @users = User.all
  end

  
  def show
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count
    @superiors = User.where(superior: true).where.not(id: current_user)
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv($a)
      end
    end
  end
  
  def send_posts_csv(attendances)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom) do |csv|
      header = %w(日付 曜日 出社時間 退社時間 在社時間)
      csv << header

      attendances.each do |day|
        x = l(day.started_at, format: :time) if day.started_at.present?
        y = l(day.finished_at, format: :time) if day.finished_at.present?
        z = difference(day.finished_at, day.started_at) if day.finished_at.present? && day.finished_at.present?
        values = [l(day.worked_on, format: :short),
                  $days_of_the_week[day.worked_on.wday],
                  x,
                  y,
                  z
                  ]
        csv << values
      end

    end
    send_data(csv_data, filename: "1か月の勤怠.csv")
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を編集しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      if User.update_all(basic_time: @user.basic_time, basic_work_time: @user.basic_work_time)
        flash[:success] = "基本情報を更新しました。"
      else
        flash[:danger] = "基本情報を更新できませんでした"
      end
    else
      flash[:danger] = "基本情報の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    if params[:csv_file].blank?
      flash[:danger] = "インポートするCSVファイルを選択してください。"
      redirect_to users_url
    else
      num = User.import(params[:csv_file])
      if num > 0
        flash[:success] = "#{num.to_s}件のユーザー情報を追加/更新しました。"
        redirect_to users_url
      else
        flash[:danger] = "読み込みエラーが発生しました。"
        redirect_to users_url
      end
    end
  end

  def working_users
    attendances1 = Attendance.where(worked_on: Date.current)
    attendances2 = attendances1.where.not(started_at: nil)
    @attendances3 = attendances2.where(finished_at: nil).order(:id)
  end
  private
    
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time, :password)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :basic_work_time)
    end
    
end


