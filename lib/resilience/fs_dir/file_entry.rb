#!/usr/bin/ruby
# ReFS Directory File Entry
# Copyright (C) 2014-2015 Red Hat Inc.

require 'fileutils'

module Resilience
  module FSDir
    class FileEntry
      attr_accessor :prefix
      attr_accessor :name
      attr_accessor :metadata

      # metadata record
      attr_accessor :record

      def initialize(args={})
        @prefix   = args[:prefix]
        @name     = args[:name]
        @metadata = args[:metadata]
        @record   = args[:record]
      end

      def fullname
        "#{prefix}\\#{name}"
      end

      def total_offset
        image.offset + record.attribute.pos
      end
    end # class FileEntry
  end # module FSDir
end # module Resilience
