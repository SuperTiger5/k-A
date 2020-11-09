class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :set_user_in_attendance, only: [:update, :edit_overtime_request, :update_overtime_request, :d,
                                                :edit_overtime_notice, :update_overtime_request,
                                                :edit_one_month_request, :update_one_month_request,
                                                :edit_one_month_notice, :update_one_month_notice]
  before_action :set_one_attendance, only: [:edit_overtime_request, :update_overtime_request]
  before_action :logged_in_user
  before_action :only_superior, only: [:edit_overtime_notice, :update_overtime_notice, :update_one_month_notice]
  before_action :set_one_month, only: :edit_one_month_request
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  def d
    @attendance = Attendance.find(params[:id])
    @attendance.update_attributes!(started_at: nil, finished_at: nil)
    redirect_to current_user
  end
  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: start_time_by_quarter(Time.current))
        flash[:info] = "おはようございます。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: finish_time_by_quarter(Time.current))
        flash[:info] = "おつかれさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_overtime_request
    @superiors = User.where(superior: true).where.not(id: current_user)
  end

  def update_overtime_request
    overtime_request_params
    if params[:attendance][:scheduled_end_time_temporary].present? && params[:attendance][:work_details_temporary].present? && params[:attendance][:overtime_superior_confirmation].present?
      superior = User.find(params[:attendance][:overtime_superior_confirmation])
      if params[:attendance][:next_day] == "0"
        if format_basic_info(finish_time_by_quarter(params[:attendance][:scheduled_end_time_temporary].in_time_zone)).to_f > format_basic_info(current_user.designated_work_end_time).to_f
          @attendance.update_attributes!(overtime_request_params)
          @attendance.update_attributes(overtime_status: "#{superior.name}に残業申請中",
                                       scheduled_end_time_temporary: finish_time_by_quarter(@attendance.scheduled_end_time_temporary),
                                       overtime_request: "1"
                                      )
          flash[:success] = "残業申請しました。"
        else
          flash[:danger] = "終了予定時間が指定勤務終了時間を越えてません。(終了予定時間は15分刻みです。例えば18:33→18:30に自動変換)"
        end
      else
        if format_basic_info(finish_time_by_quarter(params[:attendance][:scheduled_end_time_temporary].in_time_zone)).to_f < format_basic_info(current_user.designated_work_start_time).to_f 
          @attendance.update_attributes!(overtime_request_params)
          @attendance.update_attributes(overtime_status: "#{superior.name}に残業申請中",
                                       scheduled_end_time_temporary: finish_time_by_quarter(@attendance.scheduled_end_time_temporary),
                                       overtime_request: "1"
                                      )
          flash[:success] = "残業申請しました。"
        else
          flash[:danger] = "翌日にチェックをした状態で、終了予定時間が翌日の指定勤務開始時間以降になってます。(終了予定時間は15分刻みです。例えば18:33→18:30に自動変換)"
        end
      end
    else 
      flash[:danger] = "未入力の項目があります。"
    end
    redirect_to user_url(current_user,date: @attendance.worked_on.beginning_of_month)
  end
 
  def edit_overtime_notice
    @attendances = Attendance.where(overtime_request: "1", overtime_superior_confirmation: current_user.id)
  end
  
  def update_overtime_notice
    ActiveRecord::Base.transaction do 
      if overtime_approval_attendances_invalid?
        overtime_notice_params.each do |id, item|
          attendance = Attendance.find(id)
          if item[:overtime_check] == "承認"
            attendance.update_attributes!(item)
            attendance.update_attributes!(scheduled_end_time: attendance.scheduled_end_time_temporary,
                                          work_details: attendance.work_details_temporary,
                                          work_details_temporary: nil,
                                          scheduled_end_time_temporary: nil,
                                          overtime_request: nil,
                                          overtime_result: attendance.overtime_result_temporary,
                                          overtime_result_temporary: nil,
                                          overtime_status: "#{current_user.name}に残業を承認された。")
          elsif item[:overtime_check] == "否認"
            attendance.update_attributes!(item)
            if attendance.scheduled_end_time.present?
              attendance.update_attributes!(scheduled_end_time_temporary: nil,
                                            work_details_temporary: nil,
                                            overtime_request: nil,
                                            overtime_result_temporary: nil,
                                            overtime_status: "#{current_user.name}に残業を否認された。(前回分は承認済み。)")
            else
              attendance.update_attributes!(scheduled_end_time_temporary: nil,
                                            work_details_temporary: nil,
                                            overtime_request: nil,
                                            overtime_result_temporary: nil,
                                            overtime_status: "#{current_user.name}に残業を否認されました。",
                                            )
            end
          end
        end
        flash[:success] = "残業申請を更新しました。"
        redirect_to current_user
      else
        flash[:danger] = "指示者確認㊞を承認か否認にしてください。また変更にチェックしてください。"
        redirect_to current_user
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to current_user
  end
  
  def edit_one_month_request
    @superiors = User.where(superior: true).where.not(id: current_user)
  end
  
  #まとめ更新のときにはtime_selectよりtime_field
  def update_one_month_request
    ActiveRecord::Base.transaction do
      if one_month_request_invalid?
        one_month_request_params.each do |id, item|
          if item[:one_month_superior_confirmation].present?
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
           attendance.update_attributes!(one_month_request: "1",
                                         one_month_status: "#{User.find(item[:one_month_superior_confirmation]).name}にへ勤怠変更申請中。",
                                         started_at_temporary: start_time_by_quarter(attendance.started_at_temporary),
                                         finished_at_temporary: finish_time_by_quarter(attendance.finished_at_temporary)
                                         )
          end
        end
        flash[:success] = "勤怠編集を送信しました。"
        redirect_to user_url(current_user, date: params[:date])
      else
        one_month_request_flash
        redirect_to edit_one_month_request_user_attendances_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to edit_one_month_request_user_attendances_url(date: params[:date])
  end
  
  def edit_one_month_notice
    @attendances = Attendance.where(one_month_request: "1", one_month_superior_confirmation: current_user)
  end
  
  def update_one_month_notice
    if one_month_notice_valid?
      one_month_notice_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:one_month_check] == "承認"
          attendance.update_attributes!(started_at: attendance.started_at_temporary,
                                        started_at_temporary: nil,
                                        finished_at: attendance.finished_at_temporary,
                                        finished_at_temporary: nil,
                                        note: attendance.note_temporary,
                                        note_temporary: nil,
                                        one_month_request: nil,
                                        one_month_superior_confirmation: nil,
                                        one_month_status: "#{current_user.name}が勤怠編集を承認しました。")
        elsif item[:one_month_check] == "否認"
          attendance.update_attributes!(started_at_temporary: nil,
                                        finished_at_temporary: nil,
                                        note_temporary: nil,
                                        one_month_request: nil,
                                        one_month_superior_confirmation: nil,
                                        one_month_status: "#{current_user.name}が勤怠編集を否認しました。")
        end
      end
      flash[:success] = "勤怠編集を更新しました。"
      redirect_to current_user
    else
      flash[:danger] = "指示者確認を承認または否認にしてください。または変更にチェックしてください。"
      redirect_to current_user
    end
  end
  
  def edit_final_one_month_request
    @superiors = User.where(superior: true).where.not(id: @user)
  end
  
  private
  
    def set_user_in_attendance
      @user = User.find(params[:user_id])
    end
    
    def set_one_attendance
      @attendance = @user.attendances.find(params[:id])
    end
    
    def overtime_request_params
      params.require(:attendance).permit(:scheduled_end_time_temporary, :next_day, :work_details_temporary, :overtime_superior_confirmation)
    end
    
    def overtime_notice_params
      params.require(:user).permit(attendances: [:overtime_check, :overtime_change])[:attendances]
    end
    
    def one_month_request_params
      params.require(:user).permit(attendances: [:started_at_temporary, :finished_at_temporary, :note_temporary, :one_month_superior_confirmation, :next_day_one_month])[:attendances]
    end
    
    def one_month_notice_params
      params.require(:user).permit(attendances: [:one_month_check, :one_month_change])[:attendances]
    end
    
    def only_superior
      unless current_user.superior?
        redirect_to root_url
      end
    end
    
    

end