class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :set_user_in_attendance, only: [:update, :edit_overtime_request, :update_overtime_request,
                                                :edit_overtime_notice, :update_overtime_request,
                                                :edit_one_month_request, :update_one_month_request]
  before_action :set_one_attendance, only: [:edit_overtime_request, :update_overtime_request]
  before_action :logged_in_user
  before_action :only_superior, only:[:edit_overtime_notice, :update_overtime_notice]
  before_action :set_one_month, only: :edit_one_month_request
  
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
  
  def edit_one_month_request
    @superiors = User.where(superior: true).where.not(id: current_user)
  end
  
  def update_one_month_request
    ActiveRecord::Base.transaction do
      if one_month_invalid?
        edit_one_month_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(edit_one_month_request: "1")
        end
        flash[:success] = "勤怠変更申請を送信しました" 
        redirect_to current_user
      else
        flash[:danger] = "無効な入力データがあった為、送信をキャンセルしました。"
        redirect_to edit_one_month_request_user_attendances_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to edit_one_month_request_user_attendances_url(date: params[:date])
  end
  
  def edit_overtime_request
    @superiors = User.where(superior: true).where.not(id: @user)
  end

  def update_overtime_request
    if params[:attendance][:overtime_superior_confirmation].blank?
      flash[:danger] = "指示者確認㊞を選択してください。"
    elsif params[:attendance][:work_details_temporary].blank?
      flash[:danger] = "業務処理内容を入力してください。"
    else
      if @attendance.update_attributes!(overtime_params)
        @attendance.update_attributes!(overtime_status: "#{User.find(params[:attendance][:overtime_superior_confirmation]).name}に残業申請中です。",
                                      overtime_request: "1", 
                                      overtime_approval: nil,
                                      scheduled_end_time: nil,
                                      work_details: nil)
        flash[:success] = "残業申請しました。"
      end
    end
    redirect_to current_user
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
              user = User.find(day.user_id)
              if item[:overtime_check] == "承認" 
                if scheduled_end_time_invalid?(day.scheduled_end_time_temporary, user.designated_work_end_time, user.designated_work_start_time, user, day)
                  day.update_attributes!(overtime_approval: "1", 
                                         overtime_request: nil, 
                                         overtime_superior_confirmation: nil,
                                         scheduled_end_time: day.scheduled_end_time_temporary,
                                         scheduled_end_time_temporary: nil,
                                         work_details: day.work_details_temporary,
                                         overtime_status: "#{current_user.name}から残業が承認されました。")
                else
                  flash[:danger] = "残業申請の時間がおかしいです。指示者確認を否認にチェックしてください。"
                  redirect_to current_user and return
                end
              elsif item[:overtime_check] == "否認"
                day.update_attributes!(item)
                day.update_attributes!(overtime_approval: "2",
                                       overtime_request: nil, 
                                       overtime_superior_confirmation: nil,
                                       next_day: nil,
                                       scheduled_end_time_temporary: nil,
                                       work_details_temporary: nil,
                                       overtime_status: "#{current_user.name}から残業が否認されました。")
              end
            end
          end
        flash[:success] = "残業申請を更新しました。"
      end
      else
        flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。(チェックがない場合と指示者確認で申請中、またはなしにされた場合は更新されません。)"
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
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time_temporary, :next_day, :work_details_temporary, :overtime_superior_confirmation)
    end
    
    def overtime_notice_params
      params.require(:user).permit(attendances: [:overtime_check, :overtime_change])[:attendances]
    end
    
    def edit_one_month_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :one_month_superior_confirmation, :next_day_one_month])[:attendances]
    end
    
    def only_superior
      unless current_user.superior?
        redirect_to root_url
      end
    end

end