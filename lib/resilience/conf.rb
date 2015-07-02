#!/usr/bin/ruby
# Reslience Conf
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

module Resilience
  module Conf
    def self.conf
      @conf ||= {}
    end

    def self.method_missing(method, *args)
      if method.to_s =~ /=$/
        conf[method.to_s.match(/^(.*)=$/)[1].to_sym] = args.first
      elsif method.to_s =~ /\?$/
        !!conf[method.to_s.match(/^(.*)\?$/)[1].to_sym]
      else
        conf[method]
      end
    end

    def conf
      Conf
    end
  end # module Conf
end
