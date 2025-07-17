#!/usr/bin/env python3
"""
Fast XML Validation Script using Python lxml
Validates XML files against RelaxNG schema with parallel processing
"""

import os
import sys
import time
import argparse
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime

try:
    from lxml import etree
except ImportError:
    print("Error: lxml is not installed. Install it with: pip install lxml")
    sys.exit(1)


def validate_single_file(xml_file_path, rng_schema_path):
    """Validate a single XML file against RelaxNG schema"""
    try:
        # Load the RelaxNG schema
        with open(rng_schema_path, 'rb') as f:
            relaxng_doc = etree.parse(f)
        relaxng = etree.RelaxNG(relaxng_doc)
        
        # Parse the XML file
        parser = etree.XMLParser(remove_blank_text=True)
        try:
            doc = etree.parse(xml_file_path, parser)
        except etree.XMLSyntaxError as e:
            return {
                'file': xml_file_path,
                'valid': False,
                'error': f"XML Syntax Error: {e}"
            }
        
        # Validate against schema
        if not relaxng.validate(doc):
            errors = []
            for error in relaxng.error_log:
                errors.append(f"Line {error.line}, Col {error.column}: {error.message}")
            return {
                'file': xml_file_path,
                'valid': False,
                'error': "; ".join(errors[:3])  # First 3 errors only
            }
        else:
            return {
                'file': xml_file_path,
                'valid': True,
                'error': None
            }
            
    except Exception as e:
        return {
            'file': xml_file_path,
            'valid': False,
            'error': f"Unexpected error: {e}"
        }


def find_xml_files(xml_dir):
    """Find all XML files in directory"""
    xml_files = []
    for root, dirs, files in os.walk(xml_dir):
        for file in files:
            if file.endswith('.xml'):
                xml_files.append(os.path.join(root, file))
    return xml_files


def main():
    parser = argparse.ArgumentParser(description='Validate XML files against RelaxNG schema')
    parser.add_argument('--xml-dir', default='data/editions', help='Directory containing XML files')
    parser.add_argument('--schema', default='odd/out/tillich-briefe.rng', help='RelaxNG schema file')
    parser.add_argument('--workers', type=int, default=4, help='Number of parallel workers')
    parser.add_argument('--report', default='validation-report.txt', help='Output report file')
    parser.add_argument('--verbose', action='store_true', help='Show all files being processed')
    parser.add_argument('--no-interactive', action='store_true', help='Skip confirmation prompt')
    
    args = parser.parse_args()
    
    # Check if files exist
    if not os.path.exists(args.schema):
        print(f"Error: Schema file not found: {args.schema}")
        sys.exit(1)
        
    if not os.path.exists(args.xml_dir):
        print(f"Error: XML directory not found: {args.xml_dir}")
        sys.exit(1)
    
    # Find XML files
    xml_files = find_xml_files(args.xml_dir)
    total_files = len(xml_files)
    
    if total_files == 0:
        print(f"No XML files found in {args.xml_dir}")
        sys.exit(1)
    
    print(f"Found {total_files} XML files to validate")
    print(f"Schema: {args.schema}")
    print(f"Using {args.workers} parallel workers")
    
    # Test with one file first
    print("Testing with one file...")
    test_file = xml_files[0]
    print(f"Test file: {test_file}")
    
    test_result = validate_single_file(test_file, args.schema)
    if test_result['valid']:
        print("Test file is VALID")
    else:
        print("Test file is INVALID")
        print(f"Error: {test_result['error']}")
        sys.exit(1)
    
    # Ask for confirmation (unless in non-interactive mode)
    if not args.no_interactive and os.getenv('CI') != 'true':
        response = input("\nContinue with full validation? (y/N): ")
        if response.lower() != 'y':
            print("Exiting...")
            sys.exit(0)
    else:
        print("Running in non-interactive mode, proceeding with validation...")
    
    # Start validation
    start_time = time.time()
    print("Starting parallel validation...")
    
    valid_count = 0
    invalid_count = 0
    invalid_files = []
    
    # Process files in parallel
    with ProcessPoolExecutor(max_workers=args.workers) as executor:
        # Submit all tasks
        future_to_file = {
            executor.submit(validate_single_file, xml_file, args.schema): xml_file 
            for xml_file in xml_files
        }
        
        # Process results as they complete
        for i, future in enumerate(as_completed(future_to_file), 1):
            result = future.result()
            
            if result['valid']:
                valid_count += 1
                if args.verbose:
                    print(f"✅ {result['file']}")
            else:
                invalid_count += 1
                invalid_files.append(result)
                print(f"❌ {result['file']}")
                if invalid_count <= 5:  # Show details for first 5 invalid files
                    print(f"   Error: {result['error']}")
            
            # Show progress every 50 files
            if i % 50 == 0 or i == total_files:
                print(f"Progress: {i}/{total_files}")
    
    # Calculate duration
    end_time = time.time()
    duration = int(end_time - start_time)
    performance = total_files / duration if duration > 0 else total_files
    
    # Write report
    with open(args.report, 'w') as f:
        f.write("XML Validation Report\n")
        f.write("=====================\n")
        f.write(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Schema: {args.schema}\n")
        f.write(f"Total files: {total_files}\n\n")
        
        if invalid_files:
            for result in invalid_files:
                f.write(f"INVALID: {result['file']}\n")
                f.write(f"Error: {result['error']}\n\n")
        
        f.write("VALIDATION SUMMARY\n")
        f.write("==================\n")
        f.write(f"Total files:     {total_files}\n")
        f.write(f"Valid files:     {valid_count}\n")
        f.write(f"Invalid files:   {invalid_count}\n")
        f.write(f"Duration:        {duration}s\n")
        f.write(f"Performance:     {performance:.1f} files/second\n\n")
        f.write("Note: RelaxNG structure validation completed\n")
        f.write("Warning: Schematron rules not validated (requires Saxon)\n")
    
    # Console summary
    print("\nVALIDATION SUMMARY")
    print("================================")
    print(f"Total files:     {total_files}")
    print(f"Valid files:     {valid_count}")
    print(f"Invalid files:   {invalid_count}")
    print(f"Duration:        {duration}s")
    print(f"Performance:     {performance:.1f} files/second")
    print("================================")
    
    if invalid_count > 0:
        print("\nINVALID FILES:")
        for result in invalid_files[:10]:
            print(f"  {result['file']}")
        if len(invalid_files) > 10:
            print(f"  ... and {len(invalid_files) - 10} more files")
        
        print(f"\nDetailed report written to: {args.report}")
        print("Note: RelaxNG structure validation completed")
        print("Warning: Schematron rules not validated")
        sys.exit(1)
    else:
        print(f"\n🎉 All files are valid!")
        print(f"Report written to: {args.report}")
        print("RelaxNG structure validation: PASSED")
        print("Warning: Schematron rules not validated")


if __name__ == "__main__":
    main()