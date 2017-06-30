# ReFS Record
# Copyright (C) 2015-2017 Red Hat Inc.

module Resilience
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

    def key_offset
      @key_offset ||= attribute.words[2]
    end

    def key_length
      @key_length ||= attribute.words[3]
    end

    def flags
      @flags ||= attribute.words[4]
    end

    def value_offset
      @value_offset ||= attribute.words[5]
    end

    def value_length
      @value_offset ||= attribute.words[6]
    end

    def boundries
      [key_offset, key_length, value_offset, value_length]
    end

    def key
      @key ||= begin
        ko, kl, vo, vl = boundries
        attribute.bytes[ko...ko+kl].pack('C*')
      end
    end

    def value
      @value ||= begin
        ko, kl, vo, vl = boundries
        attribute.bytes[vo..-1].pack('C*')
      end
    end

    def value_bytes
      @value_bytes ||= value.unpack("C*")
    end

    def value_words
      @value_words ||= value.unpack("S*")
    end

    def value_dwords
      @value_dwords ||= value.unpack("L*")
    end

    def value_qwords
      @value_qwords ||= value.unpack("Q*")
    end

    def value_pos
      attribute.pos + value_offset
    end

    def key_pos
      attribute.pos + key_offset
    end
  end # class Record
end # module Resilience
