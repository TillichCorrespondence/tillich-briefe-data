import glob
from acdh_tei_pyutils.tei import TeiReader

print("makes sure all @ref in <tei:rs> start with '#'")
files = sorted(glob.glob("./data/editions/*.xml"))
for x in files:
    try:
        doc = TeiReader(x)
    except Exception as e:
        print(e)
        continue
    for y in doc.any_xpath(".//tei:rs[@ref]"):
        ref = y.attrib["ref"]
        if ref[0] == '#':
            pass
        else:
            y.attrib["ref"] = f"#{ref}"
    doc.tree_to_file(x)