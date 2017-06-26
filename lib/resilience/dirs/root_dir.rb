#!/usr/bin/ruby
# ReFS Root Dir
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  # Root directory of the filesystem
  class RootDir < FSDir::DirBase
    include OnImage

    def self.parse
      dir = new
      dir.parse_dir_obj ROOT_DIR_ID, ''
      dir
    end
  end  # class RootDir
end # module Resilience
