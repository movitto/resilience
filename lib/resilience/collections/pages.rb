#!/usr/bin/ruby
# ReFS Pages Collection
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class Pages < Hash
    def with_number(virtual_page_number)
      select { |page_id, page| page.virtual_page_number == virtual_page_number }
    end

    def newest_for(virtual_page_number)
      pages = with_number(virtual_page_number)
      pages.values.sort { |p1, p2| p2.sequence <=> p1.sequence }.first
    end
  end
end
