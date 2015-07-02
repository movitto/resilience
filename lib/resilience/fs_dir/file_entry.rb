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

      def initialize(prefix, name, metadata)
        @prefix   = prefix
        @name     = name
        @metadata = metadata
      end

      def fullname
        "#{prefix}\\#{name}"
      end

    end # class FileEntry
  end # module FSDir
end # module Resilience
