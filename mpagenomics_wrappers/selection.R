#!/usr/bin/env Rscript
# setup R error handling to go to stderr
options( show.error.messages=F, error = function () { cat( geterrmessage(), file=stderr() ); q( "no", 1, F ) } )

# we need that to not crash galaxy with an UTF8 error on German LC settings.
loc <- Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")

library("optparse")

##### Read options
option_list=list(
		make_option("--chrom",type="character",default=NULL, dest="chrom"),
		make_option("--input",type="character",default=NULL, dest="input"),
		make_option("--output",type="character",default=NULL, dest="output"),
		make_option("--new_file_path",type="character",default=NULL, dest="new_file_path"),
		make_option("--response",type="character",default=NULL, dest="response"),
		make_option("--settingsType",type="character",default=NULL, dest="settingsType"),
		make_option("--outputgraph",type="character",default=NULL, dest="outputgraph"),
		make_option("--settingsSnp",type="character",default=NULL, dest="settingsSnp"),
		make_option("--settingsSignal",type="character",default=NULL, dest="settingsSignal"),
		make_option("--settingsLoss",type="character",default=NULL, dest="settingsLoss"),
		make_option("--pdffigures",type="character",default=NULL, dest="pdffigures"),
		make_option("--folds",type="character",default=NULL, dest="folds"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log"),
		make_option("--userId",type="character",default=NULL, dest="userid"),
		make_option("--settingsPackage",type="character",default=NULL, dest="settingsPackage")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if(is.null(opt$input)){
	print_help(opt_parser)
	stop("input required.", call.=FALSE)
}

#loading libraries


chrom=opt$chrom
dataset=opt$input
dataResponse=opt$response
output=opt$output
tmp_dir=opt$new_file_path
signal=opt$settingsSignal
settingsType=opt$settingsType
outputfigures=type.convert(opt$outputgraph)
snp=type.convert(opt$settingsSnp)
user=opt$userid
folds=as.numeric(opt$folds)
loss=opt$settingsLoss
log=opt$log
outputlog=opt$outputlog
outputgraph=opt$outputgraph
pdffigures=opt$pdffigures
package=opt$settingsPackage


library(MPAgenomics)
library(glmnet)
library(spikeslab)
library(lars)

inputDataset=read.table(file=dataset,stringsAsFactors=FALSE)
input=inputDataset[1,2]
workdir=file.path(tmp_dir, "mpagenomics",user)
print(workdir)
setwd(workdir)

if (grepl("all",tolower(chrom)) | chrom=="None") {
		chrom_vec=c(1:25)
	} else {
		chrom_tmp <- strsplit(chrom,",")
		chrom_vecstring <-unlist(chrom_tmp)
		chrom_vec <- as.numeric(chrom_vecstring)
	}

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 

if (settingsType == "tumor") {
	if (signal=="CN") {
			res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, normalTumorArray=tumor, onlySNP=snp, loss=loss, plot=outputfigures, nbFolds=folds, pkg=package)
		} else {
			res=markerSelection(input,dataResponse, chromosome=chrom_vec,signal=signal,normalTumorArray=tumor, loss=loss, plot=outputfigures, nbFolds=folds,pkg=package)	
		} 
} else {
	if (signal=="CN") {
		res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, onlySNP=snp, loss=loss, plot=outputfigures, nbFolds=folds,pkg=package)
		} else {
  		res=markerSelection(input,dataResponse, chromosome=chrom_vec, signal=signal, loss=loss, plot=outputfigures, nbFolds=folds,pkg=package)
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

if (outputgraph){
	file.rename(file.path(tmp_dir,"mpagenomics",user,"Rplots.pdf"), pdffigures)
}

if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 

if (markerSelected) {
	colnames(df) <- c("chr","position","index","names","coefficient")
	#sink(output)
	#print(format(df),row.names=FALSE)
	#sink()
	write.table(df,output,row.names = FALSE, quote = FALSE, sep = "\t")
} else 
	writeLines("no SNP selected", output)


