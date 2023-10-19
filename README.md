# tillich-briefe-data

repo to work on tillich correspondence TEI/XML data

## fetch_data.py

throw away script to copy data from https://github.com/TillichCorrespondence/TillichEdition/tree/main/data into current repo and to change `.//tei:body//tei:persName|tei:placeName` into `tei:rs @type="person|place` elements and to add `#` to `@ref`