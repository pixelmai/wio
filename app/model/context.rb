class Context
  include DataMapper::Resource
  
  property :context_id, Serial
  property :name, String
  
  has n, :tasks
  has n, :projects
  belongs_to :user
  
  validates_present :name
  validates_is_unique :name, {:scope=>:user}
  
  before :destroy do
    # TODO: find a more efficient alternative
    user.projects.all({Project.default_context.context_id => self.context_id}).each do |project|
      project.default_context = user.contexts.first({:name => 'uncategorized'})
      project.save
    end
    
    user.tasks.all({Task.context.context_id => self.context_id}).each do |task|
      task.context = user.contexts.first({:name => 'uncategorized'})
      task.save
    end
  end
  
end
