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

def byte_map
  bytes = []
  files = image.root_dir.files
  files.each do |file|
    0.upto(file.metadata.size-1) do |byte_index|
      bytes[byte_index] ||= {}
      bytes[byte_index][file] = file.metadata[byte_index]
    end
  end
  bytes
end

def diff
  map   = byte_map
  files = image.root_dir.files
  different_bytes = []
  0.upto(map.size-1).each do |byte_index|
    bytes = map[byte_index].values
    different = bytes.uniq.size != 1 ||
                bytes.size != files.size
    different_bytes << (different ? map[byte_index] : nil)
  end
  different_bytes
end

def write_results
  different_bytes = diff
  0.upto(different_bytes.size-1) do |byte_index|
    next if different_bytes[byte_index].nil?
    puts "Byte 0x#{byte_index.to_s(16)} differs".red.bold
    different_bytes[byte_index].each do |file, byte|
      print " 0x#{byte.unpack('C*').first.to_s(16)}".blue
    end
    puts
  end
end
