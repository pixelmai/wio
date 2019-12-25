class Calendar
  include DataMapper::Resource
  
  property :calendar_id, Serial
  
  belongs_to :user
  has n, :calendar_events
end
