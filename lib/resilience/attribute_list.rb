# ReFS Attribute List
# Copyright (C) 2017 Red Hat Inc.

module Resilience
  # List of attributes whose length / params is defined by its header
  class AttributeList
    include OnImage

    attr_accessor :len
    attr_accessor :pos
    attr_accessor :end_pos
    attr_accessor :type
    attr_accessor :flags

    attr_accessor :bytes

    attr_accessor :attributes

    def initialize(args={})
      @len        = args[:len]
      @pos        = args[:pos]
      @end_pos    = args[:end_pos]
      @flags      = args[:flags]
      @type       = args[:type]
      @bytes      = args[:bytes]
      @attributes = args[:attributes]
    end

    def empty?
      len == 0 || bytes.nil? || bytes.empty?
    end

    def self.read
      orig_pos            = image.pos
      table_header_attr   = Attribute.read
      table_header_dwords = table_header_attr.unpack("L*")
      header_len          = table_header_dwords[0]
      table_len           = table_header_dwords[1]
      padding             = table_header_dwords[2]
      type                = table_header_dwords[3]
      end_pos             = table_header_dwords[4]
      flags               = table_header_dwords[5]
      next_pos            = table_header_dwords[6]
puts  "AL #{orig_pos.to_s(16)}/#{type.to_s(16)}/#{flags.to_s(16)}"

      remaining_len       = table_len - header_len
      puts "remaining #{remaining_len.to_s(16)}"
      orig_pos            = image.pos
      bytes               = image.read remaining_len
      image.seek orig_pos

      attributes = []

      until remaining_len == 0
        attributes    << Attribute.read
        remaining_len -= attributes.last.len
      end

      image.seek orig_pos - header_len + end_pos

      #raise "Mismatched list" unless end_pos == image.pos

      AttributeList.new :len     => table_len,
                        :pos     => orig_pos,
                        :end_pos => end_pos,
                        :flags   => flags,
                        :type    => type,
                        :bytes   => bytes,
                        :attributes => attributes
    end

    def to_s
      bytes.collect { |a| a.to_s(16) }.join(' ')
    end
  end
end # module Resilience
