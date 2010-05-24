import sys

count = {}
count['1998'] = 0
count['2003'] = 0
for year in ['1998', '2003']:
    for line in open('../dat/utah_by_zcta_' + year + '.txt'):
        segs = line.strip().split()
        if segs[2] != '0' or segs[3] != '0':
            count[year] += 1

print count

