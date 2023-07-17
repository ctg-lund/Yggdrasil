#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2023-07-14 14:43:51
# @Author  : Lokesh Mano (lokeshwaran.manoharan@nbis.se)
# @Link    : link
# @Version : 1.0.0

import os
import re
import sys
import copy
import argparse

usage = """We will use this script to parse the CTG sample sheet and extract information necessary for Yggdrasil. At the moment it only takes the project ids from the run and species the deliveries for each project."""

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

p0 = re.compile("\[Yggdrasil_Projects\]")
p1 = re.compile("\[Yggdrasil_Samples\]")
p2 = re.compile("\,")

count = 0

for line in args.infile:
    line = line.rstrip("\n")
    if re.match(p1, line) is not None:
        count = 0
    if count > 0:
        if re.match(p2, line) is None:
            print(line, file=args.outfile)
    if re.match(p0, line) is not None:
        count += 1

args.outfile.close()
args.infile.close()
