args<-commandArgs(TRUE)

input=args[1]
dataResponse=args[2]
chrom=args[3]
tmp_dir=args[4]
signal=args[5]
snp=type.convert(args[6])
settingsType=args[7]
tumor=args[8]
fold=as.integer(args[9])
loss=args[10]
plot=type.convert(args[11])
output=args[12]
user=args[13]
package=args[14]


library(MPAgenomics)
library(glmnet)
library(spikeslab)
library(lars)
workdir=file.path(tmp_dir, "mpagenomics",user)
setwd(workdir)

if (grepl("all",tolower(chrom)) | chrom=="None") {
		chrom_vec=c(1:25)
	} else {
		chrom_tmp <- strsplit(chrom,",")
		chrom_vecstring <-unlist(chrom_tmp)
		chrom_vec <- as.numeric(chrom_vecstring)
	}

	
if (settingsType == "tumor") {
	if (signal=="CN") {
			res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, normalTumorArray=tumor, onlySNP=snp, loss=loss, plot=plot, nbFolds=fold, pkg=package)
		} else {
			res=markerSelection(input,dataResponse, chromosome=chrom_vec,signal=signal,normalTumorArray=tumor, loss=loss, plot=plot, nbFolds=fold,pkg=package)	
		} 
} else {
	if (signal=="CN") {
		res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, onlySNP=snp, loss=loss, plot=plot, nbFolds=fold,pkg=package)
		} else {
  		res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, loss=loss, plot=plot, nbFolds=fold,pkg=package)
		}
}

res

df=data.frame()
list_chr=names(res)
markerSelected=FALSE

for (i in list_chr) {
  chr_data=res[[i]]
  len=length(chr_data$markers.index)
  if (len != 0)
  {
	markerSelected=TRUE
	chrdf=data.frame(rep(i,len),chr_data$markers.position,chr_data$markers.index,chr_data$markers.names,chr_data$coefficient)
  	df=rbind(df,chrdf)
  }
}

if (markerSelected) {
	colnames(df) <- c("chr","position","index","names","coefficient")
	sink(output)
	print(format(df),row.names=FALSE)
	sink()
	#write.table(df,output,row.names = FALSE, quote = FALSE, sep = "\t")
} else 
	writeLines("no SNP selected", output)


