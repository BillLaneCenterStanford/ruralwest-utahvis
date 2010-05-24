import re
import os
import sys


dictZipName = {}
line_to_skip = 1
for line in open('population_utah_zip_1998.txt'):
    if line_to_skip > 0:
        line_to_skip -= 1
        continue
    segs = line.strip().split()
    dictZipName[segs[1]] = segs[2]

setZipPh = set([])
line_to_skip = 1
for line in open('utah_by_zip_1998.txt'):
    if line_to_skip > 0:
        line_to_skip -= 1
        continue
    segs = line.strip().split()
    if int(segs[4]) > 0 or int(segs[5]) > 0:
        setZipPh.add(segs[0])

setZipPop = set(dictZipName.keys())
for z in setZipPop:
    if not z in setZipPh:
        print z
