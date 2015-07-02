#!/usr/bin/ruby
# rarser.rb - Ruby ReFS Parser
# Copyright (C) 2015 Red Hat Inc.

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/rarser'

include Resilience::CLI

optparse = rarser_option_parser
optparse.parse!

verify_image!
write_results parse_image
