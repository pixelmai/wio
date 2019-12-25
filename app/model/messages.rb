class Message
  include DataMapper::Resource
  
  property :message_id, Serial
  property :subject,    String
  property :content,    Text
  property :date_sent,  DateTime
  property :read,       Boolean, :default => :false
  property :draft,      Boolean, :default => :true
  property :sent,       Boolean, :default => :false
  property :notice,     Boolean, :default => :false
  
  belongs_to :user
  belongs_to :sender, :class_name => 'User', :child_key => [:sender_username]
  belongs_to :recipient, :class_name => 'User', :child_key => [:recipient_username]
  validates_present :sender, :user
  
  def hash_of_properties
    h = {}
    [
      :subject, :sender, :recipient, :content,
      :draft, :date_sent, :sent, :notice
    ].each do |p|
      h[p] = method(p).call
    end
    h
  end
  
  def copy_to(owner)
    owner.messages.new(hash_of_properties)
  end
  
  def read?
    read
  end

  def send_it
    self.sender = user
    self.date_sent = DateTime.now
    self.draft = false
    self.sent = true
    save
    #user.save
    if recipient.is_a? User
      copy = copy_to(recipient)
      puts copy
      
      if copy.save
        puts recipient
        return true
      else
        puts 'recipient ' + recipient.errors.full_messages
        false
      end
      puts 'recipient errors ' + recipient.errors.full_messages
      false
    else
      puts 'recipient ' + recipient.inspect
      false
    end
  end

  def send_to(receiver)
    self.sender = user
    self.recipient = receiver
    send_it
  end
end
