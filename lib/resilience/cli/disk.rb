#!/usr/bin/ruby
# Resilience Disk Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def disk_options(option_parser)
      option_parser.on("-m", "--mbr", "Extract FS Info From MBR") do
        conf.mbr = true
      end

      option_parser.on("-g", "--gpt", "Extract FS Info From GUID Partition Table") do
        conf.gpt = true
      end
    end

    def mbr2offset
      return unless conf.mbr
      image.offset  = 0
      offset        = MBR.new.refs_offset
      conf[:offset] = offset unless offset.nil?
    end

    def gpt2offset
      return unless conf.gpt
      image.offset = 0
      image.offset = MBR.new.gpt_offset
      image.offset = conf.offset = GPT.new.refs_offset
    end

    def boot2offset
      setup_image
      mbr2offset if conf.mbr
      gpt2offset if conf.gpt
    end
  end # module CLI
end # module Resilience
