require __DIR__/:team_to_user_request

class InviteUserRequest < TeamToUserRequest
  include Ramaze::Helper::CGI
  
  def message_html
    
    "<a href='/teams/#{u(from_team.name)}'>#{h(from_team.name)}</a>
        would like you to be a member.
        <a href='#{accept_url}'>Accept</a> |
        <a href='#{ignore_url}'>Ignore</a> "
  end
  
  def message_email
    "#{from_team.name} would like you to be a member.
      Go to your wio <a href='/wio/my_account/requests'>requests page</a> to confirm."
  end
  
  def message_sms
    "#{from_team.name} would like you to be a member. Visit your
      requests page to confirm"
  end
  
  def message_accept_html
    "You are now a member of
      <a href='/teams/#{u(from_team.name)}'>#{from_team.name}</a>."
  end
  
  def message_ignore_html
    "You denied the membership invitation from
      <a href='/teams/#{u(from_team.name)}'>#{from_team.name}</a>."
  end
  
  def initialize(frum, to)
    self.from_team = frum
    self.user = to
    self.request_notification = Notification.new(
      :recipient_user => user,
      :message => message_html
    )
  end
  
  def do_accept
    # puts 'doing accept logic...'
    # TODO: Ask DataMapper group about this curiousity
    x = User.get user.username
    t = Team.get from_team.name
    t.members << x
    if t.save
      confirmation_notification = Notification.new(
        :recipient_user => t.team_lead,
        :message => "#{x.username} has accepted your membership invitation for #{t.name}."
      )
    else
      puts 'noooo'
      puts t.errors.full_messages.to_s
    end
  end
  
  
end
