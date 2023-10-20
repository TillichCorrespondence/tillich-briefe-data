import glob
import requests

from acdh_tei_pyutils.tei import TeiReader

person_json = "https://raw.githubusercontent.com/TillichCorrespondence/tillich-entities/main/json_dumps/persons.json"

r = requests.get(person_json)
data = r.json()

lookup_dict = {}
for key, value in data.items():
    lookup_dict[f'#{value["legacy_id"]}'] = f'#{value["tillich_id"]}'

print(lookup_dict)

files = glob.glob("./data/editions/*.xml")
for x in files:
    doc = TeiReader(x)
    for node in doc.any_xpath(".//*[@ref]"):
        old_ref_value = node.attrib["ref"]
        try:
            new_ref_value = lookup_dict["old_ref_value"]
        except KeyError:
            continue
        node.attrib["ref"] = new_ref_value