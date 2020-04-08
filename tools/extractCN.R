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
		make_option("--settings_type",type="character",default=NULL, dest="settings_type"),
		make_option("--settings_tumor",type="character",default=NULL, dest="settings_tumor"),
		make_option("--symmetrize",type="character",default=NULL, dest="symmetrize"),
		make_option("--settings_signal",type="character",default=NULL, dest="settings_signal"),
		make_option("--settings_snp",type="character",default=NULL, dest="settings_snp"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log"),
		make_option("--userid",type="character",default=NULL, dest="userid")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if(is.null(opt$input)){
	print_help(opt_parser)
	stop("input required.", call.=FALSE)
}

#loading libraries

chrom=opt$chrom
input=opt$input
tmp_dir=opt$new_file_path
output=opt$output
settingsType=opt$settings_type
tumorcsv=opt$settings_tumor
symmetrize=opt$symmetrize
signal=opt$settings_signal
snp=type.convert(opt$settings_snp)
outputlog=opt$outputlog
log=opt$log
user=opt$userid

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics",user)
setwd(workdir)

inputDataset=read.table(file=input,stringsAsFactors=FALSE)
dataset=inputDataset[1,2]

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 


if (grepl("all",tolower(chrom)) | chrom=="None") {
		chrom_vec=c(1:25)
	} else {
		chrom_tmp <- strsplit(chrom,",")
		chrom_vecstring <-unlist(chrom_tmp)
		chrom_vec <- as.numeric(chrom_vecstring)
	}
if (signal == "CN")
{
	if (settingsType == "dataset") {
		if (tumorcsv== "None")
		{  		
			CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, onlySNP=snp)
					
	  	} else {
	  		CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, onlySNP=snp)
	  	}
	} else {
		input_tmp <- strsplit(settingsType,",")
		input_tmp_vecstring <-unlist(input_tmp)
		input_vecstring = sub("^([^.]*).*", "\\1", input_tmp_vecstring) 
	  	if (tumorcsv== "None") 
	  	{
	  		CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, listOfFiles=input_vecstring, onlySNP=snp)
	  	} else {
	  		CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, listOfFiles=input_vecstring, onlySNP=snp )
	  	}
	}
	
	list_chr=names(CN)
	CN_global=data.frame(check.names = FALSE)
	for (i in list_chr) {
	  chr_data=data.frame(CN[[i]],check.names = FALSE)
	  CN_global=rbind(CN_global,chr_data)
	}
	names(CN_global)[names(CN_global)=="featureNames"] <- "probeName"
	write.table(format(CN_global), output, row.names = FALSE, quote = FALSE, sep = "\t")
	
} else {
	if (symmetrize=="TRUE")	{
		if (settingsType == "dataset") {
			input_vecstring = getListOfFiles(dataset)
		} else {
			input_tmp <- strsplit(settingsType,",")
			input_tmp_vecstring <-unlist(input_tmp)
			input_vecstring = sub("^([^.]*).*", "\\1", input_tmp_vecstring) 
		}
		
		symFracB_global=data.frame(check.names = FALSE)
		
		for (currentFile in input_vecstring) {
			cat(paste0("extracting signal from ",currentFile,".\n"))
			currentSymFracB=data.frame()
			symFracB=getSymFracBSignal(dataset,chromosome=chrom_vec,file=currentFile,normalTumorArray=tumorcsv)
			list_chr=names(symFracB)
			for (i in list_chr) {
				cat(paste0("   extracting ",i,".\n"))
				chr_data=data.frame(symFracB[[i]]$tumor,check.names = FALSE)
				currentSymFracB=rbind(currentSymFracB,chr_data)
				
			}
			if (is.null(symFracB_global) || nrow(symFracB_global)==0) {
				symFracB_global=currentSymFracB
			} else {
				symFracB_global=cbind(symFracB_global,currentFile=currentSymFracB[[3]])
			}
		}
		names(symFracB_global)[names(symFracB_global)=="featureNames"] <- "probeName"
		
		write.table(format(symFracB_global), output, row.names = FALSE, quote = FALSE, sep = "\t")
	} else {
		if (settingsType == "dataset") {
			if (tumorcsv== "None")
			{  		
				fracB=getFracBSignal(dataset,chromosome=chrom_vec)
				
			} else {
				fracB=getFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv)
			}
		} else {
			input_tmp <- strsplit(settingsType,",")
			input_tmp_vecstring <-unlist(input_tmp)
			input_vecstring = sub("^([^.]*).*", "\\1", input_tmp_vecstring) 
			if (tumorcsv== "None") 
			{
				fracB=getFracBSignal(dataset,chromosome=chrom_vec, listOfFiles=input_vecstring)
			} else {
				fracB=getFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, listOfFiles=input_vecstring)
			}
		}
		#formatage des données
		list_chr=names(fracB)
		fracB_global=data.frame(check.names = FALSE)
		for (i in list_chr) {
			chr_data=data.frame(fracB[[i]]$tumor,check.names = FALSE)
			fracB_global=rbind(fracB_global,chr_data)
		}
		names(fracB_global)[names(fracB_global)=="featureNames"] <- "probeName"
		write.table(format(fracB_global), output, row.names = FALSE, quote = FALSE, sep = "\t")
	}
	
}

if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 