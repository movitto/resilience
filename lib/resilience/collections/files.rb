#!/usr/bin/ruby
# ReFS Files Collection
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Files < Array
    def byte_map
      bytes = []
      each do |file|
        0.upto(file.metadata.size-1) do |byte_index|
          bytes[byte_index] ||= {}
          bytes[byte_index][file] = file.metadata[byte_index]
        end
      end
      bytes
    end

    def bytes_diff
      map = byte_map
      different_bytes = []
      0.upto(map.size-1).each do |byte_index|
        bytes = map[byte_index].values
        different = bytes.uniq.size != 1 || bytes.size != size
        different_bytes << (different ? map[byte_index] : nil)
      end
      different_bytes
    end
  end
end
