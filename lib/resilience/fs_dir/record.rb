#!/usr/bin/ruby
# ReFS Records
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  module FSDir
    # A filesystem attribute which contains a key / value pair whose offsets & lengths
    # are defined in the attribute header
    class Record
      include OnImage
  
      attr_accessor :attribute

      attr_accessor :key_offset,
                    :key_length,
                    :value_offset,
                    :value_length
  
      def initialize(attribute)
        @attribute = attribute
      end
  
      def self.read
        new(Attribute.read)
      end

      def calc_boundries
        return if @boundries_set
        @boundries_set = true
  
        header         = attribute.words
        @key_offset    = header[2]
        @key_length    = header[3]
        @value_offset  = header[5]
        @value_length  = header[6]
      end
  
      def boundries
        calc_boundries
        [@key_offset, @key_length, @value_offset, @value_length]
      end
  
      def calc_flags
        return if @flags_set
        @flags_set = true
  
        @flags = attribute.words[4]
      end
  
      def flags
        calc_flags
        @flags
      end
  
      def key
        ko, kl, vo, vl = boundries
        attribute.bytes[ko...ko+kl].pack('C*')
      end
  
      def value
        ko, kl, vo, vl = boundries
        attribute.bytes[vo..-1].pack('C*')
      end

      def value_pos
        attribute.pos + value_offset
      end

      def key_pos
        attribute.pos + key_offset
      end
    end # class Record
  end # module FSDir
end # module Resilience
