# Resilience rarser cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def rarser_option_parser
  conf.pages = true

  OptionParser.new do |opts|
    default_options   opts
    image_options     opts
    metadata_options  opts
  end
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

  page_out += page_attribute_output(page) if conf.attributes? && page.has_attributes?
  page_out
end

def pages_output
  image.pages.collect { |page_id, page| page_output(page) }.join
end

def object_table_output
  return "" unless conf.object_table?

  output = image.object_table.pages.collect { |obj_id, cluster|
    "#{obj_id.big_endian_str[0..4]} | #{cluster.big_endian_str}\n"
  }.join

  "\nObject table:\n" \
  "Obj   | Cluster\n" \
  "-------------\n#{output}"
end

def object_tree_output
  return "" unless conf.object_tree?

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
