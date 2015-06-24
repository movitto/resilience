#!/usr/bin/ruby
# ReFS Object Tree
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class ObjectTree
    include OnImage

    attr_accessor :map

    def initialize
      @map ||= {}
    end

    def self.parse
      tree = new
      tree.parse_entries
      tree
    end

    # Depends on Image Pages extraction
    def page
      image.pages.newest_for PAGES[:object_table]
    end

    def parse_entries
      page.attributes.each { |attr|
        obj1 = obj1_from attr
        obj2 = obj2_from attr
        @map[obj1] ||= []
        @map[obj1]  << obj2
      }
    end

    private

    def obj1_from(attr)
      attr.bytes[ADDRESSES[:object_tree_start1]..ADDRESSES[:object_tree_end1]]
    end

    def obj2_from(attr)
      attr.bytes[ADDRESSES[:object_tree_start2]..ADDRESSES[:object_tree_end2]]
    end
  end # class ObjectTree
end # module Resilience
