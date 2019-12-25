class RequestController < Ramaze::Controller
  map '/my_account/requests'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @main_location = 'Dashboard'
    @me = User.get(session[:username])
    @sub_location = 'Requests'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (req = nil, action = nil)
    @sidebar = 'sidebar/find_people.xhtml'
    @where = 'request'
    @title = 'My Pending Requests'
    unless (@request = @me.requests.first({:request_id=>req})).nil?
      @title = 'Request: ' + @request.class.to_s
      case action
        
        when 'delete'
          @me.requests.delete @request
          unless @me.save
            flash[:error] = @me.errors.full_messages
            false
          else
            flash[:confirm] = "The request has been deleted."
            redirect '/my_account/requests/'
            true
          end
        when 'accept'
          @request.accept
          flash[:confirm] = @request.message_accept_html
          redirect '/my_account/requests'
        when 'ignore'
          @request.ignore
          flash[:confirm] = @request.message_ignore_html
          redirect '/my_account/requests'
        when nil
          redirect R(MyAccountController, :requests)
        else
          redirect '/my_account/requests/'
      end
      
    end
  end
  
end
