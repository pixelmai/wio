class ViewTeamController < Ramaze::Controller
  
  layout '/page' #=> [ :index, :new ]
  map '/teams'
  include Wio::Helper::General
  helper :aspect
  helper :formatting
  
  before_all do
    @main_location = 'Teams'
    @me = User.get(session[:username])
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (team = nil, action = nil, rid = nil)
    @sidebar = 'sidebar/search_team.xhtml'
    @title = 'Wio Teams'
    # paginate(model, items_per_page, options={})
    # See 'helper/paginator.rb'
    @page = paginate(Team, 10)
    @all_teams = @page.data
    @js_include = '/js/dashboard.js'
    if team
      if @team = Team.get(team)
        @title = 'Team: ' + @team.name
        @where = 'teams'
        @main_location = @team.name
        @sub_location = 'Home'
        case action
          when nil
            @action = 'view'
            @sidebar = 'sidebar/teams/team_sidebar.xhtml'
            #if not session[:username].nil? and @team.team_lead.username == session[:username]
            #  redirect '/my_account/teams/' + u(@team.name)
            #end
          
          when 'invite_members'
            @sub_location = 'Invite'
            @sidebar = 'sidebar/teams/team_sidebar.xhtml'
            @title = 'Invite Members - '+ @team.name
            @action = :invite
            if (@team.team_lead != @me)
              flash[:error] = 'Sorry. You cannot invite for other people\'s team'
              redirect_to_team_home
            end
            
            if request.post?
              @where = :search_results
              if request[:search_type] == 'username'
                unless request[:username].empty?
                  @search_results = User.all({:username => request[:username]})
                else
                  flash[:error] = 'Please specify the username to start searching...'
                  redirect_referrer
                end
              end

              if request[:search_type] == 'name'
                unless request[:first_name].empty? and request[:last_name].empty?
                  @search_results = User.all({:first_name => request[:first_name], :last_name =>  request[:last_name]})
                else
                  flash[:error] = 'Please specify the full name to start searching...'
                  redirect_referrer
                end
              end

            end

          when 'invite'
            @sub_location = 'Invite'
            if (@team.team_lead.username != @me.username)
              flash[:error] = 'Sorry. You cannot invite for other people\'s team'
              redirect_to_team_home
            end
            @invite_user = User.get(rid)
            membership = @team.members.first(:username => rid)
            if membership.nil?
              
              invite_requests = @me.sent_requests.all(:type => InviteUserRequest)
              requested_member = invite_requests.first(
                :user_username => @invite_user.username, 
                :accepted => false, 
                :from_team_name => @team.name,
                :ignored => false
              )
              
              if requested_member.nil? && (not (@team.members.include? @invite_user))
                req = InviteUserRequest.new(@team, @invite_user)
                if req.save
                  flash[:notice] = "A membership invitation has been sent to #{@invite_user.username}."
                  redirect_referer
                else
                  flash[:error] = req.errors.full_messages
                end
              else
                flash[:error] = "A contact request has already been sent to #{@invite_user.username}."
                redirect_referer
              end
              
              
            else
              flash[:error] = 'The user is already a member of this team...'
              redirect_to_team_home
            end
          
          
            
          when 'files'
          
            unless (logged_in? && @team.members.include?(@me))
              flash[:error] = 'You are not allowed to view the team\'s files. Sorry...'
              redirect_to_team_home
            end
            
            @sub_location = 'Files'
            @action = :files
            @file_action = :all_files
            @title = @team.name + '\'s Files'
            @sidebar = 'sidebar/teams/team_files.xhtml'
            if rid
              @file = @team.uploaded_files.first(:name=>rid, :team_name=>@team.name)
              unless @file
                redirect_to_team_files
              end
              
              unless request[:do].nil?
                unless @team.team_lead == @me
                  flash[:error] = 'You cannot modify the files of this team.'
                  redirect_to_team_files
                end
                case request[:do]
                  when 'edit'
                    @file_action = :edit_file
                    @title = 'Edit: ' + @file.name
                    #start of edit process
                    if request.post?       
                      @file.name = request[:name]
                      unless @file.save
                        flash[:error] = @file.errors.full_messages
                        false
                      else
                        flash[:confirm] = "The team file '#{@file.name}' has been updated."
                        redirect_to_team_files
                        true
                      end
                    end
                    #end of edit process
                  when 'delete'
                    pname = @file.name
                    unless @file.destroy
                      flash[:error] = @file.errors.full_messages
                      false
                    else
                      flash[:confirm] = "The team file '#{pname}' has been deleted."
                      redirect_to_team_files
                      true
                    end
                end
              end
            end
          when 'tasks'
            @js_include = '/js/tasks.js'
            unless (logged_in? && @team.members.include?(@me))
              flash[:error] = 'You are not allowed to view the team\'s tasks. Sorry...'
              redirect_to_team_home
            end
            
            @sub_location = 'Tasks'
            @action = :tasks
            @task_action = :all_tasks
            @where = 'team_tasks'
            @title = @team.name + '\'s Tasks'
            @sidebar = 'sidebar/teams/add_task.xhtml'

            if rid
              @task = @team.tasks.get(rid)
              unless @task
                redirect_to_team_tasks
              end
              @task_action = :view_task
              @title = 'Team Task: ' + @task.name
              
              unless request[:do].nil?
                case request[:do]
                  when 'delete'
                    pname = @task.name
                    unless @task.destroy
                      flash[:error] = @task.errors.full_messages
                      false
                    else
                      unless @task.child_tasks
                        @task.child_tasks.each do |t|
                          t.destroy
                        end
                      end
                      
                      flash[:confirm] = "The team task '#{pname}' has been deleted."
                      redirect_to_team_tasks
                      true
                    end

                  when 'edit'
                    @sidebar = 'sidebar/tasks/list_menu.xhtml'
                    @title = 'Edit Task - ' + @task.name
                    @task_action = :task_edit
                    if request.post?
                    
                      unless request[:description].empty?
                        @task.description = request[:description]
                      end
                      
                      @task.name = request[:name]
                      @task.project = @team.projects.get(request[:project])


                      unless request[:description].empty?
                        @task.description = request[:description]
                      end 
                     
                      

                      if_save = false
                      if not request[:deadline_month].empty? and not request[:deadline_day].empty? and not request[:deadline_year].empty?
                        @task.deadline = request[:deadline_month]+'/'+request[:deadline_day]+'/'+request[:deadline_year]
                        if_save = true
                      elsif request[:deadline_month].empty? and request[:deadline_day].empty? and request[:deadline_year].empty?
                        if_save = true
                      else
                        flash[:error] = "All the date fields must be set..."
                        redirect '/my_account/tasks/'+u(@task.task_id)+'/edit'
                      end   


                      
                      # NOTIFY
                      if (request[:notify_month]=="") && (request[:notify_day]=="") && (request[:notify_year]=="") && (request[:notify_hour]=="") && (request[:notify_minute]=="")
                        if_save = true
                      elsif (not request[:notify_month]=="") && (not request[:notify_day]=="") && (not request[:notify_year]=="") && (not request[:notify_hour]=="") && (not request[:notify_minute]=="")
                        puts 'weee'
                        unless @task.notification
                          puts 'New notification...'
                          @task.set_notification(
                            Notification.new(
                              :message => @task.name, 
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
                          
                          puts @task.name
                          
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
                      elsif (not request[:notify_month]=="") && (not request[:notify_day]=="") && (not request[:notify_year]=="")
                        if_save = true
                      else
                        flash[:error] = "All the fields must be set for notification..."
                        redirect_referer
                      end
                      
                      
                      #NOTIFY
                      
                      if if_save
                        unless @task.save
                          flash[:error] = @task.errors.full_messages
                          redirect request[:form_location] +'/edit'
                          false
                        else
                          if @new_notification_date
                            nd = Notification.get(@task.notification.notification_id)
                            nd.when = @new_notification_date
                            nd.sent = false
                            nd.save
                          end
                          flash[:confirm] = "The task '#{@task.name}' has been updated."
                          redirect_to_team_tasks
                          true
                        end
                      end
                    end

                end
              end
            end
          when 'projects'
            @js_include = '/js/tasks.js'
            unless (logged_in? && @team.members.include?(@me))
              flash[:error] = 'You are not allowed to view the team\'s projects. Sorry...'
              redirect_to_team_home
            end
            @sub_location = 'Projects'
            @action = :projects
            @project_action = :all_projects
            @title = @team.name + '\'s Projects'
            @sidebar = 'sidebar/teams/team_projects.xhtml'

            if rid
              @project = @team.projects.first(:name=>rid, :team_name=>@team.name)
              unless @project
                redirect_to_team_projects
              end
              @project_action = :view_project
              @title = 'Team Project: ' + @project.name
              
              unless request[:do].nil?
                unless @team.team_lead == @me
                  flash[:error] = 'You cannot modify the projects of this team.'
                  redirect_to_team_projects
                end
                case request[:do]
                  when 'edit'
                    @project_action = :edit_project
                    @title = 'Edit: ' + @project.name
                    #start of edit process
                    if request.post?       
                      unless request[:description].empty?
                        @project.description = request[:description]
                      end
                      @project.name = request[:name]
                     
                      if_save = false
                      
                      if request[:status] == '0'
                        if @project.tasks.all({:completed => false}).length == 0
                          @project.status = request[:status]
                          if_save = true
                        else
                          flash[:error] = 'All tasks must be completed before closing a project.'
                        end
                      else
                        @project.status = request[:status]
                        if_save = true
                      end

                      if if_save
                        unless @project.save
                          flash[:error] = @project.errors.full_messages
                          false
                        else
                          flash[:confirm] = "The team project '#{@project.name}' has been updated."
                          redirect_to_team_projects
                          true
                        end
                      end

                    end
                    #end of edit process

                  when 'delete'
                    pname = @project.name
                    unless @project.destroy
                      flash[:error] = @project.errors.full_messages
                      false
                    else
                      flash[:confirm] = "The team project '#{pname}' has been deleted."
                      redirect_to_team_projects
                      true
                    end
                end
              end
              
            end
            
          when 'members'
            @sub_location = 'Members'
            @title = @team.name + '\'s Members'
            @action = :members
            @sidebar = 'sidebar/teams/team_sidebar.xhtml'

          when 'add_task'
            if request.post?

              task = @me.tasks.new({
                :name=>request[:name],
                :project => @team.projects.get(request[:project]),
                :completed => false,
                :progress => 0,
                :team_name => @team.name
              })
              
              if request[:context]
                task.context = @me.contexts.get(request[:context])
              else
                task.context = @me.contexts.first(:name=>'uncategorized')
              end
              
              unless request[:description].empty?
                task.description = request[:description]
              end
              
              if_save = false
              if not request[:deadline_month].empty? and not request[:deadline_day].empty? and not request[:deadline_year].empty?
                task.deadline = request[:deadline_month]+'/'+request[:deadline_day]+'/'+request[:deadline_year]
                if_save = true
              elsif request[:deadline_month].empty? and request[:deadline_day].empty? and request[:deadline_year].empty?
                if_save = true
              else
                flash[:error] = "All the date fields must be set..."
                unless request[:form_location].nil?
                  flash[:error] = "All the date fields must be set..."
                end
              end    
              
              
              @team.members.each do |m|
                if m.mobile_number
                  task.set_notification(
                    Notification.new(
                      :message => 'Task - (' + task.name + ') has been added to Team ' + @team.name, 
                      :mode => :cellphone,
                      :recipient_user => m, 
                      :when => DateTime.now,
                      :sent => false
                    )
                  )
                end
              end  
              
              if if_save
                unless task.save
                  flash[:error] = task.errors.full_messages
                  false
                else  
                  members = []
                 
                  
                  if request[:assigned] and request[:assigned]!= 'all'
                    
                    members[0] = @team.members.get(request[:assigned])
                  
                  elsif request[:assigned]== 'all'
                    members = @team.members.all
                  end
                  
                    members.each do |member|
                        c = member.contexts.get :uncategorized
                        tc = task.child_tasks.new({
                          :name=>task.name,
                          :context => c,
                          :team_name => @team.name,
                          :user_username => member.username,
                        })
                        tc.save
                    end     
                  flash[:confirm] = "The Task '#{task.name}' has been added."
                  true
                end
              end
            end
            redirect redirect_referrer
          when 'remove'
            if @team.team_lead == @me
              check_member = User.get(rid)
              if (@team.members.include? check_member) and check_member != @me
                membership = TeamsUser.all(:team_name => @team.name, :user_username => rid)
              else
                flash[:error] = 'Sorry. You cannot remove a non-existent member'
                redirect_referer
              end
              
              unless membership.destroy!
                flash[:error] = membership.errors.full_messages
                false
              else
                flash[:confirm] = "You removed #{rid} from '#{@team.name}'."
                redirect_referer
                true
              end
            else
              flash[:error] = "You cannot remove members for this team."
              redirect_referer
            end
            
          when 'join'
            unless session[:username].nil?
              @action = 'join'
              membership = @team.members.first(:username => session[:username])
              
              join_requests = @me.sent_requests.all(:type => JoinTeamRequest)
              requested_team = join_requests.first(
                :team_name => @team.name, 
                :accepted => false, 
                :from_username => @me.username,
                :ignored => false
              )
              
              if membership.nil?
                if requested_team.nil? && (not (@team.members.include? @me))
                  req = JoinTeamRequest.new(@me, @team)
                  if req.save
                    flash[:notice] = "A membership request has been sent to #{@team.name}."
                    redirect_referer
                  else
                    flash[:error] = req.errors.full_messages
                  end
                else
                  flash[:error] = "A membership request has already been sent to #{@team.name}."
                  redirect_referer
                end
              else
                flash[:error] = 'You are already a member of this team...'
                redirect_to_team_home
              end
            else
              redirect_to_team_home
            end
          else
            redirect_to_team_home
          
        end
      else #if team specified doesn't exist
        redirect '/teams'
      end
    end
  end
  
  private
  
  def redirect_to_team_home
    redirect '/teams/' + u(@team.name)
  end

  def redirect_to_team_files
    redirect '/teams/' + u(@team.name) + '/files'
  end  
  
  def redirect_to_team_projects
    redirect '/teams/' + u(@team.name) + '/projects'
  end
  
  def redirect_to_team_tasks
    redirect '/teams/' + u(@team.name) + '/tasks'
  end
  
end
