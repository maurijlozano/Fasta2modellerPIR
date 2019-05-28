#!/usr/bin/env Rscript
# run with Rscript --vanilla scriptName.R

args = commandArgs(trailingOnly=TRUE)
args <- args[which(args!="")]

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} 


pdb <- args[1]
seqpdb <- args[2]
ali <- args[3]
seqname <- args[4]
artifacts <- args[5]
# test if there is at least one argument: if not, return an error

#read talbe 8:length son missing residues
pdbinfo <- read.table(pdb, header=FALSE, sep=" ", stringsAsFactors=FALSE)
missing <- as.vector(unlist(pdbinfo[8:(length(pdbinfo)-1)]))

#read seq from pdb
pdbseq <- read.table(seqpdb, header=FALSE, sep=" ", stringsAsFactors=FALSE, colClasses = c("character"))
arts <- as.numeric(read.table(artifacts, header=FALSE, sep=" ", stringsAsFactors=FALSE, colClasses = c("character")))

if (pdbinfo[3] > min(arts)){start = min(arts)} else{start =as.numeric(pdbinfo[3])}
if (pdbinfo[4] < max(arts)){end = max(arts)} else{end = as.numeric(pdbinfo[4])}
colnames(pdbseq) <- start:end

pdbseq[grep(paste('^',missing,'$', sep=''),colnames(pdbseq))] <- "-"


#read alignment
aliseqs <- read.table(ali, header=FALSE, sep=" ", stringsAsFactors=FALSE, colClasses = c("character"))
seqname1<-aliseqs[grep(seqname,aliseqs[,1]),1]
seqname2<-aliseqs[grep(seqname,aliseqs[,1],invert=T),1]



seq1 <- read.fwf(textConnection(aliseqs[grep(seqname,aliseqs[,1]),2]), widths = rep(1, ceiling(max(nchar(aliseqs[1,2]) / 1))), stringsAsFactors = FALSE,colClasses = c("character"))
seq2 <- read.fwf(textConnection(aliseqs[grep(seqname,aliseqs[,1],invert=T),2]), widths = rep(1, ceiling(max(nchar(aliseqs[2,2]) / 1))), stringsAsFactors = FALSE,colClasses = c("character"))




#Transform alignment
seq2gaps <- grep('-',seq2)

newseq<-NULL
#seq2 indexes
pa<-1 #last position

for (k in 1:length(seq2gaps)){
	ngaps <- k-1
	#seq2 indexes
	i <- seq2gaps[k] - 1 #the position before the gap on seq2
	if(seq2[i]!="-"){
		#pdbseq indexes
		ic <- i-ngaps #possition before the gap in pdbseq
		pac <- pa # pa-ngaps-ncg
		newseq <- c(newseq,as.vector(unlist(pdbseq[pac:ic])),"-")
		ncg <- 0
		pa<-ic+1 #last position after adding the gap on seq2
	} else {
		newseq <- c(newseq,"-")
	}
}
newseq <- c(newseq,as.vector(unlist(pdbseq[(ic+1):length(pdbseq)])))
newseq <- t(data.frame(newseq))
#info for PIR alignment
first <- pdbinfo[length(pdbinfo)]
#first <- min(grep('-',newseq,invert=T))
lenstruct <- length(grep('-',newseq,invert=T))




fn<-gsub('.fastab','.PIR',ali)
#Write sequence
write.table(paste('c; Converted with Fasta2modelerPIR, by M.J.Lozano'), fn, row.names = F, col.names = F,append=F,quote=F)
write.table(paste('>P1;',seqname1,sep=''), fn, row.names = F, col.names = F,append=T,quote=F)
write.table(paste('sequence:',seqname1,':     : :     : ::: 0.00: 0.00',sep=''), fn, row.names = F, col.names = F,append=T,quote=F)
write.table(cbind(seq1[1,],"*"), fn, row.names = F, sep='', col.names = F,append=T,quote=F)

#Write structure
write.table(paste('>P1;',seqname2,"A",sep=''), fn, row.names = F, col.names = F,append=T,quote=F)
write.table(paste('structureX:',seqname2,'.pdb:',first,'  :A:+',lenstruct,' :A:',pdbinfo[7],':: 0.00: 0.00',sep=''), fn, row.names = F, col.names = F,append=T,quote=F)
write.table(cbind(newseq,"*"), fn, row.names = F, sep='', col.names = F,append=T,quote=F)






