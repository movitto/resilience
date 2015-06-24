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

def write_results(image)
  dir = conf[:dir]
  Dir.mkdir(dir) unless File.directory?(dir)

  files = image.root_dir.files
  dirs  = image.root_dir.dirs
  files.each do |name, contents|
    puts "Got #{name}"
    path = "#{dir}/#{name}".delete("\0")
    File.write(path, contents)
  end
end
