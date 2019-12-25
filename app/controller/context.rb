class ContextController < Ramaze::Controller
  map '/my_account/contexts'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @main_location = 'Dashboard'
    @me = User.get(session[:username])
    @sub_location = 'Contexts'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (context = nil, action = nil)
    @sidebar = 'sidebar/contexts/add_context.xhtml'
    @where = 'context'
    @title = 'My Contexts'
    unless (@context = @me.contexts.first({:name=>context})).nil?
      @title = 'Context: ' + @context.name
      case action
        when 'edit'
          @sidebar = 'sidebar/contexts/list_contexts.xhtml'
          @title = 'Edit context - '+ @context.name
          if (@context.name == 'uncategorized')
            flash[:error] = 'Sorry. You cannot edit the \'uncategorized\' context'
            redirect '/my_account/contexts/' + u(@context.name)
          end
          
          @action = :edit
          
          if request.post?
            @context.name = request[:name]
            
            unless @context.save
              flash[:error] = @context.errors.full_messages
              false
            else
              flash[:confirm] = "The context '#{@context.name}' has been updated."
              redirect '/my_account/contexts/' + u(@context.name)
              true
            end
          end
        when 'delete'
          cname = @context.name
          if (cname == 'uncategorized')
            flash[:error] = 'Sorry. You cannot delete the \'uncategorized\' context'
            redirect '/my_account/contexts/' + u(cname)
          end
          unless @context.destroy
            flash[:error] = @context.errors.full_messages
            false
          else
            flash[:confirm] = "The context '#{cname}' has been deleted."
            redirect '/my_account/contexts/'
            true
          end
        when nil
          @sidebar = 'sidebar/tasks/add_task.xhtml'
          @on_load = "load"
          @action = 'view'
          @js_include = '/js/tasks.js'
          @title = 'Context: ' + @context.name
        else
          redirect '/my_account/contexts/'
      end
      
    end
  end
  
end
