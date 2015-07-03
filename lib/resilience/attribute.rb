#!/usr/bin/ruby
# ReFS Attributes
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Attribute
    include OnImage

    attr_accessor :pos
    attr_accessor :bytes

    def initialize(args={})
      @pos   = args[:pos]
      @bytes = args[:bytes]
    end

    def empty?
      bytes.nil? || bytes.empty?
    end

    def self.read
      pos = image.pos
      packed = image.read(4)
      return new if packed.nil?
      attr_len = packed.unpack('L').first
      return new if attr_len == 0

      image.seek pos
      value = image.read(attr_len)
      new(:pos => pos, :bytes => value)
    end

    def unpack(format)
      bytes.unpack(format)
    end

    def [](key)
      return bytes[key]
    end

    def to_s
      bytes.collect { |a| a.to_s(16) }.join(' ')
    end
  end
end # module Resilience
