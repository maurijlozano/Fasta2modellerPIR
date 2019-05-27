# Fasta2modellerPIR
Script to convert an alignment of only 2 sequences from fasta to modeller PIR format.

For usage run:
```
./fasta2modellerPIR.sh -h

        Usage:fasta2modellerPIR.sh [-a] [-p] [-c] [-s]
        
        -h Show this Help
        -a fasta alignment file
        -p PDB file
        -s Sequence iD
        -c chain


Converts fasta alignment to modeller PIR file. Only for One chain which must be specified.

```
## The scripts only works for an alignmet of two sequences, and for one chain.

-s sequence iD, must be the name of the sequence to model, as it is on the alingment fasta file.


## For alignments copied from FFas, additional care should be taken.
As an example, for 4n81 alingment with SMc04042, the c terminal residue of 4n81 was not aligned. All the protein residues must be in the alingment for the script to work.
