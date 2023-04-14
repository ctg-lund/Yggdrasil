#!/usr/bin/env bash

fastqc --threads 8 -o $2 $1/*gz