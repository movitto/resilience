# Reslience rex cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def rex_option_parser
  OptionParser.new do |opts|
    default_options   opts
    image_options     opts
    output_fs_options opts
  end
end

def write_results(results)
  dir = conf[:dir]
  Dir.mkdir(dir) unless File.directory?(dir)

  results[:files].each do |name, contents|
    puts "Got #{name}"
    path = "#{dir}/#{name}".delete("\0")
    File.write(path, contents)
  end
end

def parse_image
  file         = File.open(conf[:image], 'rb')
  image        = Resilience::OnImage.image
  image.file   = file
  image.offset = conf[:offset]
  image.opts   = conf

  image.parse
  files        = image.root_dir.files
  dirs         = image.root_dir.dirs
  {:files => files, :dirs => dirs}
end
