# Resilience reach cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def reach_option_parser
  OptionParser.new do |opts|
    default_options opts
    image_options   opts
  end
end

def check_sequence
  @check_sequence  ||= 0xe010002800000038 # inverted due to endian ordering
end

def sequence_length
  @sequence_length ||= 8
end

def run_search
  while check = image.read(sequence_length)
    unpacked = check.unpack('Q').first
    write_match if unpacked == check_sequence
  end
end

def write_match
  puts 'File at: 0x' + image.total_pos.to_s(16)      +
       ' cluster '   + (image.pos / 0x4000).to_s(16)
end
