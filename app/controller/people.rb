class PeopleController < Ramaze::Controller
  
  layout '/page' #=> [ :index, :new ]
  map '/people'
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    @main_location = 'People'
    @me = User.get(session[:username])
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (username = nil, action = nil)
    @sidebar = 'sidebar/search.xhtml'
    @title = 'Wio People'
    # paginate(model, items_per_page, options={})
    # See 'helper/paginator.rb'
    @page = paginate(User, 10)
    @all_users = @page.data
    unless username.nil?
      if @user = User.get(username)
        @title = @user.username + '\'s Profile'
        @user_profile = @user
        @sidebar = 'sidebar/user_profile.xhtml'
        case action
          when 'add_contact'
            @action = 'add_contact'
            contact_requests = @me.sent_requests.all(:type => AddContactRequest)
            requested_contact = contact_requests.first(:user_username => @user.username, :accepted => false, :ignored => false)
            my_contact = @me.contacts.first(:username => @user.username)
            me_contact = @user.contacts.first(:username => @me.username)

            if requested_contact.nil? and my_contact.nil? and me_contact.nil?
              req = AddContactRequest.new(@me, @user)
              if req.save
                flash[:notice] = "A contact request has been sent to #{username.capitalize}."
                redirect_referer
              else
                flash[:error] = req.errors.full_messages
              end
            else
              flash[:error] = "A contact request has already been sent to #{@user.username}."
              redirect_referer
            end
          when 'send_message'
            @action = 'send_message'
            @title = 'Send a Message'
            send_message if request.post?
            
          when 'contacts'
            @action = 'contacts'
            @title = @user.username + '\'s Contacts'
            @user_contacts = @user.contacts.all
            
            if session[:username] and @user.username == @me.username
              redirect '/my_account/contacts'
            end
          when 'teams'
            @action = 'teams'
            @title = @user.username + '\'s Teams'
            @user_teams = @user.teams.all
            
            if session[:username] and @user.username == @me.username
              redirect '/my_account/teams'
            end
          when nil
            @action = 'view'
            if not session[:username].nil? and session[:username] == @user.username
              redirect '/my_account/'
            end
          else
            redirect '/people/'+u(@user.username)
        end
      else #if user specified doesn't exist
        redirect '/people'
      end
    end
  end
  
  private
  
  def send_message
    message = @me.messages.new({
      :subject=>request[:subject],
      :content=>request[:content]
    })
    
    message.sender = @me
    message.recipient = @user
    
    unless message.send_it
      flash[:error] = message.errors.full_messages
      false
    else
      flash[:confirm] = "The message has been sent to #{@user.username}."
      true
    end
    redirect '/my_account/messages'
  end
  
end
