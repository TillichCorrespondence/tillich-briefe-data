import glob
import time
from pathlib import Path

import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader
from pyschematron import validate_document
from pyschematron.utils import load_xml_document


def main():
    print("lets validate!")
    start_time = time.time()

    schematron_path = Path("./odd/out/tillich-schematron.sch")
    schematron_schema = load_xml_document(schematron_path)
    rng_path = Path("./odd/out/tillich-briefe.rng")

    with open(rng_path, "r") as rng_file:
        rng_doc = ET.parse(rng_file)
        relaxng_schema = ET.RelaxNG(rng_doc)

    files = sorted(glob.glob("./data/editions/*.xml"))
    # counters for summary
    valid_count = 0
    invalid_count = 0
    schematron_invalid_count = 0
    relaxng_invalid_count = 0
    parse_fail_count = 0

    for x in files:
        try:
            doc = TeiReader(x).tree
        except Exception as e:
            print(f"failed to parse {x} due to {e}")
            # treat parse failures as invalid
            invalid_count += 1
            parse_fail_count += 1
            continue

        schematron_result = validate_document(doc, schematron_schema)
        schematron_valid = schematron_result.is_valid()
        relaxng_valid = relaxng_schema.validate(doc)

        if not schematron_valid:
            print(f"{x} is not valid according to Schematron schema")
            schematron_invalid_count += 1

        if not relaxng_valid:
            print(f"{x} is not valid according to RelaxNG schema")
            for error in relaxng_schema.error_log:
                print(f"  - {error}")
            relaxng_invalid_count += 1

        # overall validity: valid only if both checks passed
        if schematron_valid and relaxng_valid:
            valid_count += 1
        else:
            invalid_count += 1

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"finished validating {len(files)} files in {elapsed_time:.2f} seconds")
    print(f"valid files: {valid_count}")
    print(f"invalid files: {invalid_count} (includes {parse_fail_count} parse failures)")
    print(f"  - invalid according to Schematron: {schematron_invalid_count}")
    print(f"  - invalid according to RelaxNG: {relaxng_invalid_count}")


if __name__ == "__main__":
    main()
