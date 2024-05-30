# script to add orcid ids to editor nodes

import requests
import glob
from acdh_tei_pyutils.tei import TeiReader


orcids = requests.get("https://raw.githubusercontent.com/TillichCorrespondence/tillich-entities/main/json_dumps/editors.json").json()

lookup_dict = {}
for key, value in orcids.items():
    if len(value["name"]) > 3:
        lookup_dict[value["name"]] = value["orcid_url"]

files = sorted(glob.glob("./data/editions/L*.xml"))

for x in files:
    doc = TeiReader(x)
    editor_node = doc.any_xpath(".//tei:respStmt[./tei:resp]/tei:name")[0]
    editor_name = editor_node.text
    try:
        editor_id = lookup_dict[editor_name]
    except KeyError:
        continue
    editor_node.attrib["key"] = editor_id
    doc.tree_to_file(x)
