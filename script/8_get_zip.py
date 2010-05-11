import sys


set_zip = set([])
for line in open('../dat/zip_code_utah.txt'):
    zip = line.split()[0].strip()
    set_zip.add(zip)

#print len(set_zip)

print '\n'.join(list(set_zip))
