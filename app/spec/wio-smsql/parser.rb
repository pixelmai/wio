require '../../spec'


describe Wio::SMSQLParser do

  before do
    @parser = Wio::SMSQLParser
  end
  
  it 'should parse tasks simplest' do
    @parser.parse('tasks').should.equal({
      :command => :tasks
    })
  end
  
  it 'should parse tasks simplest' do
    @parser.parse('Tasks').should.equal({
      :command => :tasks
    })
  end
  
  it 'should parse tasks command with name' do
    @parser.parse('tasks :shop').should.equal({
      :command => :tasks, :name => 'shop'
    })
  end
  
  it 'should parse tasks simplest with leading and trailing spaces' do
    @parser.parse('   tasks    ').should.equal({
      :command => :tasks
    })
  end
  
  it 'should parse tasks command with name with multi-spaces' do
    @parser.parse('tasks     :shop').should.equal({
      :command => :tasks, :name => 'shop'
    })
  end
  
  it 'should parse tasks command with name with multi-spaces, tabs and newlines' do
    @parser.parse("\ntasks   \t\t  \n  :shop").should.equal({
      :command => :tasks, :name => 'shop'
    })
  end
  
  it 'should parse tasks command with context' do
    @parser.parse('tasks @school').should.equal({
      :command => :tasks, :context => 'school'
    })
  end
  
  it 'should parse tasks command with id' do
    @parser.parse('tasks 123').should.equal({
      :command => :tasks, :id => 123
    })
  end
  
  it 'should parse tasks with tomorrow keyword' do
    @parser.parse('tasks tomorrow').should.equal({
      :command => :tasks, :deadline => :tomorrow
    })
  end
  
  it 'should parse tasks with tom keyword' do
    @parser.parse('tasks tom').should.equal({
      :command => :tasks, :deadline => :tomorrow
    })
  end
  
  it 'should parse tasks with today keyword' do
    @parser.parse('tasks today').should.equal({
      :command => :tasks, :deadline => :today
    })
  end
  
  it 'should parse today keyword only' do
    @parser.parse('today').should.equal({
      :command => :tasks, :deadline => :today
    })
  end
  
  it 'should parse projects simplest' do
    @parser.parse('projects').should.equal({
      :command => :projects
    })
  end
  
  it 'should parse done command' do
    @parser.parse('done :xz').should.equal({
      :command => :done, :name => 'xz'
    })
  end
  
  it 'should parse done command using id' do
    @parser.parse('done 12').should.equal({
      :command => :done, :id => 12
    })
  end
  
  it 'should parse task with underscored names' do
    @parser.parse("tasks :stop_and_shop").should.equal({
      :command => :tasks, :name => 'stop and shop'
    })
  end
  
  it 'should parse task with quoted name' do
    @parser.parse("tasks 'eat and drink'").should.equal({
      :command => :tasks, :name => 'eat and drink'
    })
  end
  
  it 'should parse task with double-quoted name' do
    @parser.parse('tasks "eat and drink"').should.equal({
      :command => :tasks, :name => 'eat and drink'
    })
  end
  
  it 'should parse task with double-quoted name mixed case' do
    @parser.parse('tasks "Eat and Drink"').should.equal({
      :command => :tasks, :name => 'Eat and Drink'
    })
  end
  
  it 'should return nil if parser fails to understand query' do
    @parser.parse('wateawraer asdfasdf').should.equal nil
  end
  
  it 'should add task' do
    @parser.parse('new "eat"').should.equal({
      :command => :new, :name => "eat"
    })
  end

end
