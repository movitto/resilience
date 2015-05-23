#!/usr/bin/ruby
# ReFS Image Representation
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Image
    attr_accessor :file
    attr_accessor :offset
    attr_accessor :opts

    attr_accessor :root_dir
    attr_accessor :system_table
    attr_accessor :object_table

    def initialize(args={})
      @file         = args[:file] || []
    end

    def parse
      @system_table = Resilience::SystemTable.parse
      @object_table = Resilience::ObjectTable.parse
      @root_dir     = Resilience::RootDir.parse
    end

    def seek(position)
      @file.seek offset + position
    end

    def pos
      @file.pos - offset
    end

    def read(len)
      @file.read(len)
    end
  end
end # module Resilience
