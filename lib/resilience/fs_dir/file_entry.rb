#!/usr/bin/ruby
# ReFS Directory File Entry
# Copyright (C) 2014-2015 Red Hat Inc.

require 'fileutils'

module Resilience
  module FSDir
    # Directory Entry corresponding to file
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

      def bytes
        @bytes ||= @metadata.unpack('C*')
      end

      def dwords
        @dwords ||= @metadata.unpack('L*')
      end

      def attr1_start
        @attr1_start ||= record.value_pos
      end

      def attr1_length
        @attr1_length ||= dwords[0]
      end

      def attr1_bytes
        @attr1_bytes ||= bytes[0..attr1_length-1]
      end

      def attr1
        @attr1 ||= FileTimeStampsAttribute.new :pos   => attr1_start,
                                               :bytes => attr1_bytes,
                                               :len   => attr1_length
      end

      # XXX: from observation attribute 1 always contains the file timestamps
      alias :timestamps_attr :attr1

      def timestamps
        timestamps_attr.formatted_timestamps
      end

      def attr2_start
        @attr2_start ||= record.value_pos + attr1_length
      end

      def attr2_length
        @attr2_length ||= dwords[attr1_length/4]
      end

      def attr2_bytes
        @attr2_bytes ||= bytes[attr1_length..attr1_length+attr2_length-1]
      end

      def attr2
        @attr2 ||= Attribute.new(:pos   => attr2_start,
                                 :bytes => attr2_bytes,
                                 :len   => attr2_length)
      end

      # XXX: from observation, attribute 2 is infact a header attribute for
      # an attribute list containing attributes w/ the file length and content pointer
      def ref_header
        @ref_header ||= AttributeList::Header.new attr2
      end

      def ref_bytes
        @ref_bytes ||= bytes[attr1_length..attr1_length + ref_header.total_len-1]
      end

      def ref_attr_list
        @ref_attr_list ||= AttributeList.parse(attr2_start, ref_bytes)
      end

      # XXX: now here it gets a bit weird, the only observed item
      # in the file ref attribute list is a single record containing
      # a key and two attributes for values
      def ref_record
        @ref_record ||= FileRefRecord.new Record.new(ref_attr_list.attributes.first)
      end

      def len
        @len ||= ref_record.len
      end

      def content_ptr
        @content_ptr ||= ref_record.content_ptr
      end
    end # class FileEntry
  end # module FSDir
end # module Resilience
