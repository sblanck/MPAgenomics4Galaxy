args<-commandArgs(TRUE)

chrom=args[1]
dataset=args[2]
output=args[3]
tmp_dir=args[4]
nbcall=as.numeric(args[5])
input=args[6]
outputfigures=type.convert(args[7])
snp=type.convert(args[8])
tumorcsv=args[9]
cellularity=as.numeric(args[10])
user=args[11]
method=args[12]

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
	if (tumorcsv== "none")
	{
  		segcall=cnSegCallingProcess(dataset,chromosome=chrom_vec, nclass=nbcall, savePlot=outputfigures,onlySNP=snp, cellularity=cellularity, method=method)
  	} else {
  		segcall=cnSegCallingProcess(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, nclass=nbcall, savePlot=outputfigures,onlySNP=snp, cellularity=cellularity, method=method)
  	}
} else {
  	if (tumorcsv== "none") 
  	{
  		segcall=cnSegCallingProcess(dataset,chromosome=chrom_vec, listOfFiles=input_vecstring, nclass=nbcall, savePlot=outputfigures, onlySNP=snp, cellularity=cellularity, method=method)
  	} else {
  		segcall=cnSegCallingProcess(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, listOfFiles=input_vecstring, nclass=nbcall, savePlot=outputfigures, onlySNP=snp, cellularity=cellularity, method=method)
  	}
}

sink(output)
print(format(segcall))
sink()
#write.table(format(segcall),output,row.names = FALSE, quote=FALSE, sep = "\t")
#write.fwf(segcall,output,rownames = FALSE, quote=FALSE, sep = "\t")
quit()
