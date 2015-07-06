#!/usr/bin/ruby
# ReFS Boot Table
# Copyright (C) 2015 Red Hat Inc.

module Resilience
  class BootTable
    include OnImage

    SECTOR_SIZE = 0x200

    def refs_offsets
      offsets = []
      fs_off = fs_offsets
      image.offset = 0
      fs_off.each do |address|
        image.seek address
        sig = image.read(FS_SIGNATURE.size).unpack('C*')
        offsets << address if sig == FS_SIGNATURE
      end
      offsets
    end

    def refs_offset
      refs_offsets.first
    end
  end

  class MBR < BootTable
    SIG_ADDRESS         =  0x1FE
    SIG                 = [0x55, 0xAA]
    PARTITION_ADDRESSES = [0x1C6, 0x1D6, 0x1E6, 0x1F6]

    def detected?
      image.seek SIG_ADDRESS
      sig = image.read(2)
      sig == SIG
    end

    def fs_offsets
      offsets = []
      PARTITION_ADDRESSES.each do |address|
        image.seek address
        address = image.read(4).unpack('V').first
        offsets << address * SECTOR_SIZE unless address == 0
      end
      offsets
    end

    def gpt_offsets
      offsets = []
      fs_offsets.each do |address|
        image.seek address
        sig = image.read(GPT::SIG.size).unpack('C*')
        offsets << address if sig == GPT::SIG
      end
      offsets
    end

    def gpt_offset
      gpt_offsets.first
    end
  end # class MBR

  class GPT < BootTable
    NUM_ADDRESS      = 0x50
    PARTITIONS_START = 0x200 # from the current image offset, the start of gpt partition
    PARTITION_SIZE   = 0x80
    OFFSET_ADDRESS   = 0x20

    SIG = [0x45, 0x46, 0x49, 0x20, 0x50, 0x41, 0x52, 0x54] # EFI PART

    def num
      image.seek NUM_ADDRESS
      image.read(4).unpack('V').first
    end

    def fs_offsets
      offsets = []
      0.upto(num-1) do |i|
        image.seek PARTITIONS_START + i * PARTITION_SIZE
        partition = image.read(PARTITION_SIZE).unpack('C*')
        offset    = partition[OFFSET_ADDRESS...OFFSET_ADDRESS+8].pack('C*').unpack('V').first
        offsets << offset * SECTOR_SIZE
        break if offset == 0
      end
      offsets
    end
  end # class GPT
end # module Resilience
