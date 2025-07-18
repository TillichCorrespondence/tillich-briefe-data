import glob
from pyschematron import validate_document
from pyschematron.utils import load_xml_document
from pathlib import Path
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm


def main():
    print("lets validate!")
    schema = load_xml_document(Path("./odd/out/tillich-schematron.sch"))
    files = sorted(glob.glob("./data/editions/*.xml"))
    for x in tqdm(files, total=len(files)):
        try:
            doc = TeiReader(x).tree
        except Exception as e:
            print(f"failed to parse {x} due to {e}")
        result = validate_document(doc, schema)
        valid = result.is_valid()
        if not valid:
            print(f"{x} is not valid")


if __name__ == "__main__":
    main()
