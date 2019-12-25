class AdminController < Ramaze::Controller
  map '/admin'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_admin_session
    @main_location = 'Admin Panel'
    @sidebar = 'admin/statistics.xhtml'
    @me = User.get(session[:username])
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index
    @title = 'Administrator Panel'
    @sub_location = 'Home'
  end
  
  def people(username = nil, action = nil)
    @title = 'Admin: Manage Users of WIO'
    @sub_location = 'People'
    @page = paginate(User, 10)
    @all_users = @page.data
    
    if username
      if username == 'admin'
        redirect '/admin/people'
      end
      user = User.get(username)
      @user = user
      if not user.nil?
        if action
          case action
            when 'ban'
              user.banned = true
              user.save
              flash[:notice] = 'You have banned ' + user.username
              redirect '/admin/people'
            when 'un_ban'
              user.banned = false
              user.save
              flash[:confirm] = 'You have un-banned ' + user.username
              redirect '/admin/people'
            when 'send_notice'
              @action = 'send_notice'
              @title = 'Send a Notice'
              send_message if request.post?
            else
              redirect '/admin/people'
          end
        end
      else
        flash[:error] = 'User does not exist.'
        redirect '/admin/people'
      end
    end
  end
  
  def teams(team = nil, action = nil)
    @title = 'Admin: Manage Teams of WIO'
    @sub_location = 'Teams'
    @page = paginate(Team, 10)
    @all_teams = @page.data
    
    if team
      t = Team.get(team)
      if not t.nil?
        if action
          case action
            when 'delete'
              tname = t.name  
              unless t.destroy
                flash[:error] = t.errors.full_messages
                false
              else
                flash[:confirm] = "The team '#{tname}' has been deleted."
                redirect '/admin/teams'
                true
              end
            else
              redirect '/admin/teams'
          end
        end
      else
        flash[:error] = 'Team does not exist.'
        redirect '/admin/teams'
      end
    end
  end
  
  
  private
  
  def send_message
    message = @me.messages.new({
      :subject=>request[:subject],
      :content=>request[:content],
      :notice => true
    })
    
    message.sender = @me
    message.recipient = @user
    
    unless message.send_it
      flash[:error] = message.errors.full_messages
      false
    else
      flash[:confirm] = "The notice has been sent to #{@user.username}."
      true
    end
    redirect '/admin/people'
  end
end
