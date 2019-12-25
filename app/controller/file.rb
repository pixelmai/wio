class FileController < Ramaze::Controller
  map '/my_account/files'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @main_location = 'Dashboard'
    @me = User.get(session[:username])
    @sub_location = 'Files'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (file = nil, action = nil)
    @sidebar = 'sidebar/files/upload_file.xhtml'
    @title = 'My Files'
    unless (@file = @me.uploaded_files.first({:name=>file})).nil?
      @title = 'File: ' + @file.name
      case action
        when 'edit'
          @sidebar = 'sidebar/files/related_tasks.xhtml'
          @title = 'Edit file info - '+ @file.name
          
          @action = :edit
          
          if request.post?
            @file.name = request[:name]
            @file.file_category = @me.file_categories.get(request[:file_category])
            
            unless @file.save
              flash[:error] = @file.errors.full_messages
              false
            else
              flash[:confirm] = "The file '#{@file.name}' has been updated."
              redirect '/my_account/files/'
              true
            end
          end
        when 'delete'
          fname = @file.name
          unless @file.destroy
            flash[:error] = @file.errors.full_messages
            false
          else
            flash[:confirm] = "The file '#{fname}' has been deleted."
            redirect '/my_account/files/'
            true
          end
        when nil
          @sidebar = 'sidebar/files/upload_file.xhtml'
          @action = 'view'
          @title = 'File: ' + @file.name
        else
          redirect '/my_account/files/'
      end
      
    end
  end
  
end
