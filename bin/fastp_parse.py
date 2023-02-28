#!/usr/bin/env python3

import argparse
import json
import sys
import os


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get numbers from fastp report")
    parser.add_argument("--qc-json", dest="input_qc", help="Json from fastp QC", required=False)
    parser.add_argument("--overlap-json", dest="input_overlap", help="Json from fastp overlap reads",
                        required=False)
    parser.add_argument("-o", "--output", dest="output", help="output with stats", required=False, default='output.txt')

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        if not (args.input_qc or args.input_overlap):
            print('No json provided')
            exit(1)
        with open(args.output, 'w') as f_out:
            if args.input_qc:
                with open(args.input_qc, 'r') as f_in:
                    input = json.load(f_in)
                    total_reads = input['summary']['before_filtering']['total_reads']
                    count = total_reads
                    f_out.write(f"Initial reads: {total_reads}\n")
                    filtered_reads = input['summary']['after_filtering']['total_reads']
                    f_out.write(f"Reads passed filters: {filtered_reads}\n")

                    if 'low_quality_reads' in input['filtering_result']:
                        lq = input['filtering_result']['low_quality_reads']
                    f_out.write(f"Low quality reads: {lq}\n")
                    """
                    if 'too_short_reads' in input['filtering_result']:
                        count -= input['filtering_result']['too_short_reads']
                    if 'too_long_reads' in input['filtering_result']:
                        count -=  input['filtering_result']['too_long_reads']
                    f_out.write(f"Length filter: {count}\n")
                    if 'too_many_N_reads' in input['filtering_result']:
                        count -= input['filtering_result']['too_many_N_reads']
                    f_out.write(f"Qualified reads filter: {count}\n")
                    """
            if args.input_overlap:
                with open(args.input_overlap, 'r') as f_in:
                    input = json.load(f_in)
                    # corrected reads?
                    merged_reads = input['merged_and_filtered']['total_reads']
                    f_out.write(f"Merged reads: {merged_reads}\n")


