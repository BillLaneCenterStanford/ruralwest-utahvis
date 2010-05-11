
import sys
from xml.dom.minidom import Document

def atomNode(doc, field_name, value_text):
    result_node = doc.createElement(field_name)
    text_node = doc.createTextNode(value_text)
    result_node.appendChild(text_node)
    return result_node

fi = sys.argv[1]
fo = sys.argv[2]
#fi = '../dat/utah_by_zip_1998.txt'
#fo = '../dat/utah_by_zip_1998.xml'
print fi
# create a document object and append a records node
doc = Document()
records = doc.createElement('records')
doc.appendChild(records)

line_to_skip = 1
for line in open(fi):
    print line
    # skip initial lines
    if line_to_skip > 0:
        line_to_skip -= 1
        continue

    # create a user data node
    user = doc.createElement('area')

    [zip, year, aprn, pa, ph, panp, pop, change_ph, change_panp, change_pop] = line.strip().split('\t')

    user.appendChild(atomNode(doc, 'zip', zip))
    user.appendChild(atomNode(doc, 'year', year))

    user.appendChild(atomNode(doc, 'aprn', aprn))
    user.appendChild(atomNode(doc, 'pa', pa))
    user.appendChild(atomNode(doc, 'ph', ph))
    user.appendChild(atomNode(doc, 'panp', panp))
    user.appendChild(atomNode(doc, 'pop', pop))
    user.appendChild(atomNode(doc, 'change_ph', change_ph))
    user.appendChild(atomNode(doc, 'change_panp', change_panp))
    user.appendChild(atomNode(doc, 'change_pop', change_pop))

    #user.appendChild(atomNode(doc, 'countyname', countyname))
    #user.appendChild(atomNode(doc, 'fips', fips))
    #user.appendChild(atomNode(doc, 'category', category))
    #user.appendChild(atomNode(doc, 'ph', ph))
    #user.appendChild(atomNode(doc, 'papn', papn))
    #user.appendChild(atomNode(doc, 'pop', pop))
    #user.appendChild(atomNode(doc, 'abs_change_ph', abs_change_ph))
    #user.appendChild(atomNode(doc, 'abs_change_papn', abs_change_papn))
    #user.appendChild(atomNode(doc, 'change_ph', change_ph))
    #user.appendChild(atomNode(doc, 'change_papn', change_papn))

    records.appendChild(user)

print doc.toprettyxml()
doc.writexml(open(fo, 'w'), indent = '  ', addindent = '  ', newl='\n')

