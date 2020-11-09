module UsersHelper
  
  def format_2f(x)
    format("%.2f", x)
  end
   # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  
   #分
  def start_format_minute_quarter(time)
    if time.min != 0
      m = time.min - 1
      n = (m / 15 + 1) * 15
      if n == 60
        format("%.i", "0")
      else
        format("%.i", n)
      end
    else
      format("%.i", "0")
    end
  end
  
  def start_time_by_quarter(time)
   if time.min >= 46
     h = time.hour + 1
   else
     h = time.hour
   end
    m = start_format_minute_quarter(time).to_i
    #hとmはどちらも整数
    return "#{h}:#{m}".in_time_zone
  end
  
  #15分刻み
  def finish_format_minute_quarter(time)
    format("%i", (time.min / 15) * 15)
  end
  
  #15分刻みの時間に変換
  def finish_time_by_quarter(time)
    h = time.hour
    m = finish_format_minute_quarter(time)
    return "#{h}:#{m}".in_time_zone
  end 
  
  def difference(finish, start)
    if format_basic_info(finish).to_f > format_basic_info(start).to_f
      format("%.2f", format_basic_info(finish).to_f - format_basic_info(start).to_f)
    else
      format("%.2f", 24 - (format_basic_info(start).to_f - format_basic_info(finish).to_f))
    end
  end
  
  def overtime_calculation(attendance, sc, de)
    result = if attendance.next_day == "0"
               format_basic_info(sc).to_f - format_basic_info(de).to_f
             else
               24 - format_basic_info(de).to_f + format_basic_info(sc).to_f
             end
    format("%.2f", result) 
  end
    
end
