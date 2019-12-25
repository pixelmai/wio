unless self.class.const_defined? 'Ramaze'
  require 'rubygems'
  require 'ramaze'
  require File.expand_path('../../ramaze-irb.rb')
end

module Wio
  class SMSQL
    def execute(cmd)
      'lalala'
    end
  end
  
  class SMSQLCommander
    
    class << self
      def execute(number, cmd = {})
        number = Gnokii.denormalize(number + '')
        #puts "\nxxxxxxxxxxxxxxxxxxxxxxx"
        #puts number
        u = User.first(:mobile_number => number)
        if u.nil?
          #puts 'here...'
          u = User.first(:mobile_number => Gnokii.flip_number_format(number + ''))
        end
        #puts number
        
        if cmd.nil?
          return
        end
        
        return nil if u.nil?
        #puts u.username
        
        case cmd[:command]
          when :tasks
            options = {:completed => false}
            
            options['context.name.like'] = cmd[:context] if cmd[:context]
            
            if (cmd[:deadline] && cmd[:deadline] == :today)
              options[:deadline] = Date.today
            elsif (cmd[:deadline] && cmd[:deadline] == :tomorrow)
              options[:deadline] = Date.today + 1
            end
            
            tasks = u.tasks(options)
            output = "(#{tasks.count}) Tasks:"
            tasks.each do |t|
              output += "\n-#{t.name}(#{t.task_id})"
            end  

          when :completed
            options = {:completed => true, :order=>[:date_completed.desc], :limit=>5}
            
            tasks = u.tasks(options)
            output = "(#{tasks.count}) Completed Tasks:"
            tasks.each do |t|
              output += "\n-#{t.name}(#{t.task_id})"
            end          
            
          when :done
            options = {}
            if cmd[:id] and (cmd[:id].to_i>0)
              options[:task_id] = cmd[:id]
              task = u.tasks.first(options)
              if task
                task.completed = true
                u.save
                unless task.save
                  puts task.error.full_messages
                end
                output = "Task '#{task.name}' (#{task.task_id}) is completed"
              else
                output = "You have no tasks like that (id = #{cmd[:id]})"
              end
            else
              output = "Invalid ID, must be an integer"
            end
            
          when :task
            options = {}
            if cmd[:id] and cmd[:id].to_i>0
              options[:task_id] = cmd[:id]
              task = u.tasks.first(options)
              if task
                output = "Name: #{task.name}"
                if task.deadline
                  output += "\nDue: #{task.deadline.strftime("%m/%d/%y")}"
                end
                if task.description
                  output += "\nDescription: #{task.description}"
                end
              else
                output = "You have no tasks like that (id = #{cmd[:id]})"
              end
            else
              output = "Invalid ID, must be an integer"
            end
            
            
          when :new
            options = {}
            options[:name] = cmd[:name] if cmd[:name]
            task = u.tasks.new(options)
            if cmd[:context]
              context = u.contexts.first(:name.like => cmd[:context])
              unless context
                return output = "Unable to add task '#{task.name}'. Context '#{cmd[:context]}' not found"
              end
              task.context = context
            end
            task.save
            output = "Task '#{task.name}' (#{task.task_id}) has been added"
          when :projects
            options = {:status=>1}
            projects = u.projects(options)
            output = "(#{projects.count}) Projects:"
            projects.each do |p|
              output += "\n-#{p.name}(#{p.project_id})"
            end   
          when :project
            options = {:progress.lt=>100}
            if cmd[:id] and cmd[:id].to_i>0
              options[:project_project_id] = cmd[:id]
              tasks = u.tasks.all(options)
              
              output = "(#{tasks.count}) Proj. Tasks:"
              if tasks
                tasks.each do |t|
                output += "\n-#{t.name}(#{t.task_id})"
                end   
              else
                output = "You have no projects like that (id = #{cmd[:id]})"
              end
            else
              output = "Invalid ID, must be an integer"
            end
          when :events
            options = {:start_date.gte=>Date.today}
            events = u.calendar.calendar_events(options)
            output = "(#{events.count}) Events:"
            events.each do |e|
              output += "\n-#{e.name}"
            end   
          when :requests
            options = {}
            requests = u.requests.latest
            output = "(#{requests.count}) Contact Requests:"
            requests.each do |r|
              output += "\n-#{r.from_username}"
            end               
          when :help
            output = "WIO Codes p.1"
            output += "\nTasks @[context_name] - lists tasks (context-optional)"
            output += "\nToday - tasks today"
            output += "\nTom - tasks tomorrow"
            output += "\nHelp2 - continue..."
          when :help2
            output = "p.2\nTask #[id] - Details for task #id"
            output += "\nDone #[id] - Completes task #id"
            output += "\nNew \"msg\" @[context_name] - Quick add task (context-optional)"
            output += "\nHelp3 - cont... "     
          when :help3
            output = "p.3\nProjects @[proj_id]-list project tasks"  
            output += "\nCompleted - completed tasks"
            output += "\nCompleted - completed tasks" 
            output += "\nEvents - current events"   
            output += "\nRequests - contact requests"   
          else
            output = "Please check your syntax and try again."      
          end
        #puts ''
        output = output[0..159]
        output
      end
    end
    
  end
  
  class Gnokii
    
    class << self
      
      def normalize(number)
        n = number
        if (n[0, 1] == '0')
          n[0,1] = '3'
          n = '6' + n
        end
        n
      end
      
      def denormalize(number)
        n = number.gsub('+', '')
        if (n.match(/^[+]?63/))
          n.gsub!('63', '0')
        end
        n
      end
      
      def flip_number_format(number)
        n = number
        if (n.match(/^[+]?63/))
          denormalize(n)
        else
          normalize(n)
        end
      end
      
      def total_messages
        parse_smsfolderstatus(`gnokii --showsmsfolderstatus`)
      end
      
      def getsms(n)
        str = `gnokii --getsms SM #{n} -d`
        return parse_getsms(str) if str
        {}
      end
      
      def sendsms(msg)
        puts "Sending message..."
        cmd = "echo \"#{msg[:text]}\" | gnokii --sendsms #{msg[:to]}"
        `#{cmd}`
      end
      
      def parse_smsfolderstatus(str)
        total = str.match(/SM\s+(\d+)\n/)[1].to_i
        #unread = str.match(/	Unread messages:\s+([\d]+)/)[1].to_i
      end
      
      def parse_getsms(str)
        if str.match(/([\d])\./)
          id = str.match(/([\d])\./)[1].to_i
          sender = str.match(/\nSender:\s+([\d+]+)\sMsg/)[1]
          
          if str.match(/\nText:\n([\w\W]+)\n/)
            text = str.match(/\nText:\n([\w\W]+)\n/)[1]
          else
            text = "empty"
          end
          
        end
        if id
          puts "============="
          puts str
          puts "-------------"
          puts sender
          puts "============="
          {:id => id, :sender => sender, :text => text}
        else
          {}
        end
      end
      
      def parse_deletesms(str)
        success = true
        id = str.match(/Deleted SMS SM (\d+)/)[1].to_i
        {:success => success, :id => id}
      end
    end
  end
  
  class SMSQLServer
    class << self
      
      def start(interval = 2, times = nil)
        @@stop = false
        i = 0;
        puts 'Starting SMSQLServer...'
        loop do
          
          checknotify()
          
          messages = []
          total = Gnokii.total_messages
          puts total
          if (total > 0)
            total.downto(1) do |n|
              message = Gnokii.getsms(n)
              if (message[:id])               
                response = {}
                response[:text] = SMSQLCommander.execute(
                  message[:sender],
                  SMSQLParser.parse(message[:text])
                )
                
                if SMSQLParser.parse(message[:text]).nil?
                  response[:text] = 'Please check your syntax and try again.'
                end
                
                response[:to] = message[:sender]
                Gnokii.sendsms(response) if response[:text]
                messages << message
              end
            end
          end
          messages.each do |m|
            m.each do |k,v|
              print "#{k}: #{v}\n"
            end
          end
          i += 1
          break if (@@stop || times == i)
          sleep interval
          
        end
      end
      
      def stop
        @@stop = true;
      end
      
      def shutdown
        puts 'goodbye...'
      end
      
      def checknotify
        puts 'Checking Queu...'
        to_send = Notification.all(
          :sent => false,
          :when.lt => DateTime.now
        ).concat(
          Notification.all(:sent => false, :when => nil)
        )
        total = to_send.length
        if (total > 0)
          to_send.each do |n|
            n.send_it
          end
        end
      end
=begin      
      def startnotifications(interval = 10, times = nil)
        @@stop = false
        i = 0;
        puts 'Starting Cron...'
        loop do
          puts 'Checking Queu...'
          to_send = Notification.all(
            :sent => false,
            :when.lt => DateTime.now
          ).concat(
            Notification.all(:sent => false, :when => nil)
          )
          total = to_send.length
          if (total > 0)
            to_send.each do |n|
              n.send_it
            end
          end
          i += 1
          break if (@@stop || times == i)
          sleep interval
          
        end
      end
=end
    end
  end
  
  
  
  class SMSQLParser
    
    @@keywords = {
      'tomorrow' => [:deadline, :tomorrow],
      'tom'      => [:deadline, :tomorrow],
      'today'    => [:deadline, :today],
      'tasks'    => [:command, :tasks],
      'task'    => [:command, :task],
      'new'      => [:command, :new],
      'projects' => [:command, :projects],
      'project' => [:command, :project],
      'done'     => [:command, :done],
      'events'  => [:command, :events],
      'requests'  => [:command, :requests],
      'completed'  => [:command, :completed],
      'help'  => [:command, :help],
      'help2'  => [:command, :help2],
      'help3'  => [:command, :help3],
    }
    
    class << self
      
      def parse(cmd)
        instructions = {}
        cmd = segmentize(cmd)
        #instructions[:command] = :tasks
        cmd.each do |s|
          ar = identify_segment(s)
          instructions[ar[0]] = ar[1] if ar
        end
        
        
        if instructions.empty?
          nil
        else
          instructions[:command] = :tasks unless instructions[:command]
          #instructions[:raw] = cmd
          instructions
        end
        
      end
      
      private
      
      def identify_segment(str)
        if @@keywords.include?(str.downcase)
          return @@keywords[str.downcase]
        else
          #return [:id, str.sub(':', '')] if str[0,1] == ':'
          return parse_coloned_string(str) if str[0,1] == ':'
          return [:context, str.sub('@', '')] if str[0,1] == '@'
          return [:id, str.sub('#', '')] if str[0,1] == '#'
          #return [:id, str.to_i] if str.to_i > 0
        end
      end
      
      def segmentize(str)
        str = str.gsub(/'([^']+)'/){|s| ':'+"#$1".gsub(/\s/, '_')}
        str = str.gsub(/"([^"]+)"/){|s| ':'+"#$1".gsub(/\s/, '_')}
        str.strip.gsub(/\s/, ' ').squeeze(' ').split(/\s/)
      end
      
      def parse_coloned_string(str)
        [:name, str.sub(':', '').gsub('_', ' ')]
      end
      
    end
    
  end
end
