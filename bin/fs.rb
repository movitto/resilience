#!/usr/bin/ruby
# ReFS file searcher
# By mmorsi - 2014-09-03

DISK     = 'flat-disk.vmdk'
OFFSET   = 0x2100000

SEQUENCE_LENGTH = 8
SEQUENCE = 0xe010002800000038 # inverted due to endian ordering

inf  = File.open(DISK, 'rb')
inf.seek(OFFSET)

while check = inf.read(SEQUENCE_LENGTH)
  check = check.unpack('Q').first
  if check == SEQUENCE
    puts 'File at: 0x' + inf.pos.to_s(16) + ' cluster ' + ((inf.pos - OFFSET) / 0x4000).to_s(16)
  end
end

inf.close
