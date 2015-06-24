# Reslience resilience cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'
require 'colored'

def resilience_option_parser
  OptionParser.new do |opts|
    default_options   opts
    image_options     opts
    metadata_options  opts
  end
end

def image_output
  "Analyzed ReFS filesystem on #{conf[:image].green.bold} "\
  "starting at #{conf[:offset].to_s.green.bold}\n"
end

def bytes_per_sector_output
  "#{image.bytes_per_sector.indented.yellow.bold} (bytes per sector)"
end

def sectors_per_cluster_output
  "#{image.sectors_per_cluster.indented.yellow.bold} (sectors per cluster)"
end

def cluster_size_output
  "#{image.cluster_size.indented.yellow.bold} (bytes per cluster)\n"
end

def vbr_output
  "VBR: #{bytes_per_sector_output} * "    \
       "#{sectors_per_cluster_output} = " \
       "#{cluster_size_output}"
end

def header_output
  image_output + vbr_output
end

def page_attribute_output(page)
  output = page.attributes.collect { |attribute|
    "  #{attribute.to_s[0...10]}...\n"
  }.join

  " Attributes:\n" + output
end

def page_output(page)
  page_out = "Page      #{page.id.indented(4).blue.bold}: "                   \
             "number    #{page.virtual_page_number.indented(3).blue.bold} - " \
             "sequence  #{page.sequence.indented(2).blue.bold} - "            \
             "object id #{page.object_id.indented(2).blue.bold} - "           \
             "records   #{page.entries.indented(2).blue.bold}\n"

  page_out += page_attribute_output(page) if attributes_enabled? && page.has_attributes?
  page_out
end

def pages_output
  image.pages.collect { |page_id, page| page_output(page) }.join
end

def object_table_output
  return "" unless object_table_enabled?

  output = image.object_table.pages.collect { |obj_id, cluster|
    "#{obj_id.little_endian[0..4]} | #{cluster.little_endian}\n"
  }.join

  "\nObject table:\n" \
  "Obj   | Cluster\n" \
  "-------------\n#{output}"
end

def object_tree_output
  return "" unless object_tree_enabled?

  output = image.object_tree.map.collect { |obj, refs|
    references = refs.collect { |ref| ref[0..4] }.join(', ')
    "#{obj[0..4]} -> #{references}\n"
  }.join

  "\nObject tree:\n" \
  "-------------\n#{output}"
end

def write_results(image)
  puts header_output
  puts pages_output
  puts object_table_output
  puts object_tree_output
end
