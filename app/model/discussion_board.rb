class DiscussionBoard
  include DataMapper::Resource
  
  property :discussion_board_id, Serial
  
  belongs_to :team
  has n, :discussion_board_topics

  before :destroy do
    self.discussion_board_topics.all.each do |topic|
      topic.destroy
    end
  end
  
end
