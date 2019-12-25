class CalendarEvent
  include DataMapper::Resource
  include Notifiable
  
  property :calendar_event_id, Serial
  property :start_date, DateTime
  property :name, String

  belongs_to :notification
  
  # todo notification 
  belongs_to :calendar
  validates_present :name, :start_date
  
  
  # For Notifications
  def message_html
    
  end
  
  def message_email
    
  end
  
  def message_sms
    "#{self.name}\n#{self.start_date.strftime('%c')}"
  end
  
end
