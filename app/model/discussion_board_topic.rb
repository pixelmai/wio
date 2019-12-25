class DiscussionBoardTopic
  include DataMapper::Resource
  include Notifiable
  extend Wio::Model
  
  property :discussion_board_topic_id, Serial
  property :title, String
  
  belongs_to :creator, :class_name => "User"
  belongs_to :discussion_board
  belongs_to :notification
  has n, :discussion_board_posts
  
  validates_present :title

  
  before :destroy do
    self.discussion_board_posts.all.each do |post|
      post.destroy
    end
  end
  
end
