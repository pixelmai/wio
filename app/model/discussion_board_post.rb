class DiscussionBoardPost
  include DataMapper::Resource
  
  property :discussion_board_post_id, Serial
  property :contents, Text
  
  property :created_at,        DateTime
  property :updated_at,        DateTime
  
  belongs_to :discussion_board_topic
  belongs_to :user
  
  validates_present :contents
end
