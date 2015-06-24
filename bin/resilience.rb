#!/usr/bin/ruby
# resilience.rb - Ruby ReFS Parser

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/resilience'

include Resilience::CLI

optparse = resilience_option_parser
optparse.parse!

verify_image!
write_results parse_image
