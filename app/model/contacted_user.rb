class ContactedUser
  include DataMapper::Resource
  
  property :user_username, String, :key => true
  property :contact_username, String, :key => true

  belongs_to :user, :child_key => [:user_username]
  belongs_to :contact, :class_name => "User", :child_key => [:contact_username]

end
