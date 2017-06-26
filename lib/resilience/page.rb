#!/usr/bin/ruby
# ReFS Page Representation
# Copyright (C) 2015 Red Hat Inc.

require 'resilience/collections/pages'

module Resilience
  # A Page aka Cluster is the basic organizational unit of the ReFS filesystem.
  # It is a unit of fixed length (see constants.rb) and corresponds to directories
  # and major constructs in the filesystem (object table, volume info, etc)
  class Page
    include OnImage

    attr_accessor :id
    attr_accessor :contents

    attr_accessor :sequence
    attr_accessor :virtual_page_number

    attr_accessor :attributes

    attr_accessor :object_id
    attr_accessor :entries

    def initialize
      @attributes ||= []
    end

    def self.extract_all
      page_id     = PAGES[:first]
      pages       = Pages.new

      image.seek(page_id * PAGE_SIZE)
      while contents = image.read(PAGE_SIZE)
        # only pull out metadata pages currently
        extracted_id   = id_from_contents(contents)
        is_metadata    = extracted_id == page_id
        pages[page_id] = Page.parse(page_id, contents) if is_metadata
        page_id       += 1
      end

      pages
    end

    def self.id_from_contents(contents)
      contents.unpack('S').first
    end

    def offset
      id * PAGE_SIZE
    end

    def attr_start
      offset + ADDRESSES[:first_attr]
    end

    def root?
      virtual_page_number == PAGES[:root]
    end

    def object_table?
      virtual_page_number == PAGES[:object_table]
    end

    def self.parse(id, contents)
      store_pos

      page          = new
      page.id       = id
      page.contents = contents

      image.seek(page.offset + ADDRESSES[:page_sequence])
      page.sequence = image.read(4).unpack('L').first

      image.seek(page.offset + ADDRESSES[:virtual_page_number])
      page.virtual_page_number = image.read(4).unpack('L').first

      unless page.root? || page.object_table?
        # TODO:
        #page.parse_attributes
        #page.parse_metadata
      end

      restore_pos

      page
    end

    def has_attributes?
      !@attributes.nil? && !@attributes.empty?
    end

    def parse_attributes
      image.seek(attr_start)
      while true
        attr = Attribute.read
        break if attr.empty?
        @attributes << attr
      end
    end

    def parse_metadata
      @object_id = @attributes.first.unpack("C*")[ADDRESSES[:object_id]]
      @entries   = @attributes.first.unpack("C*")[ADDRESSES[:num_objects]]
    end
  end # class Page
end # module Resilience
