#!/usr/bin/ruby
#
# ReFS Filesystem Info
# Copyright (C) 2015 Red Hat Inc.
###########################################################

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/rinfo'

include Resilience::CLI

optparse = rinfo_option_parser
optparse.parse!

verify_image!
parse_image
dump_info
