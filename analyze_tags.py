import glob
import pandas as pd
from collections import Counter
from acdh_tei_pyutils.tei import TeiReader


files = glob.glob("./data/editions/*.xml")

elements = []
for x in files:
    try:
        doc = TeiReader(x)
    except:  # noqa:
        continue
    [
        elements.append(str(x).replace("{http://www.tei-c.org/ns/1.0}", ""))
        for x in doc.get_elements()
    ]

element_stats = dict(Counter(elements))
element_list = []
for key, value in element_stats.items():
    element_list.append(
        {"name": key, "nr": value}
    )
df = pd.DataFrame(element_list)
df.sort_values(by="nr").to_csv("tags.csv", index=False)
