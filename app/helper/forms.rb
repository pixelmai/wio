
#todo find a way to namespace this snippet properly
class String
  def to_label
    split('_').map{|e| e.capitalize}.join(' ')
  end 
end

module Wio
  
  module CoreExtensions
    
  end

  module Helper
    
    module Html
      def Html.start_tag(name, attributes = {})
        attributes.inject("<#{name.to_s}"){|s,(k,v)| s << " #{k.to_s}=\"#{v.to_s}\"" }
      end
      
      def Html.empty_element(name, attributes = {})
        start_tag(name, attributes) + " />"
      end
      
      def Html.element(name, attributes = {})
        val = (attributes.key? :contents) ? attributes.delete(:contents) : ''
        start_tag(name, attributes) + '>' + val.to_s   + "</#{name}>"
      end
    end
    
    module Lists
      def Lists.li(contents, attributes={})
        attributes[:contents] = contents
        Html.element('li', attributes)
      end
      
      def Lists.ol(elements, attributes={})
        attributes[:value] = elements.map! {|e| li(e)}.join
        Html.element('ol', attributes )
      end
      
      def Lists.ul(elements, attributes={})
        attributes[:value] = elements.map! {|e| li(e)}.join
        Html.element('ul', attributes )
      end
    end
    
    
    module Forms
      def Forms.input(type, name, o={})
        o.merge!({:type => type, :name => name})
        Html.empty_element('input', o)
      end
      
      def Forms.textarea(name, o={})
        o[:name] = name
        o[:contents] = o.delete(:value) if (o.key? :value)
        Html.element('textarea', o)
      end
      
      def Forms.date(name, o={})
        ''
      end
      
      def Forms.start_form_tag (action, method, o ={})
        "<form action=\"#{action}\" method=\"#{method}\" id=\"#{o[:id]}\">\n"
      end
      
      def Forms.label(name, fortag)
        Html.element('label', {:for=>fortag, :contents=>name})
      end
      
      def Forms.option(value, selected = false, label = nil)
        o = {:value=>value}
        o[:selected] = 'selected' if selected
        o[:contents] = (label.nil?) ? value : label
        Html.element('option', o)
      end
      
      def Forms.select(name, options, selected=nil)
        Html.element('select', {:name=>name, 
          :contents => options.sort.inject("\n")do |s,(k,v)| 
            s + option(k, (selected == k), v) + "\n"
          end
        })
      end
      
      def Forms.checkbox(name, value)
        o = {:value=>value}
        input('checkbox', name, o)
      end
      
      def Forms.fieldset(legend, contents)
        Html.element('fieldset', {:contents=>"\n" +
          Html.element('legend', {:contents=>
            Html.element('span', {:contents=> legend})
          }) + "\n" + contents
        
        })
      end
    end
    
    
    module Scaffold
      
      private
      
      def gvf(object, name)
        return object[name] if object.respond_to? :'[]'
        object.send(name)
      end
      
      def create_form (model, options = {})
        fields = {}
        if options[:fields]
          options[:fields].each { |p| fields[p] = model.properties[p] }
        else
          options[:fields] = []
          model.properties.each { |p| fields[p.name] = p; options[:fields] << p.name}
        end
        values = options[:values] || {}
        output = Forms.start_form_tag(
          options[:action], 
          options[:method], 
          {:id=> options[:id]}
        ) +"\n<ol>\n";
        
        options[:fields].each do |n|
          f = fields[n]
          case f.type.to_s
            when String.to_s
              ftype = (n == :password) ? 'password' : 'text'
              output += Lists.li(
                Forms.label(n.to_s.to_label, n) + "\n" +
                Forms.input(ftype, n, {:id => n, :value=>gvf(values,n) })
              )
            when DataMapper::Types::Text.to_s
              output += Lists.li(
                Forms.label(n.to_s.to_label, n) + "\n" +
                Forms.textarea(n, {:id => n, :value=>gvf(values,n)})
              )
            
            when Date.to_s
              output += Lists.li(
                Forms.fieldset(
                  n.to_s.to_label,
                  date_fields(n, {:value=>gvf(values,n)})
                )
              )
            when DateTime.to_s
              #unless n == :created_at or n == :updated_at
                output += Lists.li(
                  Forms.fieldset(n.to_s.to_label,
                    date_fields(n) + 
                    time_fields(n)
                  )
                )
              #end
            when DataMapper::Types::Boolean.to_s
              output += Lists.li(
                Forms.label(n.to_s.to_label, n) + "\n" +
                Forms.checkbox(n, 'no')
              )
          end
          
	        _now = Time.now
	        @_dates = {
	          :year => (1900..2012),
	          :month => {
	            1=>'Jan', 2=>'Feb', 3=>'Mar', 4=>'Apr', 5=>'May', 6=>'Jun',
	            7=>'Jul', 8=>'Aug', 9=>'Sep', 10=>'Oct', 11=>'Nov', 12=>'Dec'
            },:day => 1..31,
	          :hour => 1..24, :minute => 0..59, :second => 0..59
	        }
	        
          def date_fields(n, o = {})
	          spanned_date_select(n, :month, o) + "\n" + 
	          spanned_date_select(n, :day, o) + ",\n" +
	          spanned_date_select(n, :year, o) + "\n"  
	        end
	        
	        def time_fields(n, o = {})
	          spanned_date_select(n, :hour, o) + ":" + 
	          spanned_date_select(n, :minute, o) + ":" + 
	          spanned_date_select(n, :second, o)
          end
	        
	        def spanned_date_select(n,v, o ={})
	          if o[:value]
	            puts o[:value]
	            o[:value] = o[:value].send v if o[:value].respond_to? v
            end
	          Html.element('span', {:contents => Forms.select(
	              n.to_s + '_' + v.to_s , @_dates[v], o[:value]
            )}) 
	        end
	        
          
        end 
        
        #submit button
        options[:submit] = 'Submit' unless options[:submit]
        output += Lists.li Forms.input('submit', 'submit', {:value => options[:submit]})
        output += "</ol>\n</form>\n"
      end
        
    end
  end
end
