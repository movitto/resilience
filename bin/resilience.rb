#!/usr/bin/ruby
# resilience.rb - Ruby ReFS Parser

require 'optparse'
require 'colored'

FIRST_PAGE_ID =  0x1e
PAGE_SIZE     =  0x4000

# note I believe we can also use the object-id's
# of these entities
ROOT_PAGE_NUMBER         = 0x00
OBJECT_TABLE_PAGE_NUMBER = 0x02
OBJECT_TREE_PAGE_NUMBER  = 0x03

ADDRESSES  = {
  # vbr
  :bytes_per_sector    => 0x20,
  :sectors_per_cluster => 0x24,

  # page
  :page_sequence       => 0x08, # shadow pages share the same virtual page number
  :virtual_page_number => 0x18, # but will have higher sequences
  :first_attr          => 0x30,

  # index header
  :object_id           => 0xC,  # possibly index type of similar
  :entries_count       => 0x20
}

def unpack_attribute(image)
  pos      = image.pos
  attr_len = image.read(4).unpack('L').first
  return nil if attr_len == 0
  image.seek pos

  image.read(attr_len).unpack('C*')
end

def process_attributes(image, start)
  attributes = []
  image.seek(start)
  while true
    attribute = unpack_attribute(image)
    break if attribute.nil?
    attributes << attribute
  end

  attributes
end

# Large object table seems to have a special edge case w/
# an extra 0x40 data block, haven't deduced meaning of this yet
def process_object_table_attributes(image, start)
  image.seek(start)

  attributes = []

  # unpack first three attributes as normal
  attributes << unpack_attribute(image)
  attributes << unpack_attribute(image)
  attributes << unpack_attribute(image)

  # XXX hacky edge case detection, if next two bytes are 0,
  # handling as extended block, skipping for now
  if image.read(2).unpack('S').first == 0
    image.seek(38, IO::SEEK_CUR)
  else
    image.seek(-2, IO::SEEK_CUR)
  end

  # process rest of attributes as normal
  attributes + process_attributes(image, image.pos)
end

# Extract additional metadata from attributes
def inspect_attributes(attributes)
  return {} if attributes.empty?

  object_id = attributes.first[ADDRESSES[:object_id]]
  entries   = attributes.first[ADDRESSES[:entries_count]]
  {:object_id => object_id, :entries => entries}
end

def parse_pages(data, opts)
  image       = data[:image]
  image_start = opts[:offset]

  data[:pages].keys.each { |page|
    page_offset = page * PAGE_SIZE

    image.seek(image_start + page_offset + ADDRESSES[:page_sequence])
    page_sequence = image.read(4).unpack('L').first

    image.seek(image_start + page_offset + ADDRESSES[:virtual_page_number])
    virtual_page_number = image.read(4).unpack('L').first

    attributes_start = image_start + page_offset + ADDRESSES[:first_attr]

    if virtual_page_number == ROOT_PAGE_NUMBER
      # skipping root page analysis until it is further understood
      is_root = true

    elsif virtual_page_number == OBJECT_TABLE_PAGE_NUMBER
      attributes = process_object_table_attributes(image, attributes_start)

    else
      attributes = process_attributes image, attributes_start
    end

    data[:pages][page][:sequence]            = page_sequence
    data[:pages][page][:virtual_page_number] = virtual_page_number

    unless is_root
      data[:pages][page][:attributes]        = attributes
      data[:pages][page].merge! inspect_attributes(attributes)
    end
  }
end

def volume_metadata(data, opts)
  image       = data[:image]
  image_start = opts[:offset]

  image.seek(image_start + ADDRESSES[:bytes_per_sector])
  bytes_per_sector = image.read(4).unpack('L').first

  image.seek(image_start + ADDRESSES[:sectors_per_cluster])
  sectors_per_cluster = image.read(4).unpack('L').first

  cluster_size = bytes_per_sector * sectors_per_cluster

  {:bytes_per_sector    => bytes_per_sector,
   :sectors_per_cluster => sectors_per_cluster,
   :cluster_size        => cluster_size }
end

def pages(data, opts)
  image       = data[:image]
  image_start = opts[:offset]
  page        = FIRST_PAGE_ID
  pages       = {}
  
  image.seek(image_start + page * PAGE_SIZE)
  while contents = image.read(PAGE_SIZE)
    # only pull out metadata pages currently
    is_metadata = contents.unpack('S').first == page
    pages[page] = {:contents => contents} if is_metadata

    page += 1
  end

  pages
end

# Convert an array of bytes in little endian order to human friendly string
def little_endian_str(bytes)
  str = '0x'
  value = false
  bytes.reverse_each { |b|
    next if b == 0 && !value
    value = true
    str += b.to_s(16)
  }
  str
end

def object_table_page_id(data)
  # find shadow page w/ highest sequence
  data[:pages].keys.select { |p| data[:pages][p][:virtual_page_number] == OBJECT_TABLE_PAGE_NUMBER }
                   .sort   { |p1, p2| data[:pages][p2][:sequence] <=> data[:pages][p1][:sequence]  }.first
