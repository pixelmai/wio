=begin
require 'hpricot'

class String 
  def match_html_tag?(tag_name, attribs = {}, content = [])
    if tag_name.class == Array
      attribs = tag_name[1] unless tag_name.length < 2
      content = tag_name[2] unless tag_name.length < 3
      tag_name = tag_name[0]
    end
    compare = strip
    doc = Hpricot.XML(compare)
    
    syntax_error_message = 'Html tag syntax problems with "' + compare + '".';
    # match the number of elements 'root' elements
    # if more than one, there must be a problem
    should.flunk syntax_error_message unless doc.children.length == 1
    
    el = doc.children.first
    
    # match the root tag
    begin
      should.flunk 'Element tag name did not match. "' + 
        el.name + '" not equal to"' +
        tag_name + '".' unless el.name == tag_name
    rescue NoMethodError
      should.flunk syntax_error_message
    end
    
    # match the number of attributes
    # el.attributes.length.should == attribs.length 
    unless el.attributes.length == attribs.length
      should.flunk 'Number of attributes did not match. ' + 
        "Expecting #{attribs.length} but found #{el.attributes.length}"
    end
    
    # match each attribute with the actual values
    attribs.each do |k,v|
      should.flunk "Attribute '#{k}' is missing." unless el.has_attribute?(k)
      unless el.get_attribute(k).to_s == v.to_s
        should.flunk "Attribute '#{k}' is not '#{v}'. Found '#{el.get_attribute(k)}'"
      end
    end
    
    # match content
    if content == :empty
      unless compare =~ /[^\/>][\s]*\/>$/
        should.flunk "Element #{tag_name} is not in empty form. #{compare}"
      end
    elsif content.class == Array
      unless content.length == el.children.length
        should.flunk "Number of child elements of #{tag_name} expected #{content.length} "+
          "but found #{el.children.length}"
      end
      content.each_index do |i|
        unless content[i].to_s == el.children[i].to_s or el.children[i].to_s.match_html_tag?(content[i])
          should.flunk "Element #{i} content does not match #{content[i]}." 
        end
      end
    else
      unless content.to_s == el.children.first.to_s
        should.flunk "Element content does not match #{content.to_s}. Found #{el.children.first}" 
      end
    end
    
    return true
  end
end
=end
