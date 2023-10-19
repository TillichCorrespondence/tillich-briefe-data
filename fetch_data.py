import os
import tarfile
import glob
import requests
import shutil

from acdh_tei_pyutils.tei import TeiReader

out_dir = "./data/editions"

url = "https://api.github.com/repos/TillichCorrespondence/TillichEdition/tarball"
target_file = "tmp.tar.gz"
tmp_dir = "tmp"
shutil.rmtree(tmp_dir, ignore_errors=True)


print(f"fetching data from {url}")
response = requests.get(url, stream=True)
if response.status_code == 200:
    with open(target_file, "wb") as f:
        f.write(response.raw.read())

print(f"extracting {target_file} into {tmp_dir}")
file = tarfile.open(target_file)
file.extractall(tmp_dir)
file.close()
os.remove(target_file)


files = sorted(glob.glob("tmp/**/data/L*.xml"))
for x in files:
    _, tail = os.path.split(x)
    doc = TeiReader(x)
    for node in doc.any_xpath(".//tei:body//tei:persName"):
        node.tag = "rs"
        node.attrib["type"] = "person"
        try:
            ref = node.attrib["ref"]
        except KeyError:
            continue
        node.attrib["ref"] = f"#{ref}"
    for node in doc.any_xpath(".//tei:body//tei:placeName"):
        node.tag = "rs"
        node.attrib["type"] = "place"
        try:
            ref = node.attrib["ref"]
        except KeyError:
            continue
        node.attrib["ref"] = f"#{ref}"
    doc.tree_to_file(os.path.join(out_dir, tail))


shutil.rmtree(tmp_dir, ignore_errors=True)

print("copy listperson")
doc = TeiReader("https://raw.githubusercontent.com/TillichCorrespondence/TillichEdition/main/data/people.xml")
doc.tree_to_file(os.path.join("data", "indices", "listperson.xml"))
