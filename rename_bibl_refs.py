import glob
import requests
from acdh_tei_pyutils.tei import TeiReader

print("replacing @ref values for <rs type='work'>")
data = requests.get(
    "https://github.com/TillichCorrespondence/tillich-entities/raw/refs/heads/main/json_dumps/bibls.json"  # noqa:
).json()

lookup = {}
for key, value in data.items():
    lookup[value["tillich_id"]] = value["zotero"]


files = sorted(glob.glob("./data/editions/*.xml"))
for x in files:
    doc = TeiReader(x)
    for y in doc.any_xpath(".//tei:rs[@ref and @type='work']"):
        ref = y.attrib["ref"][1:]
        try:
            new_ref = lookup[ref]
        except KeyError:
            continue
        y.attrib["ref"] = f"#tillich__{new_ref}"
    doc.tree_to_file(x)
