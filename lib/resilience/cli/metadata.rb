#!/usr/bin/ruby
# Reslience Metadata Default Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def metadata_options(option_parser)
      option_parser.on("-a", "--attributes", "Include attribute analysis in output") do
        conf.attributes   = true
      end

      option_parser.on("--table", "Include object table analysis in output") do
        conf.object_table = true
      end

      option_parser.on("--tree", "Include object tree analysis in output") do
        conf.object_tree  = true
      end
    end
  end # module CLI
end # module Resilience
