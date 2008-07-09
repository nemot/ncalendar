class NcalendarStyleGenerator < Rails::Generator::Base

  
  def manifest
    record  do |m|  
      m.directory "public/images/ncalendar/"
      m.file 'ncalendar.css', 'public/stylesheets/ncalendar.css'
      m.file 'ncalendar.js', 'public/javascripts/ncalendar.js'
      m.file 'left.gif', "public/images/ncalendar/left.gif"
      m.file 'right.gif', "public/images/ncalendar/right.gif"
      m.file 'yui/yahoo-dom-event.js', "public/javascripts/yahoo-dom-event.js"
      m.file 'yui/container_core-min.js', "public/javascripts/container_core-min.js"
      m.file 'yui/menu-min.js', "public/javascripts/menu-min.js"
    end
  end
  
end