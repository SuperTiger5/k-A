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
  
  def working_times(start, finish)
    x = format_hour_quarter_start(start).to_f
    s = x + format_minute_quarter_start(start).to_f / 60
    f = finish.hour.to_f + format_minute_quarter_finish(finish).to_f / 60
    format("%.2f", f - s - 1)
  end
  
  def time_spent_at_work(start, finish)
    x = format_hour_quarter_start(start).to_f
    s = x + format_minute_quarter_start(start).to_f / 60
    f = finish.hour.to_f + format_minute_quarter_finish(finish).to_f / 60
    format("%.2f", f - s)
  end
  
  def format_hour_quarter_start(time)
    if format_minute_quarter_start(time) == "60"
      format("%i", time.hour + 1)
    else
      format("%i", time.hour)
    end
  end
  
  def format_minute_quarter_start(time)
    if time.min / 15 + 1 == 4
      return "0"
    else
      format("%i", 15 * (time.min / 15 + 1))
    end
  end
  
  def format_minute_quarter_finish(time)
    format("%i", 15 * (time.min / 15))
  end
  
  def scheduled_end_time_invalid?(sc, dend, dstart, user, day)
    if day.next_day == "0" 
      overtime = format_basic_info(sc).to_f - format_basic_info(dend).to_f
      if overtime > 0
        return true
      else
        return false
      end
    else
      if format_basic_info(sc).to_f < format_basic_info(dstart).to_f
        overtime = 24 - format_basic_info(dend).to_f + format_basic_info(sc).to_f
        return true
      else
        return false
      end
    end
  end
  
  def overtime_status(sc, dend, dstart, user, day)
    if day.next_day == "0"
      overtime = format_basic_info(sc).to_f - format_basic_info(dend).to_f
      if overtime > 0
        return format("%.2f", overtime)
      else
        overtime = "終了予定時間が定時を越えてません。"
        return overtime
      end
    else
      if format_basic_info(sc).to_f < format_basic_info(dstart).to_f
        overtime = 24 - format_basic_info(dend).to_f + format_basic_info(sc).to_f
        return format("%.2f", overtime)
      else
        overtime = "残業時間が翌日の出勤時間を越してます。"
        return overtime
      end
    end
  end
  
  def overtime_attendances_invalid?
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
  
  #まとめ更新のときにはtime_selectよりtime_field
  #if item[:note]と if item[:note].present?は別
  def one_month_invalid?
    a = true
    edit_one_month_params.each do |id, item|
      if item[:next_day_one_month] == "0"
        if item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
            if item[:started_at_temporary] < item[:finished_at_temporary]
              next
            else
              a = false
            end
        elsif item[:started_at_temporary].blank? && item[:finished_at_temporary].blank? && item[:note_temporary].blank? && item[:one_month_superior_confirmation].blank?
          next
        else
          a = false
          break
        end
      else
        if item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
          if item[:finished_at_temporary] < item[:started_at_temporary]
            next
          else
            a = false
            break
          end
        else
          a = false
          break
        end
      end
    end
    return a
  end
  
  def one_month_blank_column
    edit_one_month_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:next_day_one_month] == "0"
        if item[:started_at_temporary].blank? && item[:finished_at_temporary].blank? && item[:note_temporary].blank? && item[:one_month_superior_confirmation].blank?
            next
        elsif item[:started_at_temporary].present? && item[:finished_at_temporary].present? && item[:note_temporary].present? && item[:one_month_superior_confirmation].present?
            attendance.update_attributes!(item)
            attendance.update_attributes!(edit_one_month_request: "1",
                                          one_month_status: "#{User.find(item[:one_month_superior_confirmation]).name}に勤怠編集申請中。"
                                          )
        end
      else
            attendance.update_attributes!(item)
            attendance.update_attributes!(edit_one_month_request: "1",
                                          one_month_status: "#{User.find(item[:one_month_superior_confirmation]).name}に勤怠編集申請中。"
                                          )
      end
    end
  end
  
  def one_month_notice_valid?
    a = true
    one_month_notice_params.each do |id, item|
      if item[:one_month_check] == "承認" && item[:one_month_change] == "1"
        next
      elsif item[:one_month_check] == "否認" && item[:one_month_change] == "1"
        next
      else
        a = false
        break
      end
    end
    return a
  end
  
end