#!/usr/bin/ruby
# ReFS On Image Mixin
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  module OnImage
    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.image
      @image ||= Resilience::Image.new
    end

    def image
      OnImage.image
    end

    module ClassMethods
      def image
        OnImage.image
      end
    end
  end # module OnImage
end # module Resilience
