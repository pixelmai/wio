class FileCategoryController < Ramaze::Controller
  map '/my_account/files/categories'
  layout '/page' #=> [ :index, :new ]  
  
  include Wio::Helper::General
  helper :aspect
  
  before_all do
    check_session
    @me = User.get(session[:username])
    @main_location = 'Dashboard'
    @sub_location = 'Files'
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (file_category = nil, action = nil)
    @sidebar = 'sidebar/file_categories/add_file_category.xhtml'
    @title = 'My File Categories'
    puts 1
    unless (@file_category = @me.file_categories.first({:name=>file_category})).nil?
      @title = 'File Category: ' + @file_category.name
      puts 2
      case action
        when 'edit'
          @sidebar = 'sidebar/file_categories/list_file_categories.xhtml'
          @action = :edit
          
          if (@file_category.name == 'uncategorized')
            flash[:error] = 'Sorry. You cannot edit the \'uncategorized\' file category'
            redirect '/my_account/files/categories/' + u(@file_category.name)
          end
          
          if request.post?
            @file_category.name = request[:name]
            
            unless @file_category.save
              flash[:error] = @file_category.errors.full_messages
              false
            else
              flash[:confirm] = "The file category '#{@file_category.name}' has been updated."
              redirect '/my_account/files/categories/' + u(@file_category.name)
              true
            end
          end
        when 'delete'
          cname = @file_category.name
          
          if (@file_category.name == 'uncategorized')
            flash[:error] = 'Sorry. You cannot delete the \'uncategorized\' file category'
            redirect '/my_account/files/categories/'
          end
          
          unless @file_category.destroy
            flash[:error] = @file_category.errors.full_messages
            false
          else
            flash[:confirm] = "The file category '#{cname}' has been deleted."
            redirect '/my_account/files/categories/'
            true
          end
        when nil
          @sidebar = 'sidebar/file_categories/upload_file.xhtml'
          @action = 'view'
        else
          redirect '/my_account/files/categories/'
      end
      
    end
  end
  
end
