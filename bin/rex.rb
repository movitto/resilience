#!/usr/bin/ruby
# ReFS File Extractor
# Copyright (C) 2015 Red Hat Inc.

require 'optparse'
require 'resilience'

def main
  cli_opts = parse_cli(ARGV)
  results  = parse_image cli_opts
  write_results cli_opts, results
end

def write_results(opts, results)
  dir = opts[:dir]
  Dir.mkdir(dir) unless File.directory?(dir)

  results[:files].each do |name, contents|
    puts "Got #{name}"
    path = "#{dir}/#{name}".delete("\0")
    File.write(path, contents)
  end
end

def parse_image(opts)
  file         = File.open(opts[:image], 'rb')
  image        = Resilience::OnImage.image
  image.file   = file
  image.offset = opts[:offset]
  image.opts   = opts

  image.parse
  files        = image.root_dir.files
  dirs         = image.root_dir.dirs
  {:files => files, :dirs => dirs}
end

def parse_cli(cli)
  opts   = {}
  parser = OptionParser.new do |popts|
    popts.on("-h", "--help", "Print help message") do
      puts parser
      exit
    end

    popts.on("-i", "--image path", "Path to the disk image to parse") do |path|
      opts[:image] = path
    end

    popts.on("-o", "--offset bytes", "Start of volume with ReFS filesystem") do |offset|
      opts[:offset] = offset.to_i
    end

    popts.on("-d", "--dir dir", "Output directory") do |dir|
      opts[:dir] = dir
    end
  end

  begin
    parser.parse!(cli)
  rescue OptionParser::InvalidOption
    puts parser
    exit
  end

  if !opts[:image] || !opts[:offset] || !opts[:dir]
    puts "--image, --offset, and --dir params are needed"
    exit 1
  end

  opts
end

main if __FILE__ == $0
