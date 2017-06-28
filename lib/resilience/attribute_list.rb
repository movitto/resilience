# ReFS Attribute List
# Copyright (C) 2017 Red Hat Inc.

module Resilience
  # List of attributes whose length / params is defined by its header
  class AttributeList
    include OnImage

    # List header is a small attribute which appears at the start of the list
    class Header
      include OnImage

      attr_accessor :attribute

      def initialize(attr)
        @attribute = attr
      end

      def self.read
        new Attribute.read
      end

      def self.parse(pos, bytes)
        new Attribute.parse(pos, bytes)
      end

      # From my observations this is always 0x20
      def len
        @len ||= attribute.dwords[0]
      end

      def total_len
        @total_len ||= attribute.dwords[1]
      end

      def body_len
        @body_len ||= total_len - len
      end

      # XXX: Not 100% sure this field corresponds to padding (but it often lines up like so)
      def padding
        @padding ||= attribute.dwords[2]
      end

      def type
        @type ||= attribute.dwords[3]
      end

      def end_pos
        @end_pos ||= attribute.dwords[4]
      end

      def flags
        @flags ||= attribute.dwords[5]
      end

      def next_pos
        @next_pos ||= attribute.dwords[6]
      end
    end

    attr_accessor :header
    attr_accessor :pos
    attr_accessor :bytes
    attr_accessor :attributes

    def initialize(args={})
      @header     = args[:header]
      @pos        = args[:pos]
      @bytes      = args[:bytes]
      @attributes = args[:attributes]
    end

    def empty?
      len == 0 || bytes.nil? || bytes.empty?
    end

    def self.read
      header        = Header.read
      remaining_len = header.body_len
      orig_pos      = image.pos
      bytes         = image.read remaining_len
      image.seek orig_pos

      attributes = []

      until remaining_len == 0
        attributes    << Attribute.read
        remaining_len -= attributes.last.len
      end

      image.seek orig_pos - header.len + header.end_pos

      AttributeList.new :header     => header,
                        :pos        => orig_pos,
                        :bytes      => bytes,
                        :attributes => attributes
    end

    def self.parse(pos, bytes)
      header = Header.parse pos, bytes
      remaining_len = header.body_len

      attributes = []

      until remaining_len == 0
        start_pos   = pos + header.total_len - remaining_len
        start_index = header.total_len - remaining_len

        # XXX we don't know length of this attribute until we parse it,
        #     thus we pass in all bytes starting at index w/ assumption
        #     that Attribute.parse will only store what is applicable
        attributes    << Attribute.parse(start_pos, bytes[start_index..-1])

        remaining_len -= attributes.last.len
      end

      AttributeList.new :header     => header,
                        :pos        => pos,
                        :bytes      => bytes[header.len..-1],
                        :attributes => attributes
    end

    def to_s
      bytes.collect { |a| a.to_s(16) }.join(' ')
    end
  end
end # module Resilience
