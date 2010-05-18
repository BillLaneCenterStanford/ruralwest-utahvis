# TODO
# first compute diff from 1998 to 2003 and store in utah_by_zip_2003
import sys

f_in = sys.argv[1]
f_out = sys.argv[2]

dict_pop = {}
for line in open(f_in):
    segs = line.strip().split()
    zip = segs[1]
    pop = segs[4]
    dict_pop[zip] = pop

#print dict_pop
#print len(dict_pop)

for line in open(f_out):
    segs = line.strip().split()
    zip = segs[0]
    if zip in dict_pop.keys():
        segs[6] = dict_pop[zip]  # change to population
    new_line = '\t'.join(segs)
    print new_line

