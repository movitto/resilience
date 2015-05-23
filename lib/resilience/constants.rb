#!/usr/bin/ruby
# ReFS Constants
# Copyright (C) 2015 Red Hat Inc.

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
