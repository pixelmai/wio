class ContactController < Ramaze::Controller
  map '/my_account/contacts'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @main_location = 'Dashboard'
    @me = User.get(session[:username])
    @sub_location = 'Contacts'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (contact = nil, action = nil)
    @where = 'contact'
    @title = 'My Contacts'
    @sidebar = 'sidebar/find_people.xhtml'
    if (c = @me.contacted_users.first({:user_username=>contact}) || @me.contacted_users.first({:contact_username=>contact}))
      @contact = c.contact
    end
    if @contact
      @title = 'Contact: ' + @contact.username
      case action
        
        when 'delete'
          cname = @contact.username
          @me.contacts.delete @contact
          unless @me.save
            flash[:error] = @me.errors.full_messages
            false
          else
            flash[:confirm] = "The contact '#{cname}' has been deleted."
            redirect_referer
            true
          end
        when nil
          redirect R(PeopleController, {:contact => @contact.username})
        else
          redirect_referer
      end
      
    end
  end
  
end
