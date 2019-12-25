module Wio
  module Helper
    
    module Session
      
      private
      
      def check_session
        if session[:username].nil? and not session[:logged_in]
          flash[:error] = "Please login first"
          redirect '/'
        end
      end
      
      def check_admin_session
        if session[:username].nil? and not session[:logged_in] and not session[:username] == 'admin'
          flash[:error] = "Please login first"
          redirect '/'
        end   
      end
      def logged_in?
        not session[:username].nil?
      end
      
    end
    
  end
end