end

def object_table(data, opts)
  table = {}
  page  = data[:pages][object_table_page_id(data)]

  # XXX this could start from the 2nd attribute if the exception in
  #     process_table_attributes does _not_ apply, need to investigate furthur / fix
  page[:attributes][3...-1].each { |bytes|
    # bytes 4-7 give us the key offset & length and
    key_offset = bytes[4..5].pack('C*').unpack('S').first.to_i
    key_length = bytes[6..7].pack('C*').unpack('S').first.to_i

    # bytes A-D give us the value offset & length
    value_offset = bytes[0xA..0xB].pack('C*').unpack('S').first.to_i
    value_length = bytes[0xC..0xD].pack('C*').unpack('S').first.to_i

    key   = bytes[key_offset...key_offset+key_length]
    value = bytes[value_offset...value_offset+value_length]

    cluster_bytes = value[0..7]
    # TODO extract 'type' from value[3a..3d]a (?)

    object_id   = key.pack('C*')
    cluster     = cluster_bytes.pack('C*')

    object_str  = little_endian_str(key)
    cluster_str = little_endian_str(cluster_bytes)

    table[object_id] = {:object_str  => object_str,
                        :cluster     => cluster,
                        :cluster_str => cluster_str}
  }
  
  table
end

def object_tree_page_id(data)
  # find shadow page w/ highest sequence
  data[:pages].keys.select { |p| data[:pages][p][:virtual_page_number] == OBJECT_TREE_PAGE_NUMBER }
                   .sort   { |p1, p2| data[:pages][p2][:sequence] <=> data[:pages][p1][:sequence]  }.first
end

def object_tree(data, opts)
  tree = {}
  page  = data[:pages][object_tree_page_id(data)]

  page[:attributes][2...-1].each { |bytes|
    obj1_bytes = bytes[0x10..0x1F]
    obj2_bytes = bytes[0x20..0x2F]

    obj1 = little_endian_str(obj1_bytes)
    obj2 = little_endian_str(obj2_bytes)

    tree[obj1] ||= []
    tree[obj1]  << obj2
  }

  tree
end

def data_str(data, str_opts = {})
  places = str_opts[:places] || 1

  return '0x'+ ('0' * places) if data.nil?
  '0x'+data.to_s(16).rjust(places, '0').upcase
end

def print_results(data, opts)
  out = "Analyzed ReFS filesystem on #{opts[:image].green.bold} "\
        "starting at #{opts[:offset].to_s.green.bold}\n" \
        "VBR: #{data_str(data[:bytes_per_sector]).to_s.yellow.bold} (bytes per sector) * " \
        "#{data_str(data[:sectors_per_cluster]).to_s.yellow.bold} (sectors per cluster) = " \
        "#{data_str(data[:cluster_size]).to_s.yellow.bold} (bytes per cluster)\n"

  data[:pages].keys.each { |page_id|
    page  = data[:pages][page_id]

    page_out = "Page #{data_str(page_id, :places => 4).blue.bold}: "\
               "number #{data_str(page[:virtual_page_number], :places => 3).blue.bold} - " \
               "sequence #{data_str(page[:sequence], :places => 2).blue.bold} - " \
               "object id #{data_str(page[:object_id], :places => 2).blue.bold} - " \
               "records #{data_str(page[:entries], :places => 2).blue.bold}\n"

    if opts[:attributes] && page[:attributes]
      page_out += " Attributes:\n"
      page[:attributes].each { |attr_values|
        attr_out  = attr_values.collect { |a| a.to_s(16) }.join(' ')[0...10] +'...'
        page_out += '  ' + attr_out + "\n"
      }
    end

    out += page_out
  }

  if opts[:object_table]
    out += "\nObject table:\n"
    out += "Obj   | Cluster\n"
    out += "-------------\n"
    data[:object_table].keys.each { |obj_id|
      object_str = data[:object_table][obj_id][:object_str]
      cluster    = data[:object_table][obj_id][:cluster_str]
      out += "#{object_str[0..4]} | #{cluster}\n"
    }
  end

  if opts[:object_tree]
    out += "\nObject tree:\n"
    out += "-------------\n"
    data[:object_tree].keys.each { |obj_id|
      references = data[:object_tree][obj_id].collect { |obj| obj[0..4] }.join(', ')
      out += "#{obj_id[0..4]} -> #{references}\n"
    }
  end

  puts out
end

def main(opts = {})
  image = File.open(opts[:image], 'rb')

  data = {}
  data[:image] = image

  data.merge! volume_metadata(data, opts)
  data.merge! :pages         => pages(data, opts)

  parse_pages data, opts

  data.merge! :object_table  => object_table(data, opts)
  data.merge! :object_tree   => object_tree(data, opts)

  print_results data, opts
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

    popts.on("-a", "--attributes", "Include attribute analysis in output") do
      opts[:attributes] = true
    end

    popts.on("--table", "Include object table analysis in output") do
      opts[:object_table] = true
    end

    popts.on("--tree", "Include object tree analysis in output") do
      opts[:object_tree] = true
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
