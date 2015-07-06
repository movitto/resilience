# Resilience Core Ruby Extensions
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.

class String
  def indented(places=1)
    rjust(places, '0').upcase
  end
end

class Fixnum
  def indented(places=1)
    '0x' + to_s(16).rjust(places, '0').upcase
  end

  def big_endian_str
    [self].big_endian_str
  end
end

class NilClass
  def indented(places=1)
    '0x' + ('0' * places)
  end
end

class Array
  def big_endian_str
    str = '0x'
    value = false
    reverse_each { |b|
      next if b == 0 && !value
      value = true
      str += b.to_s(16)
    }
    str
  end
end
