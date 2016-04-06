args<-commandArgs(TRUE)

chrom=args[1]
dataset=args[2]
output=args[3]
tmp_dir=args[4]
input=args[5]
outputfigures=type.convert(args[6])
tumorcsv=args[7]
user=args[8]
method=args[9]

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics",user)
setwd(workdir)

if (grepl("all",tolower(chrom)) | chrom=="None") {
	chrom_vec=c(1:25)
} else {
	chrom_tmp <- strsplit(chrom,",")
	chrom_vecstring <-unlist(chrom_tmp)
	chrom_vec <- as.numeric(chrom_vecstring)
}

input_tmp <- strsplit(input,",")
input_tmp_vecstring <-unlist(input_tmp)


input_vecstring = sub("^([^.]*).*", "\\1", input_tmp_vecstring) 

if (dataset == input) {
	segcall=segFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, savePlot=outputfigures, method=method)
	
} else {
	segcall=segFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, listOfFiles=input_vecstring, savePlot=outputfigures, method=method)
	
}
sink(output)
print(format(segcall))
sink()
#write.table(segcall,output,row.names = FALSE, quote=FALSE, sep = "\t")

quit()
