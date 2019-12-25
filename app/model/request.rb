class Request
  include DataMapper::Resource
  
  property :request_id, Serial
  property :accepted, Boolean, :default => false
  property :ignored, Boolean, :default => false
  property :has_not_been_accepted_before, Boolean, :default => true
  property :new, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :type, Discriminator
  
  belongs_to :request_notification, :class_name => 'Notification',
             :child_key => [:request_notification_id]
  belongs_to :confirmation_notification, :class_name => 'Notification',
             :child_key => [:confirmation_notification_id]
  
  belongs_to :team
  belongs_to :from_user, :class_name => 'User', :child_key => [:from_username]
  belongs_to :user
  belongs_to :from_team, :class_name => 'Team', :child_key => [:from_team_name]
  
  before :save do
    if has_not_been_accepted_before and accepted
      send_confirmation_notification if confirmation_notification
      self.has_not_been_accepted_before = false
    end
    if new
      send_request_notification if request_notification
      new = false
    end
  end
  
  def accept_url
    "/my_account/requests/#{self.request_id}/accept"
  end
  
  def ignore_url
    "/my_account/requests/#{self.request_id}/ignore"
  end
  
  def do_accept
    # please define in inheriting class
  end
  
  def do_ignore
    # please define in inheriting class
  end
  
  def accept
    puts 'accepting...'
    unless ignored
      do_accept
      self.accepted = true
      puts errors.full_messages unless save
    else
      puts 'Cannot accept a request that has been ignored.'
      raise Exception
    end
  end
  
  def ignore
    do_ignore
    self.ignored = true
    puts errors.full_messages unless save
  end
  
  def send_request_notification
    request_notification.send_it
  end
  
  def send_confirmation_notification
    confirmation_notification.send_it
  end
  
  # Custom Finders
  
  def self.latest(options={})
    all options.merge({
      :order => [:created_at.desc],
      :accepted => false,
      :ignored => false
    })
  end
  
end
