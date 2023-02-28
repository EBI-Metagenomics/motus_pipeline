#!/usr/bin/env python3

import argparse
import sys
import os
import gzip
from Bio import SeqIO

directory = "sequence-categorisation"
if not os.path.exists(directory): os.makedirs(directory)

SSU = "SSU_rRNA"
LSU = "LSU_rRNA"
Seq5S = "mtPerm-5S"
Seq5_8S = "5_8S_rRNA"

SSU_rRNA_archaea = "SSU_rRNA_archaea"
SSU_rRNA_bacteria = "SSU_rRNA_bacteria"
SSU_rRNA_eukarya = "SSU_rRNA_eukarya"

LSU_rRNA_archaea = "LSU_rRNA_archaea"
LSU_rRNA_bacteria = "LSU_rRNA_bacteria"
LSU_rRNA_eukarya = "LSU_rRNA_eukarya"


def set_model_names(prefix, name):
    pattern_dict = {}
    pattern_dict[SSU] = os.path.join(directory, f'{name}_SSU.fasta')
    pattern_dict[LSU] = os.path.join(directory, f'{name}_LSU.fasta')
    pattern_dict[Seq5S] = os.path.join(directory, f'{name}_5S.fa')
    pattern_dict[Seq5_8S] = os.path.join(directory, f'{name}_5_8S.fa')
    pattern_dict[SSU_rRNA_archaea] = os.path.join(directory, f'{prefix}{name}_{SSU_rRNA_archaea}.RF01959.fa')
    pattern_dict[SSU_rRNA_bacteria] = os.path.join(directory, f'{prefix}{name}_{SSU_rRNA_bacteria}.RF00177.fa')
    pattern_dict[SSU_rRNA_eukarya] = os.path.join(directory, f'{prefix}{name}_{SSU_rRNA_eukarya}.RF01960.fa')
    pattern_dict[LSU_rRNA_archaea] = os.path.join(directory, f'{prefix}{name}_{LSU_rRNA_archaea}.RF02540.fa')
    pattern_dict[LSU_rRNA_bacteria] = os.path.join(directory, f'{prefix}{name}_{LSU_rRNA_bacteria}.RF02541.fa')
    pattern_dict[LSU_rRNA_eukarya] = os.path.join(directory, f'{prefix}{name}_{LSU_rRNA_eukarya}.RF02543.fa')
    return pattern_dict


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract lsu, ssu and 5s and other models")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-p", "--prefix", dest="prefix", help="prefix for models", required=False)
    parser.add_argument("-n", "--name", dest="name", help="Accession", required=True)

    args = parser.parse_args()
    prefix = args.prefix if args.prefix else ""

    print('Start fasta mode')
    pattern_dict = set_model_names(prefix, args.name)
    open_files = {}
    for record in SeqIO.parse(args.input, "fasta"):
        for pattern in pattern_dict:
            if pattern in record.id:
                if pattern not in open_files:
                    file_out = open(pattern_dict[pattern], 'w')
                    open_files[pattern] = file_out
                SeqIO.write(record, open_files[pattern], "fasta")
    for item in open_files:
        open_files[item].close()
