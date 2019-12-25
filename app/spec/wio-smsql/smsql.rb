require '../../spec'

DataMapper.setup(:default, 'mysql://wio:wio@localhost/wio_test')
DataMapper.auto_migrate!

describe Wio::SMSQL do

  before do
    DataMapper.auto_migrate!
    @user = User.new(
      :username => 'wio', :password => 'wio',
      :password_confirmation => 'wio', :email_address=>'wio@test.com'
    )
    unless @user.save
      puts @user.errors.full_messages
    end
    @user.tasks.new(
      :name => 'task 1'
    )
    @user.tasks.new(
      :name => 'task 2'
    )
    @user.save
    @server = Wio::SMSQL.new
  end
  
  it 'should get tasks' do
    @server.execute('tasks').should.equal(
      "- task 1\n- task 2"
    )
  end

end
