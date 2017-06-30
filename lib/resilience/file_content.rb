# ReFS File COntent
# Copyright (C) 2017 Red Hat Inc.

module Resilience
  class FileContent
    include OnImage

    attr_accessor :entry

    def initialize(file_entry)
      @entry = file_entry
    end

    def raw
      @raw ||= begin
        image.seek entry.content_ptr * PAGE_SIZE
        image.read(entry.len)
      end
    end
  end # class FileContent
end # module Resilience
