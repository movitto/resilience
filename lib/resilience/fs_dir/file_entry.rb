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

      # known metadata attributes
      attr_accessor :metadata_attrs

      def initialize(args={})
        @prefix   = args[:prefix]
        @name     = args[:name]
        @metadata = args[:metadata]
        @record   = args[:record]
        parse_attrs
      end

      def fullname
        "#{prefix}\\#{name}"
      end

      def total_offset
        image.offset + record.attribute.pos
      end

      def parse_attrs
        metadata_bytes  = @metadata.unpack('C*')
        metadata_dwords = @metadata.unpack('L*')
        attr1_length    = metadata_dwords[0]
        attr1_dwords    = attr1_length/4
        attr2_length    = metadata_dwords[attr1_dwords]
        attr2_dwords    = attr2_length/4
        attr3_length    = metadata_dwords[attr1_dwords + attr2_dwords]
        # there may be other attrs after this point...

        attr1 = metadata_bytes[0..attr1_length]
        attr2 = metadata_bytes[attr1_length..attr1_length+attr2_length]
        attr3 = metadata_bytes[attr1_length+attr2_length..attr1_length+attr2_length+attr3_length]
        @metadata_attrs = [attr1, attr2, attr3]
      end
    end # class FileEntry
  end # module FSDir
end # module Resilience
