require __DIR__/:user_to_team_request

class JoinTeamRequest < UserToTeamRequest
  include Ramaze::Helper::CGI
  
  def message_html
    puts from_user
    "<a href='/people/#{u(from_user.username)}'>#{h(from_user.username)}</a>
        would like to be a member of 
     <a href='/teams/#{u(team.name)}'>#{h(team.name)}</a>.
        <a href='#{accept_url}'>Accept</a> |
        <a href='#{ignore_url}'>Ignore</a> "
  end
  
  def message_email
    "#{from_user.username} would like to join #{h(team.name)}.
      Go to your wio <a href='/wio/my_account/requests'>requests page</a> to confirm."
  end
  
  def message_sms
    "#{from_user.username} would like to join #{h(team.name)}. Visit your
      requests page to confirm"
  end
  
  def message_accept_html
    "<a href='/people/#{u(from_user.username)}'>#{from_user.username}</a>
      is now a member of
      <a href='/teams/#{u(team.name)}'>#{h(team.name)}</a>."
  end
  
  def message_ignore_html
    "You denied the membership request of
      <a href='/people/#{u(from_user.username)}'>#{from_user.username}</a>
      from
      <a href='/teams/#{u(team.name)}'>#{h(team.name)}</a>."
  end
  
  def initialize(frum, to)
    self.from_user = frum
    self.team = to
    self.user = to.team_lead
    self.request_notification = Notification.new(
      :recipient_user => team.team_lead,
      :message => message_html
    )
  end
  
  def do_accept
    # puts 'doing accept logic...'
    # TODO: Ask DataMapper group about this curiousity
    x = User.get from_user.username
    t = Team.get team.name
    t.members << x
    if t.save
      confirmation_notification = Notification.new(
        :recipient_user => x,
        :message => "#{t.name} has accepted your membership request."
      )
    else
      puts 'noooo'
      puts t.errors.full_messages.to_s
    end
  end
  
  
end
