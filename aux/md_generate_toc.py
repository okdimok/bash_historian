#!/usr/bin/env python3
import argparse
import json
import re
import logging

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--in-file', type=argparse.FileType('r'), required=True)

    args = parser.parse_args()

    inside_code = False
    for l in args.in_file:
        if l.startswith("```"):
            inside_code = not inside_code
            continue
        if not inside_code and l.strip().startswith("#"):
            just_title = re.sub(r"^#+", "", l).strip()
            title_hash = just_title.lower().replace(" ", "-")
            h_level = len(re.search(r"^(#+)", l).group(0))
            print("  "*(h_level - 1) + f"[{just_title}](#{title_hash})")



    

    


