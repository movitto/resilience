# ReFS 0x4000 Cluster Usage Mapper
# By Willi Ballenthin  2012-03-25
# With modifications by mmorsi - 2014-07-14
import sys, struct

#REFS_VOLUME_OFFSET = 0x2010000
REFS_VOLUME_OFFSET = 0x2100000

def main(args):
    with open(args[1], "rb") as f:
        global REFS_VOLUME_OFFSET
        offset = REFS_VOLUME_OFFSET
        cluster = 0
        while True:
            f.seek(offset + cluster * 0x4000)
            buf = f.read(4)
            if not buf: break
            magic = struct.unpack("<I", buf)[0]
            if magic == cluster:
                print "Metadata cluster %s (%s)" % \
                  (hex(cluster), hex(offset + cluster * 0x4000))
            elif magic != 0:
                print "Non-null cluster %s (%s)" % \
                  (hex(cluster), hex(offset + cluster * 0x4000))
            cluster += 1

if __name__ == '__main__':
    main(sys.argv)
