# ReFS File Reference Record
# Copyright (C) 2017 Red Hat Inc.

module Resilience
  module FSDir
    # Special type of Record residing in File Entries file length & content ptr
    class FileRefRecord
      attr_accessor :record

      def initialize(record)
        @record = record
      end

      def attr1
        # XXX pass in all value bytes w/ assumption that
        #     Attribute.parse will only store what is applicable
        @attr1 ||= Attribute.parse(record.value_pos, record.value_bytes)
      end

      alias :len_attr :attr1

      def len
        @len ||= len_attr.bytes[ADDRESSES[:file_len]]
      end

      def attr2_start
        @attr2_start ||= record.value_pos + attr1.len
      end

      def attr2_bytes
        @attr2_bytes ||= record.value_bytes[attr1.len..-1]
      end

      def attr2
        @attr2 ||= Attribute.parse(attr2_start, attr2_bytes)
      end

      # XXX: to make things even more complicated this subattribute
      #      seems to be the header of yet another AttributeList
      #      (perhaps so additional attributes can be added for
      #       large files)
      def content_ptr_header
        @content_ptr_attr ||= AttributeList::Header.new(attr2)
      end

      def content_ptr_bytes
        @content_ptr_bytes ||= record.value_bytes[attr1.len..attr1.len + content_ptr_header.total_len-1]
      end

      def content_ptr_attr_list
        @content_ptr_attr_list ||= AttributeList.parse(attr2_start, content_ptr_bytes)
      end

      # XXX: right now we've only encountered one entry in the content
      #      ptr attribute list, and it looks like a record,
      #      i suspect there will be more for larger files
      def content_ptr_record
        @content_ptr_record ||= Record.new content_ptr_attr_list.attributes.first
      end

      def content_ptr
        # XXX not sure if there are words / dwords
        @content_ptr ||= content_ptr_record.value_qwords[2]
      end
    end
  end # module FSDir
end # module Resilience
