# Resilience rcomp cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def fcomp_option_parser
  OptionParser.new do |opts|
    default_options    opts
    image_options      opts
  end
end

def write_results
  different_bytes = image.root_dir.files.bytes_diff
  0.upto(different_bytes.size-1) do |byte_index|
    next if different_bytes[byte_index].nil?
    puts "Byte 0x#{byte_index.to_s(16)} differs".red.bold
    different_bytes[byte_index].each do |file, byte|
      print " 0x#{byte.unpack('C*').first.to_s(16)}".blue
    end
    puts
  end
end
