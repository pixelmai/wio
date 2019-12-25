class CalendarController < Ramaze::Controller
  map '/my_account/calendar'
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
  
  def index (event = nil, action = nil)
    @sidebar = 'sidebar/calendar/add_event.xhtml'
    @title = 'My Calendar'
  end
  
end
