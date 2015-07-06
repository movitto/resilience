#!/usr/bin/ruby
# ReFS Constants
# Copyright (C) 2015 Red Hat Inc.

FS_SIGNATURE  = [0x00, 0x00, 0x00, 0x52, 0x65, 0x46, 0x53, 0x00] # ...ReFS.

PAGE_SIZE     =  0x4000

ROOT_DIR_ID   = [0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0]
DIR_ENTRY     = 0x20030
FILE_ENTRY    = 0x10030

DIR_TREE      = 0x301
DIR_LIST      = 0x200
#DIR_BRANCH    = 0x000 ?

PAGES = {
  # page id's:
  :first        => 0x1e,

  # virtual page numbers:
  :root         => 0x00,
  :object_table => 0x02,
  :object_tree  => 0x03
}

ADDRESSES  = {
  # size / bounds
  :bytes_per_sector    => 0x20,
  :sectors_per_cluster => 0x24,

  # page
  :page_sequence       => 0x08, # shadow pages share the same virtual page number
  :virtual_page_number => 0x18,
  :first_attr          => 0x30,

  # on page 0x1e:
  :system_table_page   => 0xA0,

  # on system table:
  :system_pages        => 0x58,

  # generic table:
  # referenced from start of first attr
  :object_id           => 0x0C,
  :num_objects         => 0x20,

  # referenced from start of table header
  :table_length        => 0x04,

  # object tree:
  :object_tree_start1 => 0x10,
  :object_tree_end1   => 0x1F,
  :object_tree_start2 => 0x20,
  :object_tree_end2   => 0x2F
}
