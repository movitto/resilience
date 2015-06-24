#!/usr/bin/ruby
# ReFS Object Table
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class ObjectTable
    include OnImage

    attr_accessor :pages

    def initialize
      @pages ||= {}
    end

    def self.parse
      table = new
      table.parse_pages
      table
    end

    # Depends on SystemTable extraction
    def object_page_id
      # in the images I've seen this has always been the first entry
      # in the system table, though always has virtual page id = 2
      # which we could look for if this turns out not to be the case
      image.system_table.pages.first
    end

    def parse_pages
      object_page_address = object_page_id * PAGE_SIZE

      # read number of objects from index header
      image.seek(object_page_address + ADDRESSES[:first_attr])
      first_attr  = Attribute.read
      num_objects = first_attr.unpack('L*')[ADDRESSES[:num_objects]/4]

      # start of table attr, skip for now
      Attribute.read

      0.upto(num_objects-1) do
        object_record     = FSDir::Record.read
        object_id         = object_record.key.unpack('C*')

        # here object page is first qword of record value
        object_page       = object_record.value.unpack('Q*').first
        @pages[object_id] = object_page
      end
    end
  end # class ObjectTable
end # module Resilience
