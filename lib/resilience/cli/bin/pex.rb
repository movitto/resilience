# Resilience pex cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def pex_option_parser
  OptionParser.new do |opts|
    default_options    opts
    image_options      opts
    output_fs_options  opts
  end
end

def target_clusters
  @target_clusters ||= [0x1e,  0x20,  0x21,  0x22,  0x28, 0x29,
                        0x2a,  0x2b,  0x2c,  0x2d,  0x2e, 0x2f,
                        0x30,  0x31,  0x32,  0x33,  0x34, 0x35,
                        0x36,  0x37,  0x38,
                        0x2c0, 0x2c1, 0x2c2, 0x2c3, 0x2c4,
                        0x2c5, 0x2c6, 0x2c7, 0x2c8, 0x2cc,
                        0x2cd, 0x2ce, 0x2cf]
end

def extract
  create_output_dir!
  setup_image

  target_clusters.each do |cluster|
    extract_cluster cluster
  end
end

def extract_cluster(cluster)
  out = File.open("#{conf[:dir]}/#{cluster.to_s(16)}", 'wb')
  offset = cluster * PAGE_SIZE
  image.seek(offset)
  contents = image.read(PAGE_SIZE)
  out.write contents
  out.close
end
