module UsersHelper
  
   # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  
  # def overtime_basic(time)
  #   format("%.2f", time/3600)
  # end
  
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
end
