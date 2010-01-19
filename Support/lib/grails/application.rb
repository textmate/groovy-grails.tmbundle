module Grails
  
  class Application
    
    attr_reader :path 
    
    def initialize(path)
      @path = path
    end
  
    def properties
      @properties = read_properties if @properties.nil?
      @properties
    end
    
    def file(path, mode, &b) 
      File.open(@path + '/' + path, mode, &b) 
    end

    def grails_version
      properties['app.grails.version']
    end

    def version
      properties['app.version']
    end
    
    def plugins
      properties.inject({}) do |p,e|
        p[$1] = e.last if e.first =~ /^plugins\.(.+)$/
        p
      end
    end
    
    protected
    
    def read_properties
      p = {}
      file('application.properties', 'r') do |f|
        f.each_line do |s|
          if s =~ /(?!\s#)([\w\.]+)=(.+)$/
            p[$1] = $2
          end
        end
      end
      p
    end
      
  end
  
end