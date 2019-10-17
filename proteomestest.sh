#!bin/bash
#usage: bash proteomes.sh
#allows start from directory bioinformatics_project2019/
#script relies on having muscle program binary copied as /usr/local/bin/muscle
#hmmer command binaries must also be located in /usr/local/bin/

cd ./ref_sequences
cat hsp*.fasta > combined_hsp.fasta
cat mcrA*.fasta > combined_mcrA.fasta

for combined_gene in combined*.fasta
do
SeqName=$(echo $combined_gene | sed -E 's/\.fasta//g')
echo $SeqName
muscle -in $combined_gene -out $SeqName.afa | hmmbuild built$SeqName.hmm $SeqName.afa
done


mv built*.hmm ../proteomes
cd ../proteomes

for proteome in proteome*.fasta
do
ProteomeName=$(echo $proteome | sed -E 's/\.fasta//g')
hmmsearch --tblout table_mcrA_$ProteomeName.txt builtcombined_mcrA.hmm $proteome
hmmsearch --tblout table_hsp_$ProteomeName.txt builtcombined_hsp.hmm $proteome
done

for tables in table_*.txt
cat $tables | grep -v "\#" | wc -l >> hsp_match_table.txt

for tables in table_mcrA*.txt


