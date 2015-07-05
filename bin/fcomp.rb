#!/usr/bin/ruby
# ReFS File Metadata Comparer
# Copyright (C) 2015 Red Hat Inc.

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/fcomp'

include Resilience::CLI

optparse = fcomp_option_parser
optparse.parse!

verify_image!
parse_image
write_results
