#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/grails/application'

test_report = Grails::Application.new.find_test_report(ARGV[0])
TextMate.go_to(:file => test_report)