require 'ramaze-irb'

def create_user hash
  if User.get(hash[:username]).nil?
    user = User.new(hash)
    if user.save
      puts user.username.capitalize + " account created."
    else
      puts "There were some problems..."
      puts user.errors.full_messages
    end
  else
    puts hash[:username].capitalize +  " account already exists."
  end
end

def create_context hash
  context = Context.new(hash)
  if context.save
    puts context.name.capitalize + " context created."
  else
    puts "There were some problems..."
    puts context.errors.full_messages
  end
end

def create_project hash
  d_c = Context.first(:user_username => hash[:user_username], :name => hash[:default_context])
  project = Project.new(:name => hash[:name], :default_context => d_c, :user_username => hash[:user_username], :status => 1)
  if project.save
    puts project.name.capitalize + " project created."
  else
    puts "There were some problems..."
    puts project.errors.full_messages
  end
end

def create_task hash
  cc = Context.first(:name => hash[:context], :user_username => hash[:user_username])
  pp = Project.first(:name => hash[:project], :user_username => hash[:user_username])
  task = Task.new(:name => hash[:name], :context => cc, :project => pp, :user_username => hash[:user_username], :completed => hash[:completed])
  if task.save
    puts task.name.capitalize + " task created."
  else
    puts "There were some problems..."
    puts task.errors.full_messages
  end
end

def create_file_cat hash
  file_cat = FileCategory.new(hash)
  if file_cat.save
    puts file_cat.name.capitalize + " file category created."
  else
    puts "There were some problems..."
    puts file_cat.errors.full_messages
  end
end

def create_events hash
  event = CalendarEvent.new(hash)
  if event.save
    puts event.name.capitalize + " event created."
  else
    puts "There were some problems..."
    puts event.errors.full_messages
  end
end

def create_team hash
  team = @me.lead_teams.new(hash)
  if team.save
    puts team.name.capitalize + " team created."
  else
    puts "There were some problems..."
    puts team.errors.full_messages
  end
end




[
  'eunice', 'trishen', 'kyr', 'joy', 'cristina',
  'leslie', 'dee_ann', 'aileen', 'daniel',
  'niel', 'randhel', 'klint', 'ivy', 'kristal',
  'jason', 'piolo', 'verjun', 'heherson', 'michael',
  'almer', 'gigi', 'vinyl', 'gillian',
  'kharem', 'rogelio', 'chacha', 'charlotte', 'nikko', 'wio', 'admin'
].each do |v|
  create_user({
    :username => v,
    :password => v,
    :password_confirmation => v,
    :email_address => v + '@' + v + '.com',
  })
  
  [
    'School', 'Work', 'Personal'
  ].each do |c|  
    create_context({
      :name => c,
      :user_username => v
    })
    
    [ 
      'Proj'
    ].each do |p|
      create_project({
        :name => v + '\'s ' + c + ' ' + p, 
        :user_username => v,
        :default_context => c
      })
             
                     
      [ 
        'Task A', 'Task B'
      ].each do |t|          
       
        create_task({
          :name => v + '\'s ' + c + ' ' + p + ' ' + t + '1',
          :user_username => v,
          :context => c,
          :project => v + '\'s ' + c + ' ' + p, 
          :completed => false
        })
        
        create_task({
          :name => v + '\'s ' + c + ' ' + p + ' ' + t + '2',
          :user_username => v,
          :context => c,
          :project => v + '\'s ' + c + ' ' + p, 
          :completed => true
        })
      end          
    end      
  end 
  
  #Create File Categories
    
  [
    'Documents', 'Images', 'PDFs'
  ].each do |f|  
    create_file_cat({
      :name => v + '\'s ' + f,
      :user_username => v
    })        
  end
  
  #Create Events
  @me = User.get(v)
  
  @calendar = @me.calendar.calendar_id
  [
    'Event 1', 'Event2', 'Event 3'
  ].each do |e|  
    create_events({
      :name => v + '\'s ' + e,
      :calendar_calendar_id => @calendar,
      :start_date => Date.today
    })        
  end
  
  #Create Teams
  
  [
    'Team 1', 'Team 2'
  ].each do |t|  
    create_team({
      :name => v.capitalize + '\'s ' + t,
    })        
  end
  
  
  
end


