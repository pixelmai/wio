class DashboardController < Ramaze::Controller
  
  layout '/page' #=> [ :index, :new ]
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    @main_location = 'Dashboard'
    @sub_location = 'Home'
    check_session
  end
  
  def index
    @where = 'dashboard'
    @date = DateTime.now
    @sidebar = 'sidebar/dashboard.xhtml'
    @js_include = '/js/dashboard.js'
    @me = User.get(session[:username])
    #@title = "Hello " + session[:username] + "! You are logged in!"
    @title = "My Dashboard"
    @logged_in_users = User.all(:logged_in.eql => true);
  end
end
