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
muscle -in $combined_gene -out $SeqName.afa
done

hmmbuild builtcombined_hsp.hmm combined_hsp.afa
hmmbuild builtcombined_mcrA.hmm combined_mcrA.afa


mv built*.hmm ../proteomes
cd ../proteomes

for proteome in proteome*.fasta
do
ProteomeName=$(echo $proteome | sed -E 's/\.fasta//g')
hmmsearch --tblout table_mcrA_$ProteomeName.txt builtcombined_mcrA.hmm $proteome
hmmsearch --tblout table_hsp_$ProteomeName.txt builtcombined_hsp.hmm $proteome
done

for tables in table_mcrA_proteome_*.txt
do
ProtName=$(echo $tables | sed -E 's/table_mcrA_.+_//g'| sed -E 's/\.txt//g')
mcrA_matches=$(cat $tables | grep -v "\#" | wc -l)
echo $ProtName","$mcrA_matches >> final_mcrA.csv
done

for tables in table_hsp_proteome_*.txt
do
ProtName=$(echo $tables | sed -E 's/table_hsp_.+_//g'| sed -E 's/\.txt//g')
hsp_matches=$(cat $tables | grep -v "\#" | wc -l)
echo $ProtName","$hsp_matches >> final_hsp.csv
done

touch listofproteomes.csv
join -t , -1 1 -2 1 final_mcrA.csv final_hsp.csv | head -n 50 | sort -nr -t , -k2,2 -k3 >> listofproteomesnoheader.csv
mv listofproteomesnoheader.csv ..
cd ..

echo "Proteome,mcrA hits,hsp70 hits" > ProteomeListTitled.csv
cat listofproteomesnoheader.csv >> ProteomeListTitled.csv
echo "Ordered list of Proteomes by presence of mcrA then hsp70 genes"
cat ProteomeListTitled.csv

cat listofproteomesnoheader.csv | grep -E ".+, [^0], [^0]" > recommended_table_no_header.csv
echo "pH-Resistant Methanogenic Proteomes" > recommended_candidates.txt
cat recommended_table_no_header.csv | cut -d , -f 1 >> recommended_candidates.txt


echo "

See recommended_candidates.txt for a list of pH-resistant methanogenic proteomes,
and summary table ProteomeListTitled.csv for full results."

rm recommended_table_no_header.csv
rm listofproteomesnoheader.csv

cd ./proteomes
rm *.csv
rm *.txt
mv *.hmm ..

cd ../ref_sequences
rm combined*
