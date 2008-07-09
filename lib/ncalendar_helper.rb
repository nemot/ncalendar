# NcalendarHelper
require 'date'

# Allows to careate simple callendar
module NcalendarHelper
  
  def ncalendar(options={})
  	@@unique_id = 0-"letsWriteSomeText".object_id.to_i
    
    raise(ArgumentError, "No year given")  unless options.has_key?(:year)
    raise(ArgumentError, "No month given") unless options.has_key?(:month)
    
    defaults = {
      :month_switching=>false, 
      :month_switching_links=>{:next=>'/',:previous=>'/'},
      :show_year=>false,
      :dayly_events=>{},
      :weekly_events=>{},
      :monthly_events=>{},
      :yearly_events=>{},
      :show_today=>true,
      :today_date=>Date.today
    }
    @@calendar_id = "#{options[:year]}#{options[:month]}calendar";
    options = defaults.merge options
    
    first = Date.civil(options[:year], options[:month], 1)
    last = Date.civil(options[:year], options[:month], -1)
    
    first_weekday = 1
    last_weekday = 0
    
    cal = "
    			<link rel='stylesheet' type='text/css' href='/stylesheets/ncalendar.css' />
          <script type='text/javascript' src='/javascripts/yahoo-dom-event.js'></script>
          <script type='text/javascript' src='/javascripts/container_core-min.js'></script>
          <script type='text/javascript' src='/javascripts/menu-min.js'></script>\n"
    
    cal << %(<table cellspacing=0 cellpading=0 border=0 class='calendar' id='#{@@calendar_id}'>\n)
    cal << "<thead> <tr class='monthName'>\n"
    
    # Left month switch arrow
    cal << "<th colspan=2 > <a href='#{options[:month_switching_links][:previous]}'><img src='/images/ncalendar/left.gif' border='0'></a> </th>\n" if options[:month_switching]
    
    # Month name
    cal << "<th colspan=#{options[:month_switching] ? 3 : 7}>"
    event_actions = events_on "#{options[:year]}-#{options[:month]}-01".to_date, options[:monthly_events]
		
    cal << "<span #{event_actions[:event]||=(options[:dayly_events].empty? ? ' class="hasNoReport"' : '')} >#{Date::MONTHNAMES[options[:month]]}</span>#{event_actions[:div]}"
    # Year if required
    event_actions = events_on "#{options[:year]}-01-01".to_date, options[:yearly_events]
    cal << ", <span #{event_actions[:event]}>"+options[:year].to_s+"</span>#{event_actions[:div]}" if options[:show_year]
    
    cal << "</th>#{event_actions[:div]}\n"
    
    # Right month switch arrow
    cal << "<th colspan=2> <a href='#{options[:month_switching_links][:next]}'><img src='/images/ncalendar/right.gif' border='0'></a> </th>\n" if options[:month_switching]
    
    # Day of week names
    cal << "</th></tr><tr class='dayName'>\n"
    
    Date::DAYNAMES.each { |day|
      cal << "<th>#{day[0..2]}</th>\n"
    }
    
    cal << "</tr></thead>\n"
    cal << "<tbody>\n"
    
    
    # Full or not full week of this month
#     (first-1)-beginning_of_week(first, first_weekday)>0 ? tr_class='mixedWeek' : tr_class='thisWeek'
    event_actions = events_on beginning_of_week(first, first_weekday), options[:weekly_events]
    cal << "<tr #{event_actions[:event]||=(options[:dayly_events].empty? ? ' class="hasNoReport"' : '')} > #{event_actions[:div]}\n" 
    
    # Previous month days
    beginning_of_week(first, first_weekday).upto(first-1) { |pre_month_date|
      cal << "<td class='otherMonth'>#{pre_month_date.day}</td>\n"
    }
    
    # Now month days
    first.upto(last) { |curr|
      
      if curr.wday == first_weekday
        event_actions = events_on curr, options[:weekly_events]
        cal << "<tr #{event_actions[:event]||=(options[:dayly_events].empty? ? ' class="hasNoReport"' : '')}>#{event_actions[:div]}\n"
      end
      
      # Today or no?
      ((curr==options[:today_date].to_date) and (options[:show_today])) ? td_classes='today' : td_classes=''
      
      # Weekend or no?
      (td_classes||='') << " weekEnd" if [0,6].include? curr.wday
      
      # Watching dayly events
      event_actions = events_on curr,  options[:dayly_events], td_classes, 'dayly'
      cal << "<td #{event_actions[:event]} #{"class='"+td_classes +"'"unless td_classes==''}>#{curr.day}</td>#{event_actions[:div]}\n"
      
      cal << "</tr>\n" if curr.wday == last_weekday
    }
    
    # Next month days
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1) { |next_month_date|
      cal << "<td class='otherMonth'>#{next_month_date.day}</td>\n"
    }
    
    
    cal << "</tr></tbody></table>\n"
    cal
  end
  
  private
  
  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end
  
  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end
  
  # Watching dayly events
  def events_on(curr, events, ex_classes='', type='weekly')
    unless events[curr].nil?
	
					unless type=='dayly'
        		(event||='') << " class='hasReport #{ex_classes}' onmouseover=\"this.className='hasReportOver'\" onmouseout=\"this.className='hasReport'\"" 
        	else
        		(event||='') << " style='cursor: pointer;'"
        	end
        
        
        # Edit, Delete, Show
        if !events[curr][:edit].nil? or !events[curr][:delete].nil?
          (div||='') << "<div id='calendar_#{curr.strftime("%Y%m%d")}_control_#{@@unique_id}' style=' position: absolute; visibility: hidden;' class='yuimenu'><div class='bd'><ul class='first-of-type'>\n"
          
          div << "<li class='yuimenuitem'> <a class='yuimenuitemlabel' href='#{events[curr][:show]}'> Download </a> </li>\n" unless events[curr][:show].nil?
          
          div << "<li class='yuimenuitem'> <a class='yuimenuitemlabel' href='#{events[curr][:edit]}'> Edit </a> </li>\n" unless events[curr][:edit].nil?
          
          div << "<li class='yuimenuitem'>"+link_to("Delete",events[curr][:delete],:method=>'delete', :class=>'yuimenuitemlabel', :confirm=>'Are you shure?')+"</li>\n" unless events[curr][:delete].nil?
          
          div << "</ul></div></div>\n"
          
          div << "<script>YAHOO.util.Event.onContentReady('calendar_#{curr.strftime("%Y%m%d")}_control_#{@@unique_id}', function () {
            $('calendar_#{curr.strftime("%Y%m%d")}_btn_#{@@unique_id}').absolutize;
            pos = $('#{@@calendar_id}').cumulativeOffset();
            btn_pos = $('calendar_#{curr.strftime("%Y%m%d")}_btn_#{@@unique_id}').cumulativeOffset();
            tob = $('#{@@calendar_id}').getDimensions();
            var oMenu = new YAHOO.widget.Menu('calendar_#{curr.strftime("%Y%m%d")}_control_#{@@unique_id}', { position: 'dinamic', x:pos[0]-0+tob.width, y:btn_pos[1]});
            oMenu.render();
            oMenu.subscribe('show', oMenu.focus);
            YAHOO.util.Event.addListener('calendar_#{curr.strftime("%Y%m%d")}_btn_#{@@unique_id}', 'click', oMenu.show, null, oMenu);
            });</script>"


          (event||='') << " id='calendar_#{curr.strftime("%Y%m%d")}_btn_#{@@unique_id}' "
        else # Show 
          (event||='') << %( onclick="window.location='#{events[curr][:show]}'" ) unless events[curr][:show].nil?
        end
    end
    return {:event=>event,:div=>div}
  end
  
end