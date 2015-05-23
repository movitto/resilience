#!/usr/bin/ruby
# ReFS File Lister
# Copyright (C) 2014 Red Hat Inc.

require 'optparse'
require 'colored'

FIRST_PAGE_ID =  0x1e
PAGE_SIZE     =  0x4000
FIRST_PAGE_ADDRESS = FIRST_PAGE_ID * PAGE_SIZE

ROOT_DIR_ID   = [0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0]
DIR_ENTRY     = 0x20030
FILE_ENTRY    = 0x10030

DIR_TREE      = 0x301
DIR_LIST      = 0x200
#DIR_BRANCH    = 0x000 ?

ADDRESSES  = {
  # page
  :virtual_page_number => 0x18,
  :first_attr          => 0x30,

  # page 0x1e
  :system_table_page   => 0xA0,

  # system table
  :system_pages        => 0x58,

  # generic table
  :num_objects         => 0x20, # referenced from start of first attr

  :table_length        => 0x04  # referenced from start of table header
}

def read_attribute(image)
  pos      = image.pos
  attr_len = image.read(4).unpack('L').first
  return nil if attr_len == 0
  image.seek pos

  image.read(attr_len)
end

def record_boundries(attribute)
  header        = attribute.unpack('S*')
  key_offset    = header[2]
  key_length    = header[3]
  value_offset  = header[5]
  value_length  = header[6]
  [key_offset, key_length, value_offset, value_length]
end

def record_flags(attribute)
  attribute.unpack('S*')[4]
end

def record_key(attribute)
  ko, kl, vo, vl = record_boundries(attribute)
  attribute.unpack('C*')[ko...ko+kl].pack('C*')
end

def record_value(attribute)
  ko, kl, vo, vl = record_boundries(attribute)
  attribute.unpack('C*')[vo..-1].pack('C*')
end

def filter_dir_record(dir_entry, opts)
  image = opts[:image]

  # '4' seems to indicate a historical record or similar,
  # records w/ flags '0' or '8' are what we want
  record_flags(dir_entry)== 4 ? filter_dir_record(read_attribute(opts[:image]), opts) : dir_entry 
end

def parse_dir_branch(node, prefix, opts)
  key          = record_key(node)
  value        = record_value(node)
  flags        = record_flags(node)

  value_dwords = value.unpack('L*')
  value_qwords = value.unpack('Q*')

  page_id      = value_dwords[0]
  page_address = page_id * PAGE_SIZE
  checksum     = value_qwords[2]
  parse_dir_page page_address, prefix, opts unless checksum == 0 || flags == 4
end

def parse_dir_record(dir_entry, prefix, opts)
  key        = record_key(dir_entry)
  value      = record_value(dir_entry)

  key_bytes  = key.unpack('C*')
  key_dwords = key.unpack('L*')
  entry_type = key_dwords.first
  if entry_type == DIR_ENTRY
    dir_name = key_bytes[4..-1].pack('L*')
    opts[:dirs] << "#{prefix}\\#{dir_name}"

    dir_obj = value.unpack('C*')[0...8]
    dir_obj = [0, 0, 0, 0, 0, 0, 0, 0].concat(dir_obj)
    parse_dir_obj(dir_obj, "#{prefix}\\#{dir_name}", opts)

  elsif entry_type == FILE_ENTRY
    file_name = key_bytes[4..-1].pack('L*')
    opts[:files] << "#{prefix}\\#{file_name}"
  end
end

def parse_dir_obj(object_id, prefix, opts)
  image        = opts[:image]
  object_pages = opts[:object_pages]
  opts[:dirs]  ||= []
  opts[:files] ||= []

  page_id = object_pages[object_id]
  page_address = page_id * PAGE_SIZE
  parse_dir_page page_address, prefix, opts
end

def parse_dir_page(page_address, prefix, opts)
  image        = opts[:image]
  image_start  = opts[:offset]

  # skip container/placeholder attribute
  image.seek(image_start + page_address + ADDRESSES[:first_attr])
  read_attribute(image)

  # start of table attr, pull out table length, type
  table_header_attr   = read_attribute(image)
  table_header_dwords = table_header_attr.unpack("L*")
  header_len          = table_header_dwords[0]
  table_len           = table_header_dwords[1]
  remaining_len       = table_len - header_len
  table_type          = table_header_dwords[3]

  until remaining_len == 0
    orig_pos = image.pos
    record   = read_attribute(image)

    # need to keep track of position locally as we
    # recursively call parse_dir via helpers
    pos = image.pos

    if table_type == DIR_TREE
      parse_dir_branch record, prefix, opts
    else #if table_type == DIR_LIST
      record = filter_dir_record(record, opts)
      pos = image.pos
      parse_dir_record record, prefix, opts

    end

    image.seek pos
    remaining_len -= (image.pos - orig_pos)
  end
end

def parse_object_table(opts)
  image       = opts[:image]
  image_start = opts[:offset]
  opts[:object_pages] ||= {}

  # in the images I've seen this has always been the first entry
  # in the system table, though always has virtual page id = 2
  # which we could look for if this turns out not to be the case
  object_page_id = opts[:system_pages].first
  object_page_address = object_page_id * PAGE_SIZE

  # read number of objects from index header
  image.seek(image_start + object_page_address + ADDRESSES[:first_attr])
  first_attr  = read_attribute(image)
  num_objects = first_attr.unpack('L*')[ADDRESSES[:num_objects]/4]

  # start of table attr, skip for now
  read_attribute(image)

  0.upto(num_objects-1) do
    object_record  = read_attribute(image)
    object_id      = record_key(object_record).unpack('C*')

    # here object page is first qword of record value
    object_page    = record_value(object_record).unpack('Q*').first
    opts[:object_pages][object_id] = object_page
  end
end

def parse_system_table(opts)
  image       = opts[:image]
  image_start = opts[:offset]
  opts[:system_pages] ||= []

  image.seek(image_start + FIRST_PAGE_ADDRESS + ADDRESSES[:system_table_page])
  system_table_page = image.read(8).unpack('Q').first
  system_table_address = system_table_page * PAGE_SIZE 

  image.seek(image_start + system_table_address + ADDRESSES[:system_pages])
  num_system_pages = image.read(4).unpack('L').first

  0.upto(num_system_pages-1) do
    system_page_offset = image.read(4).unpack('L').first
    pos = image.pos

    image.seek(image_start + system_table_address + system_page_offset)
    system_page = image.read(8).unpack('Q').first
    opts[:system_pages] << system_page

    image.seek(pos)
  end
end

def print_results(opts)
  puts "Dirs found:".bold
  opts[:dirs].each { |dir|
    puts "#{dir}".blue
  }

  puts
  puts "Files found:".bold
  opts[:files].sort.each { |file|
    puts "#{file}".red
  }
end

def main(opts = {})
  image = File.open(opts[:image], 'rb')
  opts[:image] = image

  parse_system_table(opts)
  parse_object_table(opts)
  parse_dir_obj(ROOT_DIR_ID, '', opts)
  print_results(opts)
end

def parse_cli(cli)
  opts   = {}
  parser = OptionParser.new do |popts|
    popts.on("-h", "--help", "Print help message") do
      puts parser
      exit
    end

    popts.on("-i", "--image path", "Path to the disk image to parse") do |path|
      opts[:image] = path
    end

    popts.on("-o", "--offset bytes", "Start of volume with ReFS filesystem") do |offset|
      opts[:offset] = offset.to_i
    end
  end

  begin
    parser.parse!(cli)
  rescue OptionParser::InvalidOption
    puts parser
    exit
  end

  if !opts[:image] || !opts[:offset]
    puts "--image and --offset params are needed at a minimum"
    exit 1
  end

  opts
end

main parse_cli(ARGV) if __FILE__ == $0
