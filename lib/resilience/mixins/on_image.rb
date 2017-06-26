#!/usr/bin/ruby
# ReFS On Image Mixin
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  # Helper module mixed into various classes allowing easy read
  # access to the underyling disk image
  module OnImage
    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.image
      @image ||= Resilience::Image.new
    end

    def self.store_pos
      @image_pos ||= []
      @image_pos.unshift image.pos
    end

    def self.restore_pos
      image.seek @image_pos.shift
    end

    def image
      OnImage.image
    end

    def store_pos
      OnImage.store_pos
    end

    def restore_pos
      OnImage.restore_pos
    end

    module ClassMethods
      def image
        OnImage.image
      end

      def store_pos
        OnImage.store_pos
      end

      def restore_pos
        OnImage.restore_pos
      end
    end
  end # module OnImage
end # module Resilience
