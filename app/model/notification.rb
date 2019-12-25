class Notification
  include DataMapper::Resource
  
  property :notification_id, Serial
  property :when, DateTime
  property :message, Text
  property :mode, Enum[:none, :email, :cellphone, :both], :default => :none
  property :sent, Boolean, :default => false
  property :noted_class, Class
  property :identifier, String
  
  belongs_to :recipient_user, :class_name => 'User', 
              :child_key => [:recipient_username]
  
  
  def send_it
    case self.mode
      when :cellphone
        send_sms
      when :email
        send_email
      when :both
        send_sms
        send_email
    end
    
    self.sent = true
    save
  end
  
  def send_sms
    obj = self.noted_class.get(identifier) if self.noted_class
    if (obj && obj.message_sms)
      msg = obj.message_sms
    else
      msg = self.message
    end
    msg = {
      :text => msg,
      :to => self.recipient_user.mobile_number
    }
    puts 'Sending SMS Message'
    puts DateTime.now
    Wio::Gnokii.sendsms(msg)
  end
  
  def send_email
    puts '... sending email'
  end
end
