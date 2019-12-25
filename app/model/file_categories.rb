class FileCategory
  include DataMapper::Resource
  
  property :file_category_id, Serial
  property :name, String
  
  belongs_to :user
  has n, :uploaded_files  
  validates_present :name
  validates_is_unique :name, {:scope=>:user}
  
  
  before :destroy do   
    user.uploaded_files.all({UploadedFile.file_category.file_category_id => self.file_category_id}).each do |file|
      file.file_category = user.file_categories.first({:name => 'uncategorized'})
      file.save
    end
  end
  
end
