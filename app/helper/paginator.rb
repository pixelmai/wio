module Wio
  module Helper
    module Paginator
      
      class Page
        attr_reader :model, :current, :items_per_page
        
        def initialize(model, items_per_page, options = {})
          @options = options
          @items_per_page = items_per_page
          @model = model
          @request = Ramaze::Request.current
          @current = (@request[:page] || 1).to_i
        end
        
        def data
          unless @data
            @data = @model.all_paged(@current, @items_per_page)
            @total_pages = @data.total_pages
          end
          @data
        end
        
        def total_pages
          data unless @total_pages
          @total_pages
        end
        
        def navigation(show_edges = nil)
          #show_edges = true if show_edges.nil?
          str = ''
          if (current > 1)
            str << "<a href='?page=1'>First</a> <a href='?page=#{current - 1}'>Prev</a>";
          else
            str << '<span>First</span> <span>Prev</span>'
          end
          
          (1..total_pages).each do |p|
            if (current == p)
              str << " <strong>#{p}</strong>"
            else
              str << " <a href='?page=#{p}'>#{p}</a>"
            end
          end
          if (current < total_pages)
            str << " <a href='?page=#{current + 1}'>Next</a> <a href='?page=#{total_pages}'>Last</a>";
          else
            str << ' <span>Next</span> <span>Last</span>'
          end
          str
        end
      end
      
      private
      
      def paginate(model, items_per_page = 10, options = {})
        Page.new model, items_per_page, options
      end
      
    end
    
    
  end
end
