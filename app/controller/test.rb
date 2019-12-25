class TestController < Ramaze::Controller
  
  layout '/page' #=> [ :index, :new ]
  deny_layout :foo
  helper :form
  
  include Wio::Helper::Scaffold
  helper :aspect
  #helper :partial
  
  before_all do
    @main_location = 'Testing'
  end
  
  def index
    response = Ramaze::Response.current
    #response.header['Content-type'] = 'text/plain'
    p = User.get(:wio)
    @form = create_form(User, {
      :action => '/login',
      :id     => 'login',
      :values => p
    })
    @bar = 'Did I say you want me?'
  end
  
  def foo
    @bar = 'Take all of your problems and rip them apart'
  end

end

