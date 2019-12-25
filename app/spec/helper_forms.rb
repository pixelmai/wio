#require 'ramaze'
#require 'ramaze/spec/helper'

# require all configurations, controllers and models
require '../helper/forms'
require '../helper/spec'

describe Wio::Helper::Forms do
  
  before do
    @h = Wio::Helper::Forms
  end
  
  it 'should create input element' do
    @h.input('text', 'foo').should.
      match_html_tag('input', {:type=>'text', :name=>'foo'}, :empty)
  end

  it 'should create input element with attributes' do
    @h.input('password', 'bar', {:value=>'foo'}).should.
      match_html_tag('input', {
        :type=>'password', :value=>'foo', :name=>'bar'
      }, :empty)
  end
  
  it 'should create textarea element' do
    @h.textarea('foo').should.
      match_html_tag('textarea', {:name=>'foo'})
  end
  
  it 'should create textarea element with value' do
    @h.textarea('bar', {:value => 'Foo'}).should.
      match_html_tag('textarea', {:name=>'bar'}, 'Foo')
  end

  it 'should create label element' do
    @h.label('Foo', 'bar').should.
      match_html_tag('label', {:for=>'bar'}, 'Foo')
  end
  
  it 'should create option field' do
    @h.option('foo').should.
      match_html_tag('option', {:value=>'foo'}, 'foo')
  end
  
  it 'should create option field selected' do
    @h.option('bar', true).should.
      match_html_tag('option', {:value=>'bar', :selected=>'selected'}, 'bar')
  end
  
  it 'should create option field with custom Label' do
    @h.option('foo', false, 'Bar').should.
      match_html_tag('option', {:value=>'foo'}, 'Bar')
  end
  
  it 'should create select fields' do
    @h.select('foo', {1 => 'bar', 2 => 'dis'}).should.
      match_html_tag('select', {:name=>'foo'}, [
        "\n", ['option', {:value=>1}, 'bar'],
        "\n", ['option', {:value=>2}, 'dis'], "\n"
      ])
  end
    
  it 'creates select field with selected field' do
    @h.select('bar', {'a' => 'foo', 'b' => 'choo', 'c' => 'wee'}, 'b').should.
      match_html_tag('select', {:name=>'bar'}, [
        "\n", ['option', {:value=>'a'}, 'foo'],
        "\n", ['option', {:value=>'b', :selected=>'selected'}, 'choo'],
        "\n", ['option', {:value=>'c'}, 'wee'], "\n"
      ])
  end
  
  it 'creates select field from range' do
    @h.select('wee', 20..23).should.
      match_html_tag('select', {:name=>'wee'}, [
        "\n", ['option', {:value=>20}, 20],
        "\n", ['option', {:value=>21}, 21],
        "\n", ['option', {:value=>22}, 22],
        "\n", ['option', {:value=>23}, 23], "\n"
      ])
  end
  
  it 'creates select field from range with a selected field' do
    @h.select('wee', 20..23, 23).should.
      match_html_tag('select', {:name=>'wee'}, [
        "\n", ['option', {:value=>20}, 20],
        "\n", ['option', {:value=>21}, 21],
        "\n", ['option', {:value=>22}, 22],
        "\n", ['option', {:value=>23, :selected=>'selected'}, 23], "\n"
      ])
  end

  it 'can create fieldsets' do
    @h.fieldset('foos', 'contents').should.
      match_html_tag('fieldset', {}, [
        "\n", ['legend', {}, [['span', {}, 'foos']] ],
        "\n"+'contents'
      ])
  end
  
  it 'can create a checkbox' do
    @h.checkbox(:foo, 'bar').should.
      match_html_tag('input', { 
        :type=>'checkbox', :value=>'bar', :name=>'foo'}, :empty)
  end

end
