# Resilience rex cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def rex_option_parser
  OptionParser.new do |opts|
    default_options    opts
    image_options      opts
    output_fs_options  opts
    stdout_options     opts
  end
end

def write_results(image)
  create_output_dir!

  dirs  = image.root_dir.dirs
  dirs.each do |dir|
    puts "Dir: #{dir.fullname} at #{dir.total_offset}" if conf.dirs?
  end

  files = image.root_dir.files
  files.each do |file|
    puts "File: #{file.fullname} at #{file.total_offset}" if conf.files?

    path = "#{output_dir}/#{file.fullname}".delete("\0")
    File.write(path, file.metadata) if write_to_output_dir?
  end
end
