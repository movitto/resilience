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
  
      def initialize(attribute)
        @attribute = attribute
      end
  
      def self.read
        new(Attribute.read)
      end

      def calc_boundries
        return if @boundries_set
        @boundries_set = true
  
        header         = attribute.unpack('S*')
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
  
        @flags = attribute.unpack('S*')[4]
      end
  
      def flags
        calc_flags
        @flags
      end
  
      def key
        ko, kl, vo, vl = boundries
        attribute.unpack('C*')[ko...ko+kl].pack('C*')
      end
  
      def value
        ko, kl, vo, vl = boundries
        attribute.unpack('C*')[vo..-1].pack('C*')
      end
    end # class Record
  end # module FSDir
end # module Resilience
