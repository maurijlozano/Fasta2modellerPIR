#!/bin/bash

ALI=0
PDB=0
CHAIN=0
SEQ=""
show_help()
{
echo "
        Usage: fasta2modellerPIR.sh -a alignment_file -p pdb_file -c protein_chain -s sequence_name
        
        -h Show this Help
        -a fasta alignment file
        -p PDB file
        -s Sequence iD as in the fasta file.
        -c chain
"

echo -e '\nConverts fasta alignment to modeller PIR file. Only for One chain which must be specified.\n\n'

exit 1
}

while getopts ":ha:s:c:p:" option; do
    case "${option}" in
        h) show_help
            exit 1
            ;;
        a) ALI=$OPTARG;;
        p) PDB=$OPTARG;;
        c) CHAIN=$OPTARG;;
        s) SEQ=$OPTARG;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1
            ;;
        :)  echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done



if [[ $# -eq 0 ]] ; then
    echo 'Parameters required, run -h for help'
    exit 1
fi

if [[ ${ALI} == 0 ]] ; then
    echo 'Parameters -a alingment file required, run -h for help'
    exit 1
fi

if [[ ${PDB} == 0 ]] ; then
    echo 'Parameters -p, pdb file required, run -h for help'
    exit 1
fi

if [[ ${CHAIN} == 0 ]] ; then
	CHAIN=A
    echo 'Using chain A, for other chains selection use -c argument'
fi

if [[ ${SEQ} == "" ]] ; then
	echo 'Parameters -s, sequence name required.'
    exit 1
fi

SEQ=$(echo "${SEQ}" | sed -E 's/([^ ]*) .*/\1/')
#Extracting missing residues and other information
cat "${PDB}" | grep -E 'REMARK 465     \w{3} '${CHAIN}' {3,5}' | sed -E 's/REMARK 465     \w{3} \w {3,5}//' | sed -E 's/ //g' | tr '\n' ' ' | sed -E 's/ $//' > remark465.txted

cat "${PDB}" | grep -E 'SEQADV {1,5}[0-9a-zA-Z]{4,6} {1,5}[a-zA-Z]{1,5} '${CHAIN}'' | sed -E 's/SEQADV {1,5}[0-9a-zA-Z]{4,6} {1,5}[a-zA-Z]{1,5} '${CHAIN}' {1,5}(-?[0-9]{1,5}).*/\1/' | tr '\n' ' ' | sed -E 's/ $//' > arts.txt


cat "${PDB}" | grep -E 'DBREF {1,5}[0-9A-Za-z]{1,5} '${CHAIN}'' |  sed -e 's/DBREF//' -e 's/^ *//' -e 's/ *$//' -e 's/ $//' |  sed  -E 's/ {1,8}[0-9]{1,5} {1,5}[0-9]{1,5}$//'  | sed -E 's/ {1,10}/ /g' > PDBSEQ.tab
cat "${PDB}" | grep -E 'ATOM {1,8}1 {1,5}[A-Za-z]{1} {1,5}[A-Za-z]{1,5} '${CHAIN}''|  sed -E 's/(ATOM) {1,8}1 {1,5}[A-Z] {1,5}[A-Za-z]{1,5} '${CHAIN}' {1,5}(-?[0-9]{1,4}) .*/\2/' > PDBSEQ.first

paste -d' ' PDBSEQ.tab remark465.txted PDBSEQ.first > PDBSEQ.table


cat "${PDB}" | grep -E 'SEQRES {1,5}[0-9]{1,2} '${CHAIN}'' | sed -E 's/SEQRES   ?[0-9]{1,2} \w  [0-9]{1,3}  //' | sed -E 's/ {1,50}$//g'| tr '\n' ' ' | sed -e 's/MET/M/g' -e 's/PHE/F/g' -e 's/LEU/L/g' -e 's/ILE/I/g' -e 's/VAL/V/g' -e 's/SER/S/g' -e 's/PRO/P/g' -e 's/THR/T/g' -e 's/ALA/A/g' -e 's/TYR/Y/g' -e 's/HIS/H/g' -e 's/GLN/Q/g' -e 's/ASN/N/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/CYS/C/g' -e 's/TRP/W/g' -e 's/ARG/R/g' -e 's/LYS/K/g' -e 's/GLY/G/g' -e 's/ $/\n/' > PDBSEQ_"${CHAIN}".seq

if [[ $(cat "${PDB}" | grep -E 'MODRES {1,5}[0-9a-zA-Z]{4,6} {1,5}[a-zA-Z]{1,5} '${CHAIN}'') ]];then echo "Modified residues found.";  cat "${PDB}" | grep -E 'MODRES {1,5}[0-9a-zA-Z]{4,6} {1,5}[a-zA-Z]{1,5} '${CHAIN}'' > ModifiedRES.txt;fi


#Processing fasta alingment
cat "${ALI}" | perl -pe 'unless(/^>/){s/ //g;s/\n//g;s/\r//g}; if(/>/){s/([^ ]*) .*/$1/;s/\n/ /g;s/\r//g; s/>/\n/}' | sed '/^$/d' > "${ALI}tab"

#Running R script
Rscript --vanilla fasta2modellerPIR.R PDBSEQ.table PDBSEQ_"${CHAIN}".seq "${ALI}tab" "${SEQ}" arts.txt 2> /dev/null
echo "Cleaning"
rm PDBSEQ.tab remark465.txted PDBSEQ.first arts.txt PDBSEQ.table "${ALI}tab" PDBSEQ_A.seq
echo "Done"

