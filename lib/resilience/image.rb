#!/usr/bin/ruby
# ReFS Image Representation
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Image
    include Conf

    attr_accessor :file
    attr_accessor :offset
    attr_accessor :opts

    attr_accessor :bytes_per_sector
    attr_accessor :sectors_per_cluster

    def cluster_size
      @cluster_size ||= bytes_per_sector * sectors_per_cluster
    end

    attr_accessor :root_dir
    attr_accessor :system_table
    attr_accessor :object_table
    attr_accessor :object_tree

    # all pages including shadow pages
    attr_accessor :pages

    def initialize(args={})
      @file         = args[:file] || []
    end

    def parse
      parse_bounds

      # each of these is a seperate parsing process,
      # though later ones may depend on former
      @pages        = Resilience::Page.extract_all  if conf.pages?
      @system_table = Resilience::SystemTable.parse
      @object_table = Resilience::ObjectTable.parse
      @root_dir     = Resilience::RootDir.parse
      @object_tree  = Resilience::ObjectTree.parse  if conf.object_tree?
    end

    def seek(position)
      @file.seek offset + position
    end

    def pos
      @file.pos - offset
    end

    def total_pos
      @file.pos + offset
    end

    def read(len)
      @file.read(len)
    end

    private

    def parse_bounds
      seek(ADDRESSES[:bytes_per_sector])
      @bytes_per_sector = read(4).unpack('L').first

      seek(ADDRESSES[:sectors_per_cluster])
      @sectors_per_cluster = read(4).unpack('L').first
    end
  end
end # module Resilience
