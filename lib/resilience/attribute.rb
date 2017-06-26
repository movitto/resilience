# ReFS Attribute
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  # FS component of a length specified by it's first four bytes.
  #
  # Attributes may exist as standalone entities in the file system or may
  # correspond to directory Records and Lists (see corresponding classes)
  class Attribute
    include OnImage

    attr_accessor :pos
    attr_accessor :bytes
    attr_accessor :len

    def initialize(args={})
      @pos   = args[:pos]
      @bytes = args[:bytes]
      @len   = args[:len]
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
puts "len #{attr_len.to_s(16)}"

      image.seek pos
      value = image.read(attr_len)
      new(:pos => pos, :bytes => value, :len => attr_len)
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
