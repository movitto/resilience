#!/usr/bin/ruby
# Reslience CLI Image Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def image_options(option_parser)
      option_parser.on("-i", "--image path", "Path to the disk image to parse") do |path|
        conf[:image] = path
      end

      option_parser.on("-o", "--offset bytes", "Start of volume with ReFS filesystem") do |offset|
        conf[:offset] = offset.to_i
      end
    end

    def verify_image!
      unless conf[:image] && conf[:offset]
        puts "--image and --offset params needed"
        exit 1
      end
    end

    def setup_image
      file         = File.open(conf[:image], 'rb')
      image.file   = file
      image.offset = conf[:offset]
      image.opts   = conf
      image
    end

    def parse_image
      setup_image
      image.parse
      image
    end

    def image
      Resilience::OnImage.image
    end
  end # module CLI
end # module Resilience
