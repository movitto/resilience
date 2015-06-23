#!/usr/bin/ruby
# Reslience CLI FS Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def output_fs_options(option_parser)
      option_parser.on("-d", "--dir dir", "Output directory") do |dir|
        conf[:dir] = dir
      end
    end

    def verify_output_dir!
      unless conf[:dir]
        puts "--dir param needed"
        exit 1
      end
    end
  end # module CLI
end # module Resilience
