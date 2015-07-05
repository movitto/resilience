#!/usr/bin/ruby
# Reslience File Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def file_select_options(option_parser)
      option_parser.on("-f", "--file [file]", "File to analyze") do |file|
        conf.file = file
      end
    end

    def verify_file!
      unless conf.file
        puts "--file param needed"
        exit 1
      end
    end
  end # module CLI
end # module Resilience
