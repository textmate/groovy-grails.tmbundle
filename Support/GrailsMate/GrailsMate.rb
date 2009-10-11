require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/ui"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/tm/process"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/tm/htmloutput"

require "shellwords"
require "pstore"

class GrailsCommand
  
  attr_reader :colorisations

  @@location = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY']
  @@prefs = PStore.new(File.expand_path( "~/Library/Preferences/com.macromates.textmate.grailsmate"))
  
  def self.prefs(&t)
    @@prefs.transaction do |p|
      t.call(p)
    end
  end
  
  def self.location_prefs(&t)
    prefs do |p|
      p[@@location] = {} if p[@@location].nil?
      t.call(p[@@location])
    end
  end
  
  def self.get_location_pref(key) 
    location_prefs do |p|
      p[key]
    end
  end
  
  def self.set_location_pref(key, value) 
    location_prefs do |p|
      p[key] = value
    end
  end
  
  def self.last_option_prefs(&t) 
    location_prefs do |p|
      p["task"] = {} if p["task"].nil?
      t.call(p["task"])
    end
  end
  
  def self.set_last_option_pref(task, option) 
    last_option_prefs do |p|
      p[task] = option
    end
  end

  def self.get_last_option_pref(task) 
    last_option_prefs do |p|
      p[task]
    end
  end
  
  def self.select_env
    env = TextMate::UI.request_string( 
      :title => "Grails Environment",
      :prompt => 'Enter the full name of the environment you wish to set (leave blank for default)',
      :default => get_env(),
      :button2 => "Clear"
    )
    set_location_pref("env", env)
    env
  end

  def self.get_env
    get_location_pref("env")
  end
  
  def initialize(task, &option_getter)
    @grails = ENV['TM_GRAILS']
    @task = task
    @option_getter = option_getter
    @command = nil
    @colorisations = {
      "green" => [/SUCCESS/,/Server running/, /Tests PASSED/, /PASSED$/],
      "red" => [/FAILURE/,/Tests FAILED/,/Compilation error/,/threw exception/, /Exception:/, /FAILED$/],
      "blue" => [/Environment set to/],
      "aquamarine" => [/^Running test [\w\.]+...(?!PASSED|FAILED)/]
    }
  end

  def command
    if @command.nil?
      option = nil
      unless @option_getter.nil?
        last_value = self.class.get_last_option_pref(@task)
        option = @option_getter[last_value]
        self.class.set_last_option_pref(@task, option)
      end
      @command = construct_command(@task, option)
    end
    @command
  end
  
  def construct_command(task, option)
    env = self.class.get_env
    command = []
    command << "-Dgrails.env=#{env}" if env
    command << task unless task.nil? or task.empty?
    unless option.nil? or option.empty?
      (Shellwords.shellwords(option).each { |option| command << option })
    end
    command
  end
      
  def run
    Dir.chdir(@@location) do 
      cmd = command
      TextMate::HTMLOutput.show(:window_title => "GrailsMate", :page_title => "GrailsMate", :sub_title => "#{@@location}") do |io|
        if cmd.nil?
          io << "Command cancelled."
        else
          io << "<pre>"
          io << "<strong>grails " + htmlize(cmd.join(' ')) + "</strong><br/>"
          TextMate::Process.run(@grails, cmd) do |line|
            line.chomp!
            match = false
            @colorisations.each do | color, patterns |
              if match == false and patterns.detect { |pattern| line =~ pattern }
                match = "<span style=\"color: #{color}\">#{htmlize line}</span><br/>"
              end
            end
            line = (match ? match : "#{htmlize line}<br/>")
            line.sub!(/(Running test )(\S+)(\.\.\.)/, "\\1<a href='txmt://open?url=file://#{@@location}/test/reports/plain/TEST-\\2.txt'>\\2</a>\\3")
            line.sub!(/(Browse to )([^\<]+)/, "\\1<a href=\"javascript:TextMate.system('open \\\\'\\2\\\\'')\">\\2</a>")
            line.sub!(/(view reports in )(.+)(\.)/, "\\0 <br /><br /><input type='submit' name='open_test_report' value='Open HTML Report' onclick=\"TextMate.system('open \\\\'\\2/html/index.html\\\\'')\"/>")
            io << line
          end
          io << "</pre>"
        end
      end
    end
  end
  
end