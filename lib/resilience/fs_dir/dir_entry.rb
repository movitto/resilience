#!/usr/bin/ruby
# ReFS Directory Dir Entry
# Copyright (C) 2014-2015 Red Hat Inc.

require 'fileutils'

module Resilience
  module FSDir
    class DirEntry
      attr_accessor :prefix
      attr_accessor :name
      attr_accessor :metadata

      # offset in fs
      attr_accessor :offset

      def initialize(args={})
        @prefix   = args[:prefix]
        @name     = args[:name]
        @metadata = args[:metadata]
        @offset   = args[:offset]
      end

      def fullname
        "#{prefix}\\#{name}"
      end
    end # class DirEntry
  end # module FSDir
end # module Resilience
