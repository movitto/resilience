#!/usr/bin/ruby
# ReFS File Attribute Extractor
# Copyright (C) 2015 Red Hat Inc.

require 'resilience'

require 'resilience/cli/all'
require 'resilience/cli/bin/axe'

include Resilience::CLI

optparse = axe_option_parser
optparse.parse!

verify_image!
verify_file!
parse_image
write_results
