require '../../spec'

DataMapper.setup(:default, 'mysql://wio:wio@localhost/wio_test')
DataMapper.auto_migrate!

describe Wio::SMSQLCommander do

  before do
    DataMapper.auto_migrate!
    @user = User.new(
      :username => 'wio', :password => 'wio',
      :password_confirmation => 'wio', :email_address=>'wio@test.com',
      :mobile_number => '01113334444'
    )
    unless @user.save
      puts @user.errors.full_messages
    end
    school = @user.contexts.new(:name => 'school')
    home   = @user.contexts.new(:name => 'home')
    @user.save
    home.reload
    school.reload
    @user.tasks.new(
      :name => 'task 1',
      :task_id => 1
    )
    @user.tasks.new(
      :name => 'task 2',
      :deadline => Date.today,
      :task_id => 2
    )
    @user.tasks.new(
      :name => 'completed task 3',
      :task_id => 6,
      :completed => true
    )
    @user.tasks.new(
      :name => 'school task',
      :task_id => 9,
      :context => school
    )
    @user.tasks.new(
      :name => 'home task',
      :task_id => 10,
      :context => home
    )
    @user.save
    
    @x = User.new(
      :username => 'x', :password => 'x',
      :password_confirmation => 'x', :email_address=>'x@x.com',
      :mobile_number => '02223334444'
    )
    unless @x.save
      puts @x.errors.full_messages
    end
    @x.tasks.new(
      :name => 'xtask 1',
      :task_id => 3
    )
    @x.tasks.new(
      :name => 'xtask 2',
      :task_id => 4
    )
    @x.tasks.new(
      :name => 'xtask 3',
      :task_id => 5
    )
    @x.save
    
    @b = User.new(
      :username => 'b', :password => 'b',
      :password_confirmation => 'b', :email_address=>'b@b.com',
      :mobile_number => '633333334444'
    )
    unless @b.save
      puts @b.errors.full_messages
    end
    @b.tasks.new(
      :name => 'btask 1',
      :task_id => 7
    )
    @b.tasks.new(
      :name => 'btask 2',
      :task_id => 8
    )
    @b.save
    
    @com = Wio::SMSQLCommander
  end
  
  it 'should get tasks' do
    @com.execute('01113334444', {
      :command => :tasks
    }).should.equal(
      "4 results:\n-task 1(1)\n-task 2(2)\n-school task(9)\n-home task(10)"
    )
  end
  
  it 'should get tasks with plus format used in number' do
    @com.execute('+631113334444', {
      :command => :tasks
    }).should.equal(
      "4 results:\n-task 1(1)\n-task 2(2)\n-school task(9)\n-home task(10)"
    )
  end
  
  it 'should get tasks in a context' do
    @com.execute('+631113334444', {
      :command => :tasks,
      :context => :school
    }).should.equal(
      "1 results:\n-school task(9)"
    )
  end
  
  it 'should mark a task as done' do
    @com.execute('+631113334444', {
      :command => :done,
      :id => 1
    }).should.equal(
      "Task 'task 1' (1) is completed"
    )
    @user.reload
    (@user.tasks.get 1).completed.should.equal true
  end
  
  it 'should not mark a task as done if sender is not owner' do
    @com.execute('633333334444', {
      :command => :done,
      :id => 1
    }).should.equal(
      "You have no tasks like that (id = 1)"
    )
    @user.reload
    (@user.tasks.get 1).completed.should.equal false
  end
  
  it 'should get tasks due today' do
    @com.execute('631113334444', {
      :deadline => :today,
      :command => :tasks
    }).should.equal(
      "1 results:\n-task 2(2)"
    )
  end

  it 'should get b tasks with normal format used in number' do
    number = '633333334444'
    @com.execute(number, {
      :command => :tasks
    }).should.equal(
      "2 results:\n-btask 1(7)\n-btask 2(8)"
    )
  end
  
  it 'should get b tasks with plus format used in number' do
    number = '+633333334444'
    @com.execute(number, {
      :command => :tasks
    }).should.equal(
      "2 results:\n-btask 1(7)\n-btask 2(8)"
    )
  end
  
  it 'should get tasks for x user' do
    @com.execute('02223334444', {
      :command => :tasks
    }).should.equal(
      "3 results:\n-xtask 1(3)\n-xtask 2(4)\n-xtask 3(5)"
    )
  end
  
  it 'should add task for x user' do
    @com.execute('02223334444', {
      :name => 'churva task',
      :command => :new
    }).should.match(
      /Task 'churva task' \(\d+\) has been added/
    )
  end
  
  it 'should add task with context for user' do
    @com.execute('01113334444', {
      :name => 'another home task',
      :command => :new,
      :context => 'home'
    }).should.match(
      /Task 'another home task' \(\d+\) has been added/
    )
    @user.tasks.first(:name => 'another home task').
      context.name.should.equal 'home'
  end
  
  it 'should not add task with non-existent context for user' do
    @com.execute('01113334444', {
      :name => 'a work task',
      :command => :new,
      :context => 'work'
    }).should.match(
      /Unable to add task 'a work task'. Context 'work' not found/
    )
    @user.tasks.first(:name => 'a work task').should.equal nil
  end
  
  
  it 'should return nil if user does not exist' do
    @com.execute('nonexistentnumber', {
      :command => :tasks
    }).should.equal(nil)
  end

end
