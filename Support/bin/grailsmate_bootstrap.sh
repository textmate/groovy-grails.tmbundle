source "$TM_SUPPORT_PATH/lib/bash_init.sh"
export RUBYLIB="$TM_BUNDLE_SUPPORT/GrailsMate:$TM_SUPPORT_PATH/lib/${RUBYLIB:+:$RUBYLIB}"

TM_GRAILS=${TM_GRAILS:-grails}

require_cmd "$TM_GRAILS" "If you have installed grails, then you need to either <a href=\"help:anchor='search_path'%20bookID='TextMate%20Help'\">update your <tt>PATH</tt></a> or set the <tt>TM_GRAILS</tt> shell variable (e.g. in Preferences / Advanced)"

export TM_GRAILS=`which $TM_GRAILS`
script="$1"
shift

/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -r GrailsMate -r ui -- "$TM_BUNDLE_SUPPORT/GrailsMate/$script.rb" $@

rescan_project