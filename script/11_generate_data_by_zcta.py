import sys
import re

###############################################################################
# construct a redundant dict with all possible zcta's in utah shape file
###############################################################################
d = {}
for line in open('../dat/zcta_utah.txt'):
    zcta = line.strip()

    d[zcta] = {}
    d[zcta]['1998'] = {'PH':'0', 'PA':'0', 'APRN':'0', 'POP':'0'}
    d[zcta]['2003'] = {'PH':'0', 'PA':'0', 'APRN':'0', 'POP':'0'}
#print d


###############################################################################
# fill d with physician data in utah
###############################################################################
for line in open('../dat/Utah_by_zip.csv'):
    [zcta, year, type, count] = line.strip().split(',')
    if d.has_key(zcta):  # ignore those zcta's not in shape file
        d[zcta][year][type] = count
#print d


###############################################################################
# fill d with population data
###############################################################################
for line in open('../dat/population_zcta_us_2000.txt'):
    segs = line.strip().split()
    zcta = segs[0][2:]
    pop = segs[3]
    if d.has_key(zcta):
        d[zcta]['1998']['POP'] = pop
        d[zcta]['2003']['POP'] = pop
#print d


###############################################################################
# output as required by utah viz 
###############################################################################
print 'zcta\tyear\tpanp\tph\tpop\tchange_panp\tchange_ph\tchange_pop'
for year in ['1998', '2003']:
    for zcta in d.keys():
        # compute panp
        panp = str(int(d[zcta][year]['PA']) + int(d[zcta][year]['APRN']))

        # compute change of stats
        change_panp = 0
        change_ph = 0
        if year == '2003':
            change_panp = int(d[zcta]['2003']['PA']) + \
                          int(d[zcta]['2003']['APRN']) - \
                          int(d[zcta]['1998']['PA']) - \
                          int(d[zcta]['1998']['APRN'])
            change_ph = int(d[zcta]['2003']['PH']) - \
                        int(d[zcta]['1998']['PH'])
        change_pop = 0
        try:
            pop = int(d[zcta][year]['POP'])
        except ValueError:
            pop = 0
        print '%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d' % (zcta, year, panp, d[zcta][year]['PH'], pop, change_panp, change_ph, change_pop)










