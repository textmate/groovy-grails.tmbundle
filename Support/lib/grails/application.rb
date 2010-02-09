require "find"

module Grails
  
  class Application
    
    attr_reader :path 
    
    def initialize(path = nil)
      @path = path || ENV['TM_PROJECT_DIRECTORY']
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
    
    def is_pre_1_2
      grails_version[0,1] == '0' or (grails_version[0,1] == '1' and grails_version =~ /^1\.1.*/) 
    end

    def test_reports_dir
      is_pre_1_2 ? "#{@path}/test/reports" : "#{@path}/target/test-reports"
    end

    def find_test_report(test_class_name)
      matches = []
      Find.find("#{test_reports_dir}/plain") do |path|
        if File.basename(path) =~ /#{Regexp.escape(test_class_name)}\.txt$/
          matches << path
        end
      end
      matches.first # we eventually need something more sophisticated here
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