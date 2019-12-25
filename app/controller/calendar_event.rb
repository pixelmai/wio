class CalendarEventController < Ramaze::Controller
  map '/my_account/calendar/events'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Calendar'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (id = nil, action = nil)
    @title = 'My Calendar Events'
    calendar = @me.calendar
    @sidebar = 'sidebar/calendar/add_event.xhtml'

    unless (@event = calendar.calendar_events.get(id)).nil?
      @title = 'event: ' + @event.name
      case action
        when 'edit'
          @title = 'Edit event - '+ @event.name
          @sidebar = 'sidebar/calendar/list_events.xhtml'
          @action = :edit
          
          if request.post?
            @event.name = request[:name]
            
            if_save = false
            
            if not request[:start_date_month].empty? and not request[:start_date_day].empty? and not request[:start_date_year].empty?
              @event.start_date = request[:start_date_month]+'/'+request[:start_date_day]+'/'+request[:start_date_year]
              if_save = true
            else
              if_save = false
              flash[:error] = "All the fields for start date must be set..."
            end 
            
            
            # NOTIFY
            if (request[:notify_month]=="") && (request[:notify_day]=="") && (request[:notify_year]=="") && (request[:notify_hour]=="") && (request[:notify_minute]=="")
              if_save = true
            elsif (not request[:notify_month]=="") && (not request[:notify_day]=="") && (not request[:notify_year]=="") && (not request[:notify_hour]=="") && (not request[:notify_minute]=="")

              unless @event.notification
                puts 'New notification...'
                @event.set_notification(
                  Notification.new(
                    :message => @event.name, 
                    :mode => :cellphone,
                    :recipient_user => @me, 
                    :when => DateTime.new(
                      request[:notify_year].to_i,
                      request[:notify_month].to_i,
                      request[:notify_day].to_i,
                      request[:notify_hour].to_i,
                      request[:notify_minute].to_i
                    ),
                    :sent => false
                  )
                )
                
                
              else
                puts 'It already has a notification...'
                @new_notification_date = DateTime.new(
                  request[:notify_year].to_i,
                  request[:notify_month].to_i,
                  request[:notify_day].to_i,
                  request[:notify_hour].to_i,
                  request[:notify_minute].to_i
                )
              end
              if_save = true
            elsif (
                  request[:notify_month].empty?  &&
                  request[:notify_day].empty?  &&
                  request[:notify_year].empty? &&
                  request[:notify_hour].empty? &&
                  request[:notify_minute].empty?
                )
              if_save = true
            else
              flash[:error] = "All the fields must be set for notification..."
              redirect '/my_account/tasks/'+u(@event.task_id)+'/edit'
            end
            
            
            
            
            if if_save
              unless @event.save
                flash[:error] = @event.errors.full_messages
                false
              else
                flash[:confirm] = "The event '#{@event.name}' has been updated."
                redirect '/my_account/calendar/'
                true
              end
            end
            
          end
        when 'delete'
          ename = @event.name
          unless @event.destroy
            flash[:error] = @event.errors.full_messages
            false
          else
            flash[:confirm] = "The event '#{ename}' has been deleted."
            redirect '/my_account/calendar/'
            true
          end
        when nil
          @action = 'view'
          @title = 'Event: ' + @event.name
        else
          redirect '/my_account/calendar/'
      end
      
    end
  end
  
end
