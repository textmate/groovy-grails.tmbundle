#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/grails/application'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

test_class = ARGV[0]

test_report = Grails::Application.new.find_test_report(test_class)
if test_report
  TextMate.go_to(:file => test_report)
else
  TextMate::UI.tool_tip("Could not find report for #{test_class}")
end
