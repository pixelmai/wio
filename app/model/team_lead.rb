=begin
require 'model/team_member'

class TeamLead < TeamMember
  include DataMapper::Resource
  
  belongs_to :team
end
=end

