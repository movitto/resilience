# ReFS FileTimeStamps Attribute
# Copyright (C) 2017 Red Hat Inc.

module Resilience
  module FSDir
    # Special type of Attribute residing in File Metadata Entry containing timestamps
    class FileTimeStampsAttribute
      attr_accessor :attribute

      def initialize(args={})
        @attribute = Attribute.new(args)
      end

      # XXX: it seems the actual offset of the timestamps is given
      # by the 5th byte, though perhaps these are unrelated
      def timestamps_offset
        @timestamps_offset ||= attribute.bytes[4]
      end

      def timestamps_bytes
        @timestamps_bytes ||= attribute[timestamps_offset..(timestamps_offset + 31)]
      end

      def raw_timestamps
        @raw_timestamps ||= timestamps_bytes.each_slice(8).to_a
      end

      # convert timestamp to local format :-D
      def formatted_timestamps
        @formatted_timestamps ||= raw_timestamps.collect { |ts|
          tsi = ts.pack("C*").unpack("Q*").first
          Time.at(tsi / 10000000 - 11644473600)
        }
      end
    end
  end # module FSDir
end # module Resilience
