#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'


# require all configurations, controllers and models
acquire __DIR__/:config/'*'
acquire __DIR__/:model/'*'
acquire __DIR__/:helper/'*'
acquire __DIR__/:controller/'*'

class Wio::Cron

  class << self
    def start(interval = 10, times = nil)
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
  
  end
  
end

puts '.......'
Wio::Cron.start
