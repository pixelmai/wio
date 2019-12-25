class User
  include DataMapper::Resource
  # TODO: change this to recommended pattern once this is fixed
  extend Wio::Model # fix for many_to_many associations
  
  property :username,          String, :key => true
  property :password,          String
  property :email_address,     String
  property :last_name,         String
  property :first_name,        String
  property :middle_name,       String
  property :address,           Text
  property :mobile_number,     String, :length => 12
  property :home_phone_number, String, :length => 7
  property :work_phone_number, String, :length => 7
  property :birth_date,        Date
  property :logged_in,         Boolean, :default => :false
  property :created_at,        DateTime
  property :updated_at,        DateTime
  property :banned,            Boolean, :default => :false
  
  attr_accessor :password_confirmation
  
  validates_is_unique :username, :email_address
  validates_present :password, :email_address
  # This will not validate unless :password == :password_confirmation
  validates_is_confirmed :password
  validates_format :email_address, :as => :email_address
  
  has 1, :calendar
  has n, :file_categories
  has n, :uploaded_files
  has n, :file_sharings
  
  has n, :contexts
  has n, :tasks
  has n, :created_tasks, :through => :tasks, :remote_name => :creator
  has n, :assigned_tasks, :through => Resource, :class_name => 'Task'

  has n, :projects
  def created_projects
    projects
  end
  has n, :assigned_projects, :through => Resource, :class_name => 'Project'
  
  # the following relationships are for contacts
  has n, :contacted_users
  #has n :contacts, :through => :contacted_users, :class_name =>
  
  has n, :teams, :through => Resource
  
  has n, :lead_teams, :class_name => 'Team'
  has n, :discussion_board_posts
  has n, :discussion_board_topics
  
  # Messages
  has n, :messages
  has n, :received_messages, :class_name => 'Message',:child_key => [:recipient_username] #:remote_name => :recipient
  has n, :sent_messages, :class_name => 'Message', :child_key => [:sender_username] #:remote_name => :sender
  
  has n, :requests
  has n, :sent_requests, :class_name => 'Request', :child_key => [:from_username]
    #:remote_name => :from_user
  
  after :save do
    must_save = false
    if self.contexts.first({:name => 'uncategorized'}).nil?
      self.contexts.new({:name => 'uncategorized'})
      must_save = true
    end
    
    if self.file_categories.first({:name => 'uncategorized'}).nil?
      self.file_categories.new({:name => 'uncategorized'})
      must_save = true
    end
    
    if self.calendar.nil?
      self.calendar = Calendar.new
      must_save = true
    end
    save if must_save
  end
  
  def contacts
    unless @contacts
      @contacts = contacted_users.all(:user_username => username).contact
      @contacts_orig = Array.new(@contacts)
    end
    @contacts
  end
  
  before :save do
    contacts unless @contacts
    
    @contacts.each do |t|
      unless t.in? @contacts_orig
        contacted_users.new(:contact_username => t.username)
        t.contacted_users.new(:contact_username => username)
        @add_contact_to_other_record_too = [] unless @add_contact_to_other_record_too
        @add_contact_to_other_record_too << t
      end
    end
  end
  
  after :save do
    if @add_contact_to_other_record_too
      @add_contact_to_other_record_too.each do |t|
        t.save
      end
    end
    
    @contacts_orig.each do |t|
      contacts unless @contacts
      unless t.in? @contacts
        [
          ContactedUser.first(:contact_username => t.username, :user_username => username),
          ContactedUser.first(:contact_username => username, :user_username => t.username)
        ].each do |r|
          contacted_users.delete r
          @contacts_orig.delete r
          r.destroy if r
        end
      end
    end
    @contacts = nil
  end
  
  def contacts_original
    @contacts__original
  end
  
  # Custom Finders
  def self.newest(options={})
    all :order => [:created_at.desc]
  end

end
