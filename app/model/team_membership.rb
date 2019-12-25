=begin
class TeamMembership
  include DataMapper::Resource
  
  property :team_membership_id, Serial
  property :created_at,        DateTime
  property :updated_at,        DateTime
  
  belongs_to :user
  belongs_to :team
end
=end


