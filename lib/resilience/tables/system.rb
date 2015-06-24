#!/usr/bin/ruby
# ReFS System Table
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class SystemTable
    include OnImage

    attr_accessor :pages

    def initialize
      @pages = []
    end

    def self.parse
      table = new
      table.parse_pages
      table
    end

    def self.first_page_address
      PAGES[:first] * PAGE_SIZE
    end

    def parse_pages
      image.seek(self.class.first_page_address + ADDRESSES[:system_table_page])
      system_table_page    = image.read(8).unpack('Q').first
      system_table_address = system_table_page * PAGE_SIZE 

      image.seek(system_table_address + ADDRESSES[:system_pages])
      num_system_pages = image.read(4).unpack('L').first

      0.upto(num_system_pages-1) do
        system_page_offset = image.read(4).unpack('L').first
        pos = image.pos

        image.seek(system_table_address + system_page_offset)
        system_page = image.read(8).unpack('Q').first
        @pages << system_page

        image.seek(pos)
      end
    end
  end # class SystemTable
end # module Resilience
