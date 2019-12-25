class MyAccountController < Ramaze::Controller
  map '/my_account'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index
    @sub_location = 'Profile'
    @title = session[:username] + "'s Profile"
    @user_profile = @me
    @sidebar = 'sidebar/user_profile.xhtml'
  end
  
  def edit_profile
    @sidebar = 'sidebar/user_profile.xhtml'
    @title = "Edit Profile Information"
    @sub_location = 'Profile'
    @action = 'profile_management'
    if request.post?
      if request[:last_name].empty? or request[:first_name].empty? or request[:middle_name].empty?
        flash[:error] = "Your full name is required..."
      else
             
        unless request[:address].empty?
          @me.address = request[:address]
        end
        
        unless request[:home_phone_number].empty?
          @me.home_phone_number = request[:home_phone_number]
        end
        
        unless request[:work_phone_number].empty?
          @me.work_phone_number = request[:work_phone_number]
        end

        if_save = false
        if not request[:Birth_Date_month].empty? and not request[:Birth_Date_day].empty? and not request[:Birth_Date_year].empty?
          @me.birth_date = request[:Birth_Date_month]+'/'+request[:Birth_Date_day]+'/'+request[:Birth_Date_year]
          if_save = true
        elsif request[:Birth_Date_month].empty? and request[:Birth_Date_day].empty? and request[:Birth_Date_year].empty?
          if_save = true
        else
          flash[:error] = "All the date fields must be set..."
        end    
        
        last_name= request[:last_name].split(" ")
        i = 0;
        begin
           last_name[i] = last_name[i].capitalize
           i += 1;
        end while i < last_name.length
        
        
        first_name= request[:first_name].split(" ")
        i = 0;
        begin
           first_name[i] = first_name[i].capitalize
           i += 1;
        end while i < first_name.length

        middle_name= request[:middle_name].split(" ")
        i = 0;
        begin
           middle_name[i] = middle_name[i].capitalize
           i += 1;
        end while i < middle_name.length

        
        
        @me.last_name = last_name.join(" ") #request[:last_name].capitalize
        @me.first_name = first_name.join(" ") #request[:first_name].capitalize
        @me.middle_name = middle_name.join(" ") #request[:middle_name].capitalize
        
        if if_save
          unless @me.save
            flash[:error] = task.errors.full_messages
            false
          else
            flash[:confirm] = "Your Profile has been updated."
            redirect '/my_account'
          end
        end
      end
    end
    
  end
  
  def manage_account
    @sidebar = 'sidebar/user_profile.xhtml'
    @main_location = ''
    @action = 'profile_management'
    @title = "Manage Account Information"
    if request.post?
      @me.email_address = request[:email_address]
      
      #mobile duplication checking
      mobile = normalize(request[:mobile_number])
      other_mobile = User.first(:mobile_number => mobile)
      other_mobile = normalize(other_mobile.mobile_number) if other_mobile
      my_mobile = @me.mobile_number
      my_mobile = normalize(my_mobile) if my_mobile
      
      if other_mobile
        if other_mobile != my_mobile
          flash[:error]="The mobile number you entered is already used by another user"
          return
        end
      end
      #mobile duplication checking
      
      @me.mobile_number = mobile
      
      unless request[:password].empty?
        if request[:old_password] == @me.password
          @me.password = request[:password]
          @me.password_confirmation = request[:password_confirmation]
        else
          flash[:error]="The password you entered is wrong..."
          return
        end
      end
      
      unless @me.save
        flash[:error] = @me.errors.full_messages
        false
      else
        flash[:confirm] = "Your account has been updated."
        redirect '/my_account'
        true
      end
    end
    
  end
  
  
  # CONTEXT
  def add_context
    @title = 'Add a Context'
    if request.post?
      context = @me.contexts.new({:name=>request[:name]})
      
      unless context.save
        flash[:error] = context.errors.full_messages
        redirect '/my_account/contexts'
        false
      else
        flash[:confirm] = "The context '#{context.name}' has been added."
        #redirect R(ContextController, context.name)
        redirect '/my_account/contexts'
        true
      end
    end
  end
  
  # TEAM
  def add_team
    @title = 'Create a Team'
    if request.post?
      team = @me.lead_teams.new({:name=>request[:name]})
      
      unless request[:description].nil?
        team.description = request[:description]
      end
      
      unless team.save
        flash[:error] = team.errors.full_messages
        redirect '/my_account/teams'
        false
      else
        flash[:confirm] = "The team '#{team.name}' has been added."
        #redirect R(TeamController, team.name)
        redirect '/my_account/teams'
        true
      end
    end
  end
  
  # PROJECT
  def add_project
    @title = 'Add a Project'
    if request.post?
      if request[:team]
        @team = Team.get(request[:team])
        project = @team.projects.new({
          :name=>request[:name],
          :status => 1,
          :team_creator => @me.username
          #:team_name => @team.name
        })
        
        @team.members.each do |m|
          if m.mobile_number
            project.set_notification(
              Notification.new(
                :message => 'Project - (' + project.name + ') has been added to Team ' + @team.name, 
                :mode => :cellphone,
                :recipient_user => m, 
                :when => DateTime.now,
                :sent => false
              )
            )
          end
        end  
        
      else
        project = @me.projects.new({
          :name=>request[:name],
          :default_context => @me.contexts.get(request[:default_context]),
          :status => 1
        })
      end
      
      unless request[:description].empty?
        project.description = request[:description]
      end
      
      unless project.save
        flash[:error] = project.errors.full_messages
        redirect_referer
        false
      else
        flash[:confirm] = "The project '#{project.name}' has been added."
        #redirect R(ProjectController, project.name)
        redirect_referer
        true
      end
    end
  end
  
  # TASK
  def add_task
    @title = 'Add a Task'
    if request.post?

      task = @me.tasks.new({
        :name=>request[:name],
        :project => @me.projects.get(request[:project]),
        :completed => false,
        :progress => 0
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
      
      if if_save
        unless task.save
          flash[:error] = task.errors.full_messages
          false
        else       
          flash[:confirm] = "The Task '#{task.name}' has been added."
          true
        end
      end
      redirect redirect_referrer
    end
  end

  # FILE CATEGORY
  def add_file_category
    @title = 'Add a File Category'
    if request.post?
      
      file_category = @me.file_categories.new({
        :name=>request[:name]
      })
      
      unless file_category.save
        flash[:error] = file_category.errors.full_messages
        false
      else
        flash[:confirm] = "The File Category '#{file_category.name}' has been added."
        #redirect R(FileCategoryController, file_category.name)
        true
      end
      redirect '/my_account/files/categories'
    end
  end
  
  
  # CALENDAR EVENT
  def add_event
    @title = 'Add a Calendar Event'
    if request.post?
      @me.calendar
      @me.save
      event = @me.calendar.calendar_events.new({
        :name=>request[:name]
      })
      
      if not request[:start_date_month].empty? and not request[:start_date_day].empty? and not request[:start_date_year].empty?
        event.start_date = request[:start_date_month]+'/'+request[:start_date_day]+'/'+request[:start_date_year]
      end 
      
      
      # NOTIFY
      if (request[:notify_month]=="") && (request[:notify_day]=="") && (request[:notify_year]=="") && (request[:notify_hour]=="") && (request[:notify_minute]=="")
        if_save = true
      elsif (not request[:notify_month]=="") && (not request[:notify_day]=="") && (not request[:notify_year]=="") && (not request[:notify_hour]=="") && (not request[:notify_minute]=="")
        if event
          puts 'New notification...'
          event.set_notification(
            Notification.new(
              :message => event.name, 
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
        end
      end
      
      unless event.save
        flash[:error] = event.errors.full_messages
        false
      else
        flash[:confirm] = "The Event '#{event.name}' has been added."
        #redirect R(CalendarController)
        true
      end
      redirect '/my_account/calendar'
    end
  end
  
  def file_upload
    @title = 'Upload File'
    if request.post?
      
      if request[:team]
        @team = Team.get(request[:team])
      end
      
      orig_file = request[:file]
      unless orig_file[:filename].empty?
        
        file_name_prefix = DateTime.now.strftime("%m-%d-%Y-%I-%M-%S-")
        file_name = file_name_prefix + orig_file[:filename]
        file_name.chomp!(" ") # remove spaces on the ends
        
        unless @team
          dir_path = "#{__APP_PATH__}/public/files/#{@me.username}/"
          resource_path = "files/#{@me.username}/#{file_name}"
        else
          dir_path = "#{__APP_PATH__}/public/files/team_#{@team.name}/"
          resource_path = "files/team_#{@team.name}/#{file_name}"          
        end
        
        file_path = "#{dir_path}/#{file_name}"


        Dir.mkdir(dir_path) unless File.directory?(dir_path)
        File.rename(orig_file[:tempfile].path, file_path)

      end
      
      unless @team
        file = @me.uploaded_files.new({
          :name=>request[:name],
          :file_path => resource_path,
          :file_category => @me.file_categories.get(request[:file_category])
        })
        
      else
        file = @team.uploaded_files.new({
          :name=>request[:name],
          :file_path => resource_path,
          :team_creator => @me.username
        })
        
        
        @team.members.each do |m|
          if m.mobile_number
            file.set_notification(
              Notification.new(
                :message => 'File - (' + file.name + ') has been added to Team ' + @team.name, 
                :mode => :cellphone,
                :recipient_user => m, 
                :when => DateTime.now,
                :sent => false
              )
            )
          end
        end 
      end
      
      unless file.save
        flash[:error] = file.errors.full_messages
        redirect '/my_account/files'
        false
      else
        flash[:confirm] = "The file '#{file.name}' has been uploaded."
        #redirect R(ContextController, context.name)
        redirect_referrer
        true
      end
    end
  end
  
  private
    
    def normalize(number)
      n = number
      n = n.gsub('+', '')
      if (n[0, 1] == '0')
        n[0,1] = '3'
        n = '6' + n
      end
      n
    end
end
