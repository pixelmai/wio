class TeamController < Ramaze::Controller
  map '/my_account/teams'
  layout '/page' #=> [ :index, :new ]  

  include Wio::Helper::General
  helper :aspect, :formatting
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Teams'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (team = nil, action = nil, invite_username = nil)
    @sidebar = 'sidebar/teams/add_team.xhtml'
    @where = 'team'
    @title = 'My Teams'
    unless (@team = @me.teams.first({:name=>team})).nil?
      @title = 'Team: ' + @team.name
      case action
               
        when 'edit'
          @sidebar = 'sidebar/teams/team_sidebar.xhtml'
          @title = 'Edit team - '+ @team.name
          @action = :edit
          if (@team.team_lead != @me)
            flash[:error] = 'Sorry. You cannot edit other people\'s team'
            redirect '/teams/' + u(@team.name)
          end
          
          if request.post?
            @team.description = request[:description]
            
            unless @team.save
              flash[:error] = @team.errors.full_messages
              false
            else
              flash[:confirm] = "The team '#{@team.name}' has been updated."
              redirect '/teams/' + u(@team.name)
              true
            end
          end
          
        when 'delete'
          cname = @team.name
          @teams = Team.all
          if (@team.team_lead.username != @me.username)
            flash[:error] = 'Sorry. You cannot delete other people\'s team'
            redirect '/teams/' + u(@team.name)
          end      
          
          unless @team.destroy
            flash[:error] = @team.errors.full_messages
            false
          else
            flash[:confirm] = "The team '#{cname}' has been deleted."
            redirect '/my_account/teams/'
            true
          end
          
        when 'leave'
          cname = @team.name
          if (@team.members.include? @me) and (@team.team_lead != @me)
            membership = TeamsUser.all(:team_name => @team.name, :user_username => @me.username)
          else
            flash[:error] = 'Sorry. You cannot leave a team you are not a member of...'
            redirect '/teams/' + u(@team.name)
          end
          
          unless membership.destroy!
            flash[:error] = membership.errors.full_messages
            false
          else
            flash[:confirm] = "You left team '#{cname}'."
            redirect_referer
            true
          end

        when nil
          @sidebar = 'sidebar/teams/team_sidebar.xhtml'
          @action = 'view'
          @title = 'Team: ' + @team.name
          unless @team.team_lead.username == @me.username
            redirect '/teams/' + @team.name
          end
        else
          redirect '/my_account/teams/'
      end
      
    end
  end
  
end
