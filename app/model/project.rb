class Project
  include DataMapper::Resource
  include Notifiable
  extend Wio::Model
  
  property :project_id, Serial
  property :name, String
  property :description, Text
  #property :deadline, DateTime
  property :status, Integer, :length => 1
  property :created_at, DateTime
  property :updated_at, DateTime
  property :progress, Integer, :length => 3
  property :team_creator, String
  #property :creator, Integer, :key => true
  
  belongs_to :creator, :class_name => "User"
  belongs_to :team
  belongs_to :notification
  
  has n, :tasks
  belongs_to :default_context, :class_name => 'Context'
  has n, :assigned_to, :through => Resource, :class_name => 'User'
  
  validates_present :name
  validates_is_unique :name, {:scope=>:creator}
  validates_is_unique :name, {:scope=>:team}
end
