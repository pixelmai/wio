class FileSharing
  include DataMapper::Resource
  
  belongs_to :shared_with_user, :class_name => "User"
  belongs_to :uploaded_file
end
