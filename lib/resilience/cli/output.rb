#!/usr/bin/ruby
# Reslience CLI Output Options
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'colored'

module Resilience
  module CLI
    OUTPUT_LABELS = {
      :bps    => "(bytes per sector)",
      :spc    => "(sectors per cluster)",
      :bpc    => "(bytes per cluster)",
      :vbr    => "VBR",
      :image  => "Analyzed ReFS filesystem on",
      :offset => "starting at"
    }

    def output_fs_options(option_parser)
      option_parser.on("--write dir", "Write output to directory") do |dir|
        conf.dir = dir
      end
    end

    def stdout_options(option_parser)
      option_parser.on("-f", "--files", "List files in output") do
        conf.files = true
      end

      option_parser.on("-d", "--dirs", "List dirs in output") do
        conf.dirs = true
      end
    end

    def verify_output_dir!
      unless conf.dir
        puts "--write param needed"
        exit 1
      end
    end

    def output_dir
      conf.dir
    end

    def write_to_output_dir?
      !!output_dir
    end

    def create_output_dir!
      return unless write_to_output_dir?
      Dir.mkdir(output_dir) unless File.directory?(output_dir)
    end

    def image_output
      "#{OUTPUT_LABELS[:image]} #{conf.image_file.green.bold} "\
      "#{OUTPUT_LABELS[:offset]} #{conf.offset.to_s.green.bold}\n"
    end

    def header_output
      image_output + vbr_output
    end

    def bytes_per_sector_output
      "#{image.bytes_per_sector.indented.yellow.bold} (#{OUTPUT_LABELS[:bps]})"
    end

    def sectors_per_cluster_output
      "#{image.sectors_per_cluster.indented.yellow.bold} (#{OUTPUT_LABELS[:spc]})"
    end

    def cluster_size_output
      "#{image.cluster_size.indented.yellow.bold} (#{OUTPUT_LABELS[:bpc]})\n"
    end

    def vbr_output
      "#{OUTPUT_LABELS[:vbr]}: #{bytes_per_sector_output} * "    \
                              "#{sectors_per_cluster_output} = " \
                              "#{cluster_size_output}"
    end

    def format_bytes(bytes, bytes_per_col, cols_per_row)
      formatted = ''
      bytes.each_slice(bytes_per_col) { |s1|
        s1.each_slice(cols_per_row) { |s2|
          formatted += s2.collect { |b| c = b.to_s(16) ; c.size < 2 ? "0#{c}" : c }.join(' ')
          formatted += "  " 
        }
        formatted += "\n"
      }
      formatted
    end
  end # module CLI
end # module Resilience
