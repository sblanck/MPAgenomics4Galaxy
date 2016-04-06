args<-commandArgs(TRUE)

input=args[1]
length=as.numeric(args[2])
probes=as.numeric(args[3])
tmp_dir=args[4]
nbcall=as.vector(args[5])
output=args[6]

nbcall_tmp <- strsplit(nbcall,",")
nbcall_vecstring <-unlist(nbcall_tmp)

nbcall_vecstring

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics")
setwd(workdir)

segcall = read.table(input, header = TRUE)
filtercall=filterSeg(segcall,length,probes,nbcall_vecstring)
sink(output)
print(format(filtercall),row.names=FALSE)
sink()
#write.table(filtercall,output,row.names = FALSE, quote = FALSE, sep = "\t")

