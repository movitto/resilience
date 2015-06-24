#!/usr/bin/ruby
# ReFS 0x4000 Cluster Extractor
# By mmorsi - 2014-07-14

require 'resilience'
require 'resilience/cli/all'
require 'resilience/cli/bin/cle'

include Resilience::CLI

optparse = cle_option_parser
optparse.parse!

verify_image!
verify_output_dir!
extract
