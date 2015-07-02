#!/usr/bin/ruby
# ReFS Directory Handling
# Copyright (C) 2014-2015 Red Hat Inc.

require 'fileutils'

module Resilience
  module FSDir
    class DirBase
      include OnImage

      attr_accessor :dirs
      attr_accessor :files

      def parse_dir_obj(object_id, prefix)
        object_table   = image.object_table
        @dirs        ||= []
        @files       ||= []
      
        page_id      = object_table.pages[object_id]
        page_address = page_id * PAGE_SIZE
        parse_dir_page page_address, prefix
      end
      
      def parse_dir_page(page_address, prefix)
        # skip container/placeholder attribute
        image.seek(page_address + ADDRESSES[:first_attr])
        Attribute.read
      
        # start of table attr, pull out table length, type
        table_header_attr   = Attribute.read
        table_header_dwords = table_header_attr.unpack("L*")
        header_len          = table_header_dwords[0]
        table_len           = table_header_dwords[1]
        remaining_len       = table_len - header_len
        table_type          = table_header_dwords[3]
      
        until remaining_len == 0
          orig_pos = image.pos
          record   = Record.read
      
          # need to keep track of position locally as we
          # recursively call parse_dir via helpers
          pos = image.pos
      
          if table_type == DIR_TREE
            parse_dir_branch record, prefix
      
          else #if table_type == DIR_LIST
            record = filter_dir_record(record)
            pos = image.pos
            parse_dir_record record, prefix
      
          end
      
          image.seek pos
          remaining_len -= (image.pos - orig_pos)
        end
      end

      def filter_dir_record(record)
        # '4' seems to indicate a historical record or similar,
        # records w/ flags '0' or '8' are what we want
        record.flags == 4 ? filter_dir_record(Record.read) : record 
      end
      
      def parse_dir_branch(record, prefix)
        key          = record.key
        value        = record.value
        flags        = record.flags
      
        value_dwords = value.unpack('L*')
        value_qwords = value.unpack('Q*')
      
        page_id      = value_dwords[0]
        page_address = page_id * PAGE_SIZE
        checksum     = value_qwords[2]

        parse_dir_page page_address, prefix unless checksum == 0 || flags == 4
      end
      
      def parse_dir_record(record, prefix)
        key        = record.key
        value      = record.value
      
        key_bytes  = key.unpack('C*')
        key_dwords = key.unpack('L*')
        entry_type = key_dwords.first

        if entry_type == DIR_ENTRY
          dir_name = key_bytes[4..-1].pack('L*')
          dir_obj = value.unpack('C*')[0...8]
          dirs << DirEntry.new(prefix, dir_name, dir_obj)

          dir_obj = [0, 0, 0, 0, 0, 0, 0, 0].concat(dir_obj)
          parse_dir_obj(dir_obj, "#{prefix}\\#{dir_name}")
      
        elsif entry_type == FILE_ENTRY
          filename = key_bytes[4..-1].pack('L*')
          files <<  FileEntry.new(prefix, filename, value)
        end
      end
    end # class DirBase
  end # module FSDir
end # module Resilience
