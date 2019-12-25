class ProjectController < Ramaze::Controller
  map '/my_account/projects'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  helper :formatting
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Projects'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (project = nil, action = nil)
    @sidebar = 'sidebar/projects/add_project.xhtml'
    @where = 'project'
    @title = 'My Projects'
    unless (@project = @me.projects.first({:name=>project})).nil?
      @title = 'Project: ' + @project.name

      case action
        when 'edit'
          @sidebar = 'sidebar/projects/list_projects.xhtml'
          @title = 'Edit Project - ' + @project.name
          @action = :edit
          
          if request.post?
          
            unless request[:description].empty?
              @project.description = request[:description]
            end
            @project.name = request[:name]
            @project.default_context = @me.contexts.get(request[:default_context])
            
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
                flash[:confirm] = "The project '#{@project.name}' has been updated."
                redirect '/my_account/projects/' + u(@project.name)
                true
              end
            end
      
            
          end
        when 'delete'
          pname = @project.name
          unless @project.destroy
            flash[:error] = @project.errors.full_messages
            false
          else
            flash[:confirm] = "The project '#{pname}' has been deleted."
            redirect '/my_account/projects/'
            true
          end
        when nil
          @on_load = "load"
          @sidebar = 'sidebar/tasks/add_task.xhtml'
          @js_include = '/js/tasks.js'
          @action = 'view'
        else
          redirect '/my_account/projects/'
      end
      
    end
  end
  
end
