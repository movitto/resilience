# Resilience axe cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def axe_option_parser
  OptionParser.new do |opts|
    default_options     opts
    image_options       opts
    file_select_options opts
  end
end

def validate_file!(file)
  if file.nil?
    puts "File #{conf.file} not found"
    exit 1
  end
end

def write_results
  file = image.root_dir.files.at(conf.file)
  validate_file!(file)

  puts "==="
  puts "File: #{file.fullname}"

  puts "Metadata:"
  print format_bytes(file.metadata.unpack("C*"), 16, 4)
  puts "\n\n"

  puts "Timestamps"
  puts file.timestamps
  puts

  puts "File len: 0x#{file.len.to_s(16)}"

  puts "Content Ptr: 0x#{file.content_ptr.to_s(16)}"

  puts "Content:"
  puts Resilience::FileContent.new(file).raw
end
