class AttendancesController < ApplicationController
  include AttendancesHelper
  
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :set_user_in_attendance, only: [:edit_overtime_request, :update_overtime_request, :edit_overtime_notice, :update_overtime_request]
  before_action :set_one_attendance, only: [:edit_overtime_request, :update_overtime_request]
  before_action :logged_in_user
  before_action :only_superior, only:[:edit_overtime_notice, :update_overtime_notice]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "おつかれさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      if overtime_attendances_invalid?
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_overtime_request
    @superiors = User.where(superior: true).where.not(id: @user)
  end

  def update_overtime_request
    if params[:attendance][:overtime_superior_confirmation].blank?
      flash[:danger] = "指示者確認㊞を選択してください。"
    elsif params[:attendance][:work_details].blank?
      flash[:danger] = "業務処理内容を入力してください。"
    else
      if @attendance.update_attributes!(overtime_params)
        @attendance.update_attributes!(overtime_status: "#{User.find(params[:attendance][:overtime_superior_confirmation]).name}に残業申請中です。",
                                      overtime_request: "1")
        flash[:success] = "残業申請しました。"
      end
    end
    redirect_to @user
  end
  
  def edit_overtime_notice
    @attendances = Attendance.where(overtime_request: "1", overtime_superior_confirmation: current_user.id)
  end
  
  def update_overtime_notice
    ActiveRecord::Base.transaction do 
      if overtime_attendances_invalid?
      overtime_notice_params.each do |id, item|
        if item[:overtime_change] == "1"
          if item[:overtime_check].in?(["承認", "否認"])
            day = Attendance.find(id)
            if item[:overtime_check] == "承認"
              day.update_attributes!(item)
              day.update_attributes!(overtime_approval: "1", overtime_request: nil,
                                    overtime_status: "#{current_user.name}から残業が承認されました。")
            elsif item[:overtime_check] == "否認"
              day.update_attributes!(item)
              day.update_attributes!(overtime_approval: "2", overtime_request: nil,
                                    overtime_status: "#{current_user.name}から残業が否認されました。")
            end
          end
        end
        flash[:success] = "残業申請を更新しました。(但しチェックがない場合と指示者確認でなしにされた場合は更新されません。)"
      end
      else
        flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
      end
      redirect_to current_user and return
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
      redirect_to current_user and return
  end
  private
  
    def set_user_in_attendance
      @user = User.find(params[:user_id])
    end
    
    def set_one_attendance
      @attendance = @user.attendances.find(params[:id])
    end
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :work_details, :overtime_superior_confirmation)
    end
    
    def overtime_notice_params
      params.require(:user).permit(attendances: [:overtime_check, :overtime_change])[:attendances]
    end
    
    def only_superior
      unless @current_user.superior?
        redirect_to root_url
      end
    end

end