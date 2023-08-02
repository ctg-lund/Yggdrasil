#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2023-07-14 14:43:51
# @Author  : Lokesh Mano (lokeshwaran.manoharan@nbis.se)
# @Link    : link
# @Version : 1.0.0

import re
import sys
import argparse
import csv

usage = """
We will use this script to parse the CTG sample sheet and 
extract information necessary for Yggdrasil. At the moment it only 
takes the project ids from the run and species the deliveries for 
each project.
"""

parser = argparse.ArgumentParser(description=usage)


parser.add_argument(
    "-i",
    "--infile",
    dest="infile",
    type=argparse.FileType("r"),
    help="CTG sample sheet",
    required=True,
)

parser.add_argument(
    "-o",
    "--outfile",
    dest="outfile",
    type=argparse.FileType("w"),
    help="Parsed csv that Yggdrasil can read",
    default=sys.stdout,
)

args = parser.parse_args()

def parse_samplesheet(file_obj):
    lines = file_obj.readlines()

    start_parsing = False
    cleaned_data = []
    for line in lines:
        if "[BCLConvert_Data]" in line:
            start_parsing = True
            continue
        if start_parsing:
            row = re.sub(r',+$', '', line.rstrip('\n'))  # remove trailing commas
            cleaned_data.append(row)

    return cleaned_data

args.outfile.write(parse_samplesheet(args.infile))
args.outfile.close()
args.infile.close()
