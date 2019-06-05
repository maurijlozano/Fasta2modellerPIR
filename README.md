Fasta2modellerPIR
=================

# Script to convert an alignment of only 2 sequences from fasta to modeller PIR format.

For usage run:
```
./fasta2modellerPIR.sh -h

        Usage:fasta2modellerPIR.sh -a alignment -p structure.pdb -c chain -s sequence ID
        
        -h Show this Help
        -a fasta alignment file
        -p PDB file
        -s Sequence ID
        -c chain


Converts fasta alignment to modeller PIR file. Only for One chain which must be specified.

```
## The scripts only works for an alignment of two sequences, and for one chain.

-s sequence iD, must be the name of the sequence to model, as it is on the alingment fasta file.


## For alignments copied from FFas, HHPRED, etc additional care should be taken.
Please verify that the alignment contains all the amino acids present on the pdb SEQRES field.
If the crystallized protein contains an expression tag, please verify that the sequence used for the alignment doesn't have the tag residues, since  N-ter and C-ter expression tags will be removed.

## For domain modelling!
For domain modelling, the alignment must be of the domains. The script will work fine both, if the pdb has the complete protein sequence under 'SEQREF' or only the domain sequence. Any failure in the script will be related, possibly to abnormal numeration  or missing/ added positions (such as cloning artifacts).

## Modified Residues
If the protein has modified residues an output file will be created. Modified residues are replaced by gaps for modelling. If you with to model modified residues please refer to Modeller help.
