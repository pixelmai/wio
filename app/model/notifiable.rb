module Notifiable
  def set_notification (n)
    puts 'churva'
    n.noted_class = self.class
    n.identifier = self.key[0]
    n.save
    self.notification = n
  end
  
  def message_html
    
  end
  
  def message_email
    
  end
  
  def message_sms
    
  end
end
