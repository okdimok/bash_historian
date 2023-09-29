#!/usr/bin/env python
import argparse
import json
import logging
import csv

def get_from_recursive_dict(kk, d):
    ks = kk.split(".")
    current_v = d 
    for k in ks:
        if isinstance(current_v, dict):
            if k not in current_v.keys():
                return ""
            current_v = current_v[k]
        elif isinstance(current_v, list) or isinstance(current_v, tuple):
            try:
                k = int(k)
                current_v = current_v[k]
            except (ValueError, IndexError):
                return ""
        else:
            return ""
    return current_v


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--in-jsonl', type=argparse.FileType('r'), required=True)
    parser.add_argument('--out-csv', type=argparse.FileType('w'), required=True)
    parser.add_argument('-f', '--fields', nargs="+", default=["inform.prompt", "inform.text", "inform.answer", "inform.sub-paragraphs"])
    args = parser.parse_args()

    csvwriter = csv.writer(args.out_csv)
    ov_data_map = {}
    
    lines = 0
    for l in args.in_jsonl:
        lines += 1
        lj = json.loads(l)
        row = []
        for k in args.fields:
            row += [get_from_recursive_dict(k, lj)]
        csvwriter.writerow(row)

    print(f"Total {lines}")
