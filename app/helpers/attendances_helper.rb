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
    s = start.hour.to_f + format_minute_quarter(start).to_f / 60
    f = finish.hour.to_f + format_minute_quarter(finish).to_f / 60
    format("%.2f", f - s - 1)
  end
  
  def format_minute_quarter(time)
    format("%i", 15 * (time.min / 15))
  end
  
  def attendances_invalid?
    a = true
      attendances_params.each do |id, item|
        if item[:started_at].blank? && item[:finished_at].blank?
          next
        elsif item[:started_at].blank? || item[:finished_at].blank?
          a = false
          break
        end
      end
      return a
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
        overtime = "翌日の出勤時間以降までの残業は無効です。"
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
  
  def one_month_invalid?
    a = true
    edit_one_month_params.each do |id, item|
      if item[:started_at].present?
        next
      else
        a = false
        break
      end
    end
    return a
  end
  
end

  