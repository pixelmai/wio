require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'delegate'
# Adds in useful methods to classes that include DataMapper::Resource.
module DataMapper
  module Resource
    module ClassMethods
      # Acts just like all, but gives only a particular page of data. The returned collection
      # has an extra total_pages method that tells you how many pages worth of data are in the
      # repository.
      #
      # The order param should be an array of properties to order by as per usual DM standards.
      # The conditions param should be a hash of standard DM options to restrict the data.
      #
      # Examples:
      #
      # # Get page 2, 10 items per page, ordering by name then size (descending).
      # foos = Foo.all_paged 2, 10, [:name, :size.desc]
      #
      # # Get page 1, 10 items per page, where age greater than 30.
      # foos = Foo.all_paged, 1, 10, [:name], {:age.gt => 30}
      # foos.total_pages #=> 3, assuming between 21 and 30 foos with age greater than 30.

      def all_paged(page, page_size, conditions = {})
        # Get all, but with options set for just the specific page, plus user specified conditions.
        offset = (page.to_i - 1) * page_size
        options = {:offset => offset, :limit => page_size}
        options.merge!(conditions)
        data = self.all options

        # Determine total number of pages and add a total_pages method to the data object.
        total_pages = alltotal_pages(page_size, conditions)
        data.instance_eval "def total_pages; #{total_pages}; end"
        data
      end

      # Return total number of pages of a given size.
      # A conditions hash (in standard DM form) can be specified.

      def alltotal_pages(page_size, conditions = {})
        item_count = self.count conditions
        (item_count + (page_size - 1)) / page_size
      end
    end
  end
end

require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'

# setup the database properly
DataMapper.setup(:default, 'mysql://wio:wio@localhost/wio')


# Hack for problems with many-to-many
module Wio

  class DMCollection < DelegateClass(DataMapper::Collection)
    def initialize(obj, allow_duplicates = false)
      @___ops = {}
      @___ops[:allow_duplicates] = allow_duplicates
      super(obj)
    end
    
    def <<(el)
      super(el) if ((not el.in? self) ||  @___ops[:allow_duplicates])
    end
  end

  module Model
    
    def whas(prop, options)
      prop = prop.to_s
      ck = options[:child_key] || []
      sprop = (ck[0] || options[:class_name] || prop).to_s.downcase.gsub(/s$/, '')
      j = options[:through].to_s
      j_call = "#{j}.#{sprop}"
      
      definition = "
        def #{prop}
          unless @#{prop} 
            @#{prop} = Wio::DMCollection.new(#{j_call}, #{(options[:allow_duplicates] || 'false').to_s })
            @#{prop}__original = Array.new(@#{prop})
          end
          @#{prop}
        end
        
        before :save do
          #{prop} unless @#{prop}
          ts = #{j_call}
          
          id = #{j_call}.key[0].inspect.gsub(/^[^:]+:[^:]+:/, '').gsub('>', '')
          sym = ('#{sprop}_'+id).to_sym
          
          ts.each do |t|
            unless t.in? @#{prop}
              r = #{j}.first(sym => t.key[0])
              #{j}.delete r
              r.destroy if r
            end
          end
          @#{prop}.each do |t|
            #{j}.new(sym => t.key[0]) unless t.in? ts
          end
        end
      "
      puts definition
      self.class_eval definition 
    end
    
  end
  
end
