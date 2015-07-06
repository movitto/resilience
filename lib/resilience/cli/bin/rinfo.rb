# Resilience rinfo cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def rinfo_option_parser
  OptionParser.new do |opts|
    default_options    opts
    image_options      opts
    disk_options       opts
  end
end

def dump_info
  puts header_output
end
