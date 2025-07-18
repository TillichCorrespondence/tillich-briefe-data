import glob
import time
from pyschematron import validate_document
from pyschematron.utils import load_xml_document
from pathlib import Path
from acdh_tei_pyutils.tei import TeiReader
import lxml.etree as ET


def main():
    print("lets validate!")
    start_time = time.time()

    schematron_path = Path("./odd/out/tillich-schematron.sch")
    schematron_schema = load_xml_document(schematron_path)

    with open("./odd/out/tillich-briefe.rng", "r") as rng_file:
        rng_doc = ET.parse(rng_file)
        relaxng_schema = ET.RelaxNG(rng_doc)

    files = sorted(glob.glob("./data/editions/*.xml"))
    for x in files:
        try:
            doc = TeiReader(x).tree
        except Exception as e:
            print(f"failed to parse {x} due to {e}")
            continue

        schematron_result = validate_document(doc, schematron_schema)
        schematron_valid = schematron_result.is_valid()
        relaxng_valid = relaxng_schema.validate(doc)

        if not schematron_valid:
            print(f"{x} is not valid according to Schematron schema")

        if not relaxng_valid:
            print(f"{x} is not valid according to RelaxNG schema")
            for error in relaxng_schema.error_log:
                print(f"  - {error}")

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"finished validating {len(files)} files in "
          f"{elapsed_time:.2f} seconds")


if __name__ == "__main__":
    main()
