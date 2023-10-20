import glob
import requests

from acdh_tei_pyutils.tei import TeiReader

person_json = "https://raw.githubusercontent.com/TillichCorrespondence/tillich-entities/main/json_dumps/persons.json"
listperson = "./data/indices/listperson.xml"
r = requests.get(person_json)
data = r.json()

lookup_dict = {}
for key, value in data.items():
    lookup_dict[f'#{value["legacy_id"]}'] = f'#{value["tillich_id"]}'

files = glob.glob("./data/editions/*.xml")
for x in files:
    doc = TeiReader(x)
    for node in doc.any_xpath(".//*[@ref]"):
        try:
            new_ref_value = lookup_dict[node.attrib["ref"]]
            print(new_ref_value)
        except KeyError:
            continue
        node.attrib["ref"] = new_ref_value
    doc.tree_to_file(x)

doc = TeiReader(listperson)
for node in doc.any_xpath(".//tei:person"):
    for node in doc.any_xpath(".//*[@ref]"):
        try:
            new_ref_value = lookup_dict[f'#{node.attrib["{http://www.w3.org/XML/1998/namespace}id"]}']
            print(new_ref_value)
        except KeyError:
            continue
        node.attrib["{http://www.w3.org/XML/1998/namespace}id"] = new_ref_value[1:]
