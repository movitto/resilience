#!/usr/bin/ruby
# ReFS Attributes
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Attribute
    include OnImage

    attr_accessor :bytes

    def initialize(args={})
      @bytes = args[:bytes] if args.key?(:bytes)
    end

    def self.read
      pos      = image.pos
      attr_len = image.read(4).unpack('L').first
      return new if attr_len == 0

      image.seek pos
      new(:bytes => image.read(attr_len))
    end

    def unpack(format)
      bytes.unpack(format)
    end
  end
end # module Resilience
