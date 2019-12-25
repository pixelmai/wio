class Task
  include DataMapper::Resource
  include Notifiable
  extend Wio::Model
  
  property :task_id, Serial
  property :name, String
  property :description, Text
  property :deadline, DateTime
  property :date_completed, DateTime
  property :created_at, DateTime
  property :progress, Integer, :length => 3, :default => 0
  property :completed, Boolean, :default => false
  
  #property :creator, Integer, :key => true
  
  belongs_to :creator, :class_name => "User"
  belongs_to :project
  belongs_to :team
  belongs_to :parent_task, :class_name => 'Task'
  has n, :child_tasks, :class_name => 'Task'
  
  belongs_to :notification
  belongs_to :context
  
  validates_present :name
  
  has n, :assigned_to, :through => Resource, :class_name => 'User'

  
  before :save do
    self.progress
    self.completed = true if self.progress == 100
    self.progress = 100 if self.completed
    self.date_completed = DateTime.now if self.completed
    puts self.creator.username
    puts 'completed ' + self.completed.to_s
    puts 'progress ' + self.progress.to_s
    if self.completed && (not self.child_tasks.empty?)
      self.child_tasks.each do |t|
        t.completed = true
        t.save
      end
    end
  end
  
  
  after :save do
    t = self
    self.assigned_to.reload
    @_used = [] unless @_used
    self.assigned_to.each do |u|
      if not ((u == self.creator) || Task.first(:task_task_id => self.task_id, :user_username => u.username) || (@_used.include? u))
        @_used << u
        c = Task.new({
          :name => t.name,
          :description => t.description,
          :deadline => t.deadline
        })
        c.creator = u
        c.assigned_to << u
        c.parent_task = t
        
        unless c.save
          puts c.errors.full_messages
        end
      end
    end
    
    if self.parent_task
      self.parent_task.completed = false unless self.completed
      puts self.parent_task.completed.to_s
      unless self.parent_task.save
        puts self.parent_task.errors.full_messages
      end
    end
    auto_create_defaults
  end
  
  
  after :destroy do
    unless self.child_tasks.empty?
      self.child_tasks.each do |t|
        t.destroy
      end
    end
  end
  
  
  def overdue?
    if self.deadline
      self.days_countdown < 0
    else
      false
    end
  end
  
  def days_countdown
    self.deadline_fraction.ceil
  end
  
  def days_overdue
    self.deadline_fraction.ceil.abs if self.overdue?
  end
  
  def deadline_fraction
    @deadline_fraction = self.deadline - Date.today unless @deadline_fraction
    @deadline_fraction
  end

=begin  
  def progress
    unless child_tasks.empty?
      psum = 0
      child_tasks.each {|c| psum += c.progress}
      r = psum / child_tasks.length
      @progress = (psum / child_tasks.length).ceil
    end
    @progress
  end
=end

  alias_method :old_completed, :completed
  
  def completed
=begin
    unless child_tasks.empty?
      completed = true if progress == 100
    end   
=end
    old_completed
  end

  # Custom Finders
  def self.due_today
    all(:deadline => Date.today)
  end
  
  def self.incomplete(options={})
    all({
      :completed => false, :deadline.not => nil,
      :order => [:deadline.asc]
    }.merge(options)).concat(all({
      :completed => false,:deadline => nil
    }.merge(options)))
  end
  
  def self.completed(options={})
    all({:completed => true, :order => [:date_completed.desc]}.merge(options))
  end
  
  # For Notifications
  def message_html
    
  end
  
  def message_email
    
  end
  
  def message_sms
    "#{self.name}\n#{self.description}"
  end
  
  private
  
  def auto_create_defaults
    must_save = false
    if self.assigned_to.empty?
      self.assigned_to << self.creator
      must_save = true
    end
    if self.context.nil?
      self.context = (
        self.assigned_to.first.contexts.first(:name =>'uncategorized') ||
        self.creator.contexts.first(:name => 'uncategorized')
      )
      must_save = true
    end
    save if must_save
    reload
  end
  
  
end
