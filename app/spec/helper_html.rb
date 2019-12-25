#require 'ramaze'
#require 'ramaze/spec/helper'

# require all configurations, controllers and models
require '../helper/forms'
require '../helper/spec'

describe Wio::Helper::Html do
  
  before do
    @h = Wio::Helper::Html
  end
  
  it 'creates start tag' do
    @h.start_tag('p').should == '<p'
  end
  
  it 'creates start tag with attributes' do
    @h.start_tag('p', {:id => 'foo', :class => 'bar'}).
      should == '<p class="bar" id="foo"'
  end
  
  it 'creates empty element' do
    @h.empty_element('br').should.match_html_tag('br', {}, :empty)
  end
  
  it 'creates empty element with attributes' do
    #@h.empty_element('br', {:id=> 'foo', :clear => 'both'}).
    #  should == '<br clear="both" id="foo" />'
    @h.empty_element('br', {:id=> 'foo', :clear => 'both'}).
      should.match_html_tag('br', {:id=> 'foo', :clear => 'both'}, :empty)
  end
  
  it 'creates non-empty element' do
    @h.element('div').should.match_html_tag('div');
  end
  
  it 'creates non-empty element with attributes' do
    @h.element('h1', {:id=>'bar', :class=>'foo'}).
      should.match_html_tag('h1', {:id=>'bar', :class=>'foo'});
  end
  
  it 'creates non-empty element with value' do
    @h.element('h1', {:contents => "The quick brown"}).
      should.match_html_tag('h1', {}, ['The quick brown'])
  end
end
