require __DIR__/:forms
require __DIR__/:session
require __DIR__/:paginator

module Wio
  module Helper
    
    module General
    
      include Wio::Helper::Scaffold
      include Wio::Helper::Session
      include Wio::Helper::Paginator
      
      alias_method :old_initialize, :initialize
      
      def main_location
        if @main_location
          @main_location
        else
          false
        end
      end
      
      def sub_location
        if @sub_location
          @sub_location
        else
          false
        end
      end
      
      def __APP_PATH__
        File.expand_path(__DIR__/'..')
      end
    
      private
      
      def render_fragment(file, *params)
        render_template(
          Ramaze::Global.root + '/' + Ramaze::Global.view_root +
          '/' + file , *params
        )
      end
    end
    
  end
end
