#!/usr/bin/ruby
# ReFS file searcher
# Copyright (C) 2015 Red Hat Inc.

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/reach'

include Resilience::CLI

optparse = reach_option_parser
optparse.parse!

verify_image!
setup_image
run_search
