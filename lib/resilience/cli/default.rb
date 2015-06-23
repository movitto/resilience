#!/usr/bin/ruby
# Reslience CLI Default Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def default_options(option_parser)
      option_parser.on('-h', '--help', 'Print help message') do
        puts option_parser
        exit
      end
    end
  end # module CLI
end # module Resilience
