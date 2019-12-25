# todo: Bullet Proof against ramaze restart - store sessions on database?


class MainController < Ramaze::Controller
  
  #helpers
  include Wio::Helper::General
  helper :aspect
  
  layout :page
  
  before (:logout) do
    check_session
  end
  
  # the index action is called automatically when no other action is specified
  
  def index
    @sidebar = 'sidebar/login.xhtml'
    @title = "Welcome to Wio!"
    @login_form = create_form(User, {
      :action => '/login',
      :id     => 'login',
      :method => :post,
      :fields => [:username, :password],
      :submit => 'Login'
    })
      
    if session[:username].nil? and not session[:logged_in]
      @title = "Welcome to Wio!"
    else
      if session[:username] and session[:username] == 'admin'
        redirect '/admin'
      end
      redirect '/dashboard'
    end
  end
  
  def login
    username, password = request[:username, :password]
    if request.post? and check_auth(username, password)
      session[:logged_in] = true
      session[:username] = username

      if username == 'admin'
        redirect '/admin'
      end
      redirect '/dashboard'
      #@user_logged_in=true
    else
      redirect '/'
    end
  end
  
  def logout
    auser = User.get(session[:username])
    auser.logged_in = false
    auser.save
    session.clear
    redirect '/'
  end
  
  def register
    @title = "Register to Wio!"
    if request.post?
      if check_registration request
        login
      else
        @title = "There are some problems with your registration."
      end
    end
  end
  
  
  def search
    if request.post?
      @search_type = request[:search_type]
      @main_location = 'People'
      @sidebar = 'sidebar/search.xhtml'
      if @search_type == 'username'
        unless request[:username].empty?
          @username = request[:username]
          @title = 'Search Results for User: ' + @username
          @search_results = User.all(:username => @username)
        else
          # if username was empty...
          flash[:error] = 'Please input the username to start searching'
          redirect '/people'
        end
        
      elsif @search_type == 'name'
        if not request[:last_name].empty? and not request[:first_name].empty?
          @first_name = request[:first_name]
          @last_name = request[:last_name]
          @title = 'Search Results for User: ' + @first_name + ' ' + @last_name
          @search_results = User.all(:first_name => @first_name, :last_name => @last_name)
        else
          # if first name and last name lacks... or is completely empty
          flash[:error] = 'Please complete the first name and last name...'
          redirect '/people'
        end
        
      elsif @search_type == 'team'
        puts 'here'
        @main_location = 'Teams'
        @sidebar = 'sidebar/search_team.xhtml'
        if not request[:name].empty?
          @team_name = request[:name]
          @title = 'Search Results for Team: ' + @team_name
          @search_results = Team.all({:name => @team_name})
        else
          # if first name and last name lacks... or is completely empty
          flash[:error] = 'Please specify the team name...'
          redirect '/teams'
        end
      else
        # if the search type has been altered to a different value
        redirect '/'
      end
    else
      # if /search was accessed via the address bar
      redirect '/'
    end
  end  
  
  
  private 
  
  def check_auth user, pass
    if User.get(user).nil?
      if user.empty? or pass.empty?
        flash[:error] = 'Complete required fields'
        false
      else
        flash[:error] = 'User does not exist'
        false
      end
    else
      auser = User.get(user)
      if auser.password == pass
        if auser.banned == true
          flash[:error] = 'You are banned from WIO.'
          redirect '/'
        end
        auser.logged_in = true
        auser.save
        true
      else
        flash[:error] = 'Password is wrong'
        false
      end
    end
  end
  
  def check_registration request
    new_user = User.new({
      :username => request[:username],
      :email_address => request[:email_address],
      :password => request[:password],
      :password_confirmation => request[:password_confirmation],
      :mobile_number => request[:mobile_number]
    })
    unless new_user.save
      flash[:error] = new_user.errors.full_messages
      false
    else
      flash[:confirm] = "Your account has been created."
      flash[:error] = nil
      true
    end
  end  
end
