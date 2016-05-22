#!/usr/bin/python
import sys
import getopt
import re
import os
import array

Known_patterns = {}
Level = 0

# this is the grok pattern I want to expand
#pattern='%{IP:junk} %{COMBINEDAPACHELOG:junk2}';
#pattern='%{IP:junk}(\s+)Lars%{IP}'

def replacePattern(p):
    global Level
    global Known_patterns

    Level = Level + 1
    print "p = ", p, "Level = ", Level
    reMacro = re.compile("(%\{([^:\}]+)(:?)([^\}]*?)\})")
    me = reMacro.search(p)
    while me:
        tag = me.group(1)
        name = me.group(2)
        separator = me.group(3)
        label = me.group(4)
        print "name: ", name
        print "tag: ", tag
        print "sep: ", separator
        print "label: ", label
        print "pos: ", me.pos
        print "endpos: ", me.endpos
        print "start: ", me.start(2)
        print "end: ", me.end(2)
        print "prefix: ", p[0:me.pos]
        print "postfix: ", p[me.endpos:]
        print "pattern: ", p
        if label:
            p = p[0:me.start(2)-2] + "(?<" + label + ">" + replacePattern(Known_patterns[name]) + ")" + p[me.end(2)+2+len(label):]
        else:
            p = p[0:me.start(2)-2] + replacePattern(Known_patterns[name]) + p[me.end(2)+1:]
        print "pattern1: ", p
        me = reMacro.search(p,me.end(2))
    print "returning: ", p,"\n";
    Level = Level - 1
    return p


def loadPatterns(files):
    global Known_patterns

    for f in files:
        if os.path.isdir(f):
           print "getting files from directory: ", f
           d_files = os.listdir(f)
           loadPatterns(d_files)

        
        else:
            fd = open(f, 'r')
            for line in fd:
                line.rstrip("\r\n")
                rePat = re.compile("^(\S+) (.*)")
                me = rePat.search(line)
                if me is not None:
                    print "inserting name: ", me.group(1), " value: ", me.group(2)
                    Known_patterns[me.group(1)] = me.group(2)
            fd.close()

def main(argv):
   usage='conv_grok.py -i <inputfile|inputDir> [-i <inputfile|inputDir] -p <pattern>'
   inputfiles = []
   nifiles=0
   pattern=""
   try:
      opts, args = getopt.getopt(argv,"hi:p:",["ifile=","pattern="])
   except getopt.GetoptError:
      print usage
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print usage
         sys.exit()
      elif opt in ("-i", "--ifile"):
         nifiles = nifiles + 1
         inputfiles.append(arg)
      elif opt in ("-p", "--pattern"):
         pattern = arg
   print 'Input file(s): '
   for f in inputfiles:
       print f
   print 'pattern is: ', pattern

   loadPatterns(inputfiles)
    
   pattern = replacePattern(pattern)
   print pattern,"\n";

if __name__ == "__main__":
   main(sys.argv[1:])

