#!/usr/bin/ruby
# ReFS File Extractor
# Copyright (C) 2015 Red Hat Inc.

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/rex'

include Resilience::CLI

optparse = rex_option_parser
optparse.parse!

verify_image!
write_results parse_image
