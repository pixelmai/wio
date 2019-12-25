class MessagesController < Ramaze::Controller
  map '/my_account/messages'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect, :formatting
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Messages'
    @sidebar = 'sidebar/messages/mailboxes.xhtml'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index(message = nil, action = 'view')
    @title = 'My Messages'
    
    if message && message != 'sent'
      unless (@message = @me.messages.get(message))
        flash[:error] = "We could not find that message"
        redirect '/my_account/messages'
      end
      case action
        when 'view'
          @action = 'view'
        when 'reply'
          @action = 'reply'
      end
    elsif message == 'sent'
      @title = 'Sent Messages'
      @action = 'sent'
    else
      @title = 'Inbox'
      @action = 'inbox'
    end
  end
  
  
end
