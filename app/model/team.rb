class TeamsUser
  include DataMapper::Resource
  property :teams_users, Serial
  belongs_to :user
  belongs_to :team
end

class Team
  include DataMapper::Resource
  # TODO: change this to recommended pattern once this is fixed
  extend Wio::Model
  
  property :name, String, :key => true
  property :description, Text
  property :created_at,        DateTime
  property :updated_at,        DateTime
  
  #has n, :uploaded_files
  #has n, :tasks
  #has n, :projects
  #has n, :calendar_events
  has n, :members, :through => Resource, :class_name => 'User'
  
  belongs_to :team_lead, :class_name => 'User'
  has 1, :discussion_board
  has n, :tasks
  has n, :projects
  has n, :uploaded_files
  
  #has 1, :calendar
  
  validates_present :name, :team_lead
  validates_is_unique :name
  
  after :create do
    members << team_lead
    save
  end
  
  before :save do
    unless members.empty?
      throw :halt unless team_lead.in? members
    end
  end
  
  after :save do
    if self.discussion_board.nil?
      self.discussion_board = DiscussionBoard.new
      must_save = true
    end
    save if must_save
  end
  
  before :destroy do
    TeamsUser.all(:team_name => self.name).each do |m|
      m.destroy
    end
    
    self.discussion_board.destroy
    
    self.uploaded_files.all.each do |file|
      file.destroy
    end
    
    self.projects.all.each do |p|
      p.destroy
    end    
  end
  
end
