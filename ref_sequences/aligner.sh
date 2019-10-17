#!bin/bash
#usage: bash aligner.sh *.fasta
for refseqs in *.fasta
do
./muscle3.8.31_i86linux64 -in $refseqs >> aligned.fasta
done
