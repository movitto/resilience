#!/usr/bin/ruby
# Reslience CLI Output Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module CLI
    def output_fs_options(option_parser)
      option_parser.on("--write dir", "Write output to directory") do |dir|
        conf[:dir] = dir
      end
    end

    def stdout_options(option_parser)
      option_parser.on("-f", "--files", "List files in output") do
        conf[:files] = true
      end

      option_parser.on("-d", "--dirs", "List dirs in output") do
        conf[:dirs] = true
      end
    end

    def verify_output_dir!
      unless conf[:dir]
        puts "--write param needed"
        exit 1
      end
    end

    def output_dir
      conf[:dir]
    end

    def write_to_output_dir?
      !!output_dir
    end

    def create_output_dir!
      return unless write_to_output_dir?
      Dir.mkdir(output_dir) unless File.directory?(output_dir)
    end

    def output_files?
      !!conf[:files]
    end

    def output_dirs?
      !!conf[:dirs]
    end
  end # module CLI
end # module Resilience
