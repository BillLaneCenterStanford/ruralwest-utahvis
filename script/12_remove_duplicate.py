import sys

setLine = set([])
for line in open(sys.argv[1]):
    setLine.add(line.strip())

print '\n'.join(setLine)
