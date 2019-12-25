require __DIR__/:user_to_user_request

class AddContactRequest < UserToUserRequest

  def message_html
    "<a href='/people/#{from_user.username}'>#{from_user.username}</a>
        would like to be your contact.
        <a href='#{accept_url}'>Accept</a> |
        <a href='#{ignore_url}'>Ignore</a> "
  end
  
  def message_email
    "#{from_user.username} would like to be your contact.
      Go to your wio <a href='/wio/my_account/requests'>requests page</a> to confirm."
  end
  
  def message_sms
    "#{from_user.username} would like to be your contact. Visit your
      requests page to confirm"
  end
  
  def message_accept_html
    "<a href='/people/#{from_user.username}'>#{from_user.username}</a>
        is now one of your <a href='/my_account/contacts'>contacts.</a>"
  end
  
  def message_ignore_html
    "You denied the request from 
      <a href='/people/#{from_user.username}'>#{from_user.username}</a>."
  end
  
  def initialize(frum, to)
    self.from_user = frum
    self.user = to
    self.request_notification = Notification.new(
      :recipient_user => user,
      :message => message_html
    )
  end
  
  def do_accept
    puts 'doing accept logic...'
    # TODO: Ask DataMapper group about this curiousity
    x = User.get user.username
    y = User.get from_user.username
    x.contacts << y
    #y.contacts << x
    if x.save
      confirmation_notification = Notification.new(
        :recipient_user => y,
        :message => "#{x.username} has accepted you as a contact."
      )
    else
      puts 'noooo'
      puts x.errors.full_messages.to_s + y.errors.full_messages.to_s
    end
  end
  
  
end
