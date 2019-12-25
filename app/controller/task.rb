class TaskController < Ramaze::Controller
  map '/my_account/tasks'
  layout '/page' #=> [ :index, :new ]  

  include Wio::Helper::General
  helper :aspect
  helper :formatting
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Tasks'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (task = nil, action = nil)
    @date = DateTime.now
    @sidebar = 'sidebar/tasks/add_task.xhtml'
    @js_include = '/js/tasks.js'
    @title = 'My Tasks'
    @where = 'task'
    unless (@task = @me.tasks.get(task)).nil?
      @title = 'Task: ' + @task.name
      case action
        when 'edit'
          @sidebar = 'sidebar/tasks/list_menu.xhtml'
          @title = 'Edit Task - ' + @task.name
          @action = :edit
          
          if request.post?
          
            unless request[:description].empty?
              @task.description = request[:description]
            end
            @task.name = request[:name]
            @task.context = @me.contexts.get(request[:context])
            @task.project = @me.projects.get(request[:project])

      
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
              redirect '/my_account/tasks/'+u(@task.task_id)+'/edit'
            end
            
            unless request[:progress].empty?
              if request[:progress].to_i <= 100
                @task.progress = request[:progress]
                if_save = true
              else
                if_save = false
                flash[:error] = "Progress must be in percentage from 0 -100"
                redirect '/my_account/tasks/'+u(@task.task_id)+'/edit'
              end
            else
              @task.progress = 0
            end  
            
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
                redirect '/'+ request[:form_location]
                true
              end
              
            end
      
       
          end
        when 'delete'
          pname = @task.name
          unless @task.destroy
            flash[:error] = @task.errors.full_messages
            false
          else
            flash[:confirm] = "The task '#{pname}' has been deleted."
          end
          redirect_referer
        when 'completed'
            pname = @task.name
            @task.completed = true
            unless @task.child_tasks.empty?
            
              @task.child_tasks.all.each do |t|
                t.completed = true
                t.progress = 100
                t.save
              end
              
              @task.progress = 100
            end
              
            unless @task.save
              flash[:error] = @task.errors.full_messages
              false
            else
              
              flash[:confirm] = "The task '#{pname}' has been set to completed."
            end
            redirect '/my_account/tasks/'
        when 'incomplete'
            pname = @task.name
            @task.progress = 0
            @task.completed = false
            
     
            unless @task.save
              flash[:error] = @task.errors.full_messages
              false
            else
              unless @task.child_tasks.empty?
              
                @task.child_tasks.all.each do |t|
                  t.progress = 0
                  t.completed = false
                  t.save
                end
                
                @task.progress = 0
              end
              flash[:confirm] = "The task '#{pname}' has been set to incomplete."
            end
            redirect '/my_account/tasks/'
            true
        when nil
          @action = 'view'
          @sidebar = 'sidebar/tasks/list_menu.xhtml'
        else
          redirect '/my_account/tasks/'
        end
      
    end
  end
end
