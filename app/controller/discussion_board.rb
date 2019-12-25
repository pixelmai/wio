class DiscussionBoardController < Ramaze::Controller
  
  layout '/page' #=> [ :index, :new ]
  map '/teams/board'
  include Wio::Helper::General
  helper :aspect
  helper :formatting
  
  before_all do
    @main_location = 'Teams'
    @me = User.get(session[:username])
  end
  
  after_all do
    flash.delete(:error) unless flash[:error]
    flash.delete(:confirm) unless flash[:confirm]
  end
  
  def index (team = nil, action = nil, type = nil, id = nil)
    if logged_in?
      if team
        if @team = Team.get(team)
          @title = @team.name + '\'s Discussion Board'
          @board = @team.discussion_board
          @topics = @board.discussion_board_topics
          @posts = @topics.discussion_board_posts
          @main_location = @team.name
          @sub_location = 'Discussion Board'
          @id = id 
          
          if id and type == 'topic'
            @topic = @topics.get(id)
          end
          
          if id and type == 'post'
            @post = @posts.get(id)
          end          
                    
          case action
            when nil
              if not @team.members.include? @me
                flash[:error] = 'You are not allowed to view this team\'s Discussion Board'
                redirect_to_team_home
              end
              @action = :view_board
              @sidebar = 'sidebar/teams/add_topic.xhtml'
              # paginate(model, items_per_page, options={})
              # See 'helper/paginator.rb'
              #@page = paginate(DiscussionBoardTopic, 10, {:discussion_board_id=>@board.discussion_board_id, :order=>[:discussion_board_topic_id.desc]})
              #@all_topics = @page.data
              
              
            #adding of values
            when 'add'
              if request.post?
                case type
                  when 'topic' 
                    
                    unless request[:contents].empty?
                      contents = request[:contents]
                    else
                      flash[:error] = "The topic post must not be blank."
                      redirect_to_team_board
                    end   
                                     
                    topic = @topics.new({
                      :title=>request[:title],
                      :user_username=>@me.username
                    })
                    
                    @team.members.each do |m|
                      if m.mobile_number
                        topic.set_notification(
                          Notification.new(
                            :message => 'Discussion Board Topic - (' + topic.title + ') has been added to Team ' + @team.name, 
                            :mode => :cellphone,
                            :recipient_user => m, 
                            :when => DateTime.now,
                            :sent => false
                          )
                        )
                      end
                    end  
                    
                    unless topic.save
                      flash[:error] = topic.errors.full_messages
                      redirect_to_team_board
                      false
                    else

                      flash[:confirm] = "The topic '#{topic.title}' has been added."
                      post = @posts.new({
                        :contents => contents,
                        :user_username => @me.username,
                        :discussion_board_topic_discussion_board_topic_id => topic.discussion_board_topic_id
                      })
                      unless post.save
                        flash[:error] = post.errors.full_messages
                        redirect_to_team_board
                      end
                      
                      redirect_to_team_board
                      true
                    end
                   
                  when 'post'
                    if id.nil?
                      puts redirect_to_team_board
                    end
                    
                    topic = @board.discussion_board_topics.get(id)
                    post = topic.discussion_board_posts.new({
                      :contents=>request[:contents],
                      :user_username=>@me.username
                    })
                    
                    unless post.save
                      flash[:error] = post.errors.full_messages
                      puts redirect_to_team_topic(@id)
                      false
                    else
                      flash[:confirm] = "You successfully replied on the topic."
                      redirect_referer
                      true
                    end                  
                  when nil
                    redirect_to_team_board
                end #case
              else
                redirect_to_team_board
              end
            when 'view'
              case type
                when 'topic'  
                  @sidebar = 'sidebar/teams/add_post.xhtml'
                  @title = 'Board Topic - ' + @topic.title
                  @action = :view_topic
                  @topic_posts = @topic.discussion_board_posts.all
                  puts @topic_posts
                when nil
                  redirect_to_team_board
              end
                
            when 'edit'
              case type
                when 'topic'  
                  @title = 'Edit Board Topic - ' + @topic.title
                  @action = :edit_board
                  @topic = @topics.get(id)
                  
                  if @topic.user_username != @me.username and @team.team_lead != @me 
                    redirect_to_team_board
                  end
                  
                  
                  if request.post?
                    if @topic
                      @topic.title = request[:title]
                    
                      unless @topic.save
                        flash[:error] = @topic.errors.full_messages
                        false
                      else
                        flash[:confirm] = "The topic '#{@topic.title}' has been updated."
                        redirect_to_team_board
                        true
                      end
                    else
                      redirect_to_team_board
                    end
                  end
                when 'post'
                  @title = 'Edit Board Post'
                  @action = :edit_post
                  id = @post.discussion_board_topic.discussion_board_topic_id
                  
                  if request.post?
                    if @post
                      @post.contents = request[:contents]
                      unless @post.save
                        flash[:error] = @post.errors.full_messages
                        false
                      else
                        flash[:confirm] = "The post has been updated."
                        redirect_to_team_topic(id)
                        true
                      end
                    else
                      redirect_to_team_topic(id)
                    end
                  end 
                when nil
                  redirect_to_team_board
              end
            when 'delete'
              case type
                when 'topic'  
                
                  if @topic.user_username != @me.username and @team.team_lead != @me 
                    redirect_to_team_board
                  end
                  
                  tname = @topic.title
                  unless @topic.destroy
                    flash[:error] = @topic.errors.full_messages
                    false
                  else
                    flash[:confirm] = "The topic '#{tname}' has been deleted."
                    redirect_to_team_board
                    true
                  end
                when 'post'  
                                 
                  id = @post.discussion_board_topic.discussion_board_topic_id
                  topic = @topics.get(id)
                  if topic.discussion_board_posts.all.length == 1
                    flash[:error] = 'Cannot delete last post'
                    redirect_to_team_topic(id)
                  end
                  
                  if @post.user_username != @me.username and @team.team_lead != @me 
                    redirect_to_team_topic(id)
                  end         
                  
                  unless @post.destroy
                    flash[:error] = @post.errors.full_messages
                    false
                  else
                    flash[:confirm] = "The post has been deleted."
                    redirect_to_team_topic(id)
                    true
                  end
              end
            else
              redirect_to_team_home
          end
        else #if team specified doesn't exist
          redirect '/teams'
        end
      else #if team wasn't specified at all
        redirect '/teams'
      end
    else
      redirect_to_team_home
    end
  end
  
  private
  
  def redirect_to_team_home
    redirect '/teams/' + u(@team.name)
  end
  
  def redirect_to_team_board
    redirect '/teams/board/' + u(@team.name)
  end
  
  def redirect_to_team_topic(tid = nil)
    redirect '/teams/board/' + u(@team.name) + '/view/topic/' + u(tid)
  end
  
end
