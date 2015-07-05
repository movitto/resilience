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
  puts "File: #{file.fullname} attributes: "
  file.metadata_attrs.each_index { |attr_index|
    attr = file.metadata_attrs[attr_index]
    print "Attribute #{attr_index}: "
    print attr.collect { |b| b.to_s(16) }.join(' ')
    puts "\n\n"
  }
end
