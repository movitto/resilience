#!/usr/bin/ruby
# ReFS reference analyzer
# By mmorsi - 2014-09-03

require 'graphviz'

CLUSTERS = [0x1e, 0x2e, 0x37, 0x38,
            0x2c0, 0x2c1, 0x2c2, 0x2c3, 0x2c4, 0x2c5, 0x2c6, 0x2c7, 0x2c8, 0x2cc, 0x2cd, 0x2ce, 0x2cf]

DISK     = 'flat-disk.vmdk'
OFFSET   = 0x2100000

inf  = File.open(DISK, 'rb')

refs = {}

CLUSTERS.each do |cluster|
  offset = OFFSET + cluster * 0x4000
  inf.seek(offset + 2) # skip first 2 bytes containing cluster #
  while inf.pos < offset + 0x4000
    checkb = inf.read(2).unpack('S').first
    CLUSTERS.each do |checkc|
      if checkb == checkc
        refs[cluster]         ||= {}
        refs[cluster][checkc] ||=  0
        refs[cluster][checkc]  +=  1
      end
    end
  end
end

inf.close

g = GraphViz.new( :G, :type => :digraph )

refs.keys.each { |cluster|
  g.add_nodes cluster.to_s(16)
}

refs.keys.each { |cluster|
  puts "cluster #{cluster.to_s(16)} references: "
  refs[cluster].keys.each { |ref|
    puts ref.to_s(16) + " (#{refs[cluster][ref]})"
    #g.add_edges(cluster.to_s(16), ref.to_s(16))
    g.add_edges(ref.to_s(16), cluster.to_s(16))
  }
}

g.output :png => 'fan-out.png'
