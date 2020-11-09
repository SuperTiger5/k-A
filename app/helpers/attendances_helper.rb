module AttendancesHelper
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return "出社" if attendance.started_at.nil?
      return "退社" if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  def sunday_or_saturday_color(x)
    css_class = 
          case $days_of_the_week[x.worked_on.wday]
            when '土'
              'text-primary'
            when '日'
              'text-danger'
          end
    return css_class
  end
  
  def overtime_approval_attendances_invalid?
    a = true
      overtime_notice_params.each do |id, item|
        if item[:overtime_change] == "1" && item[:overtime_check].in?(["承認", "否認"])
          next
        else
          a = false
          break
        end
      end
      return a
  end
  
  # まとめ更新のときにはtime_selectよりtime_field
  # if item[:note]と if item[:note].present?は別
  def one_month_request_invalid?
    a = true
    b = 0
    one_month_request_params.each do |id, item|
      if item[:next_day_one_month] == "0"
        if item[:started_at_temporary].blank? && item[:finished_at_temporary].blank? && item[:note_temporary].blank? && item[:one_month_superior_confirmation].blank?
          next
        elsif item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
          if format_basic_info(item[:started_at_temporary].in_time_zone).to_f < format_basic_info(item[:finished_at_temporary].in_time_zone).to_f
            b += 1
            next
          else
            b += 1
            a = false
            break
          end
        else #空白
          b += 1
          a = false
          break
        end
      elsif item[:next_day_one_month] == "1"
        if item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
          if format_basic_info(item[:started_at_temporary].in_time_zone).to_f > format_basic_info(item[:finished_at_temporary].in_time_zone).to_f
            b += 1
            next
          else
            b += 1
            a = false
            break
          end
        else
          b += 1
          a = false
          break
        end
      end
    end
    if b == 0
      a = false
    end
    return a
  end
  
   def one_month_request_flash
    b = 0
    one_month_request_params.each do |id, item|
      if item[:next_day_one_month] == "0"
        if item[:started_at_temporary].blank? && item[:finished_at_temporary].blank? && item[:note_temporary].blank? && item[:one_month_superior_confirmation].blank?
          next
        elsif item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
          if format_basic_info(item[:started_at_temporary].in_time_zone).to_f < format_basic_info(item[:finished_at_temporary].in_time_zone).to_f
            b += 1
            next
          else
            b += 1
            flash[:danger] = "出社時刻が退社時刻より遅い申請があります。(出勤時間、退勤時間は15分刻みに自動変換されます。例えば出勤時間9:45→9:45、9:46→10:00、退勤時間18:45→18:45、18:46→18:45)"
            break
          end
        else #空白
          b += 1
          flash[:danger] = "未入力の項目があります。"
          break
        end
      elsif item[:next_day_one_month] == "1"
        if item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
          if format_basic_info(item[:started_at_temporary].in_time_zone).to_f > format_basic_info(item[:finished_at_temporary].in_time_zone).to_f
            b += 1
            next
          else
            b += 1
            flash[:danger] = "翌日にチェックありで、出社時刻が退社時刻より早い申請があります。(出勤時間、退勤時間は15分刻みに自動変換されます。例えば出勤時間9:45→9:45、9:46→10:00、退勤時間18:45→18:45、18:46→18:45)"
            break
          end
        else
          b += 1
          flash[:danger] = "未入力の項目があります。"
          break
        end
      end
    end
    if b == 0
      flash[:danger] = "全ての申請が未入力になってます。"
    end
  end
  
  def one_month_notice_valid?
    a = true
    one_month_notice_params.each do |id, item|
      if item[:one_month_check].in?(["承認", "否認"]) && item[:one_month_change] == "1"
        next
      else
        a = false
        break
      end
    end
    return a
  end
 
  def final_one_month_request_invalid?
    final_one_month_request_params
    if params[:attendance][:final_one_month_superior_confirmation].present?
      a = true
    else
      a = false
    end
    return a
  end
  
  def final_one_month_notice_invalid?
    final_one_month_notice_params.each do |id, item|
      a = true
      if item[:final_one_month_check].in?(["承認", "否認"]) && item[:final_one_month_change] == "1"
        next
      else
        a = false
        break
      end
      return a
    end
  end
end