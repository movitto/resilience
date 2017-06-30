#!/usr/bin/ruby
# ReFS Directory Handling
# Copyright (C) 2014-2015 Red Hat Inc.

require 'fileutils'
require 'resilience/collections/dirs'
require 'resilience/collections/files'

module Resilience
  module FSDir
    # Base Directory disk structure, defines mechanism to parse ReFS directories.
    #
    # Directories reside on pages (clusters) and are registered in the object table.
    # They may consist of specified subdir & file entries, and/or branches to other
    # pages containing additional directory contents (in the case a single page
    # cannot contain all directory entries).
    #
    # We look for standard fields / retrieved from analysis here.
    class DirBase
      include OnImage

      attr_accessor :dirs
      attr_accessor :files

      def parse_dir_obj(object_id, prefix)
        object_table   = image.object_table
        @dirs        ||= Dirs.new
        @files       ||= Files.new

        page_id      = object_table.pages[object_id]
        page_address = page_id * PAGE_SIZE
        parse_dir_page page_address, prefix
      end

      def parse_dir_page(page_address, prefix)
        # skip container/placeholder attribute
        image.seek(page_address + ADDRESSES[:first_attr])
        Attribute.read

        # read directory page attribute list
        attributes = AttributeList.read
        attributes.attributes.each { |attr|
          record = Record.new attr

          if attributes.header.type == DIR_TREE
            parse_dir_branch record, prefix

          else #if attributes.header.type == DIR_LIST
            unless exclude_dir_record(record)
              parse_dir_record record, prefix
            end
          end
        }
      end

      def exclude_dir_record(record)
        # '4' seems to indicate a historical record or similar,
        # records w/ flags '0' or '8' are what we want
        record.flags == 4
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
          dir_name = key_bytes[4..-1]
          dir_name.delete(0)
          dir_name = dir_name.pack('C*')

          dir_obj = value.unpack('C*')[0...8]
          dirs << DirEntry.new(:prefix   => prefix,
                               :name     => dir_name,
                               :metadata => dir_obj,
                               :record   => record)

          dir_obj = [0, 0, 0, 0, 0, 0, 0, 0].concat(dir_obj)
          parse_dir_obj(dir_obj, "#{prefix}\\#{dir_name}")

        elsif entry_type == FILE_ENTRY
          filename = key_bytes[4..-1]
          filename.delete(0)
          filename = filename.pack('C*')


          files <<  FileEntry.new(:prefix   => prefix,
                                  :name     => filename,
                                  :metadata => value,
                                  :record   => record)
        end
      end
    end # class DirBase
  end # module FSDir
end # module Resilience
