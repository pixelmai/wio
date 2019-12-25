class UploadedFile
  include DataMapper::Resource
  include Notifiable
  extend Wio::Model
  
  property :file_id, Serial
  property :name, String
  property :file_path, Text
  property :team_creator, String
  
  belongs_to :user
  belongs_to :team
  belongs_to :file_category
  belongs_to :notification
  #has n, :file_sharings
  #has n, :shared_with_users, :through => :file_sharings
  
  validates_present :name, :file_path
  validates_is_unique :name, {:scope=>:user}
end
