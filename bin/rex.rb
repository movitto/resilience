#!/usr/bin/ruby
# ReFS File Extractor
# Copyright (C) 2015 Red Hat Inc.

require 'optparse'

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/rex'

include Resilience::CLI

optparse = rex_option_parser
optparse.parse!

verify_image!
verify_output_dir!

results = parse_image
write_results results
