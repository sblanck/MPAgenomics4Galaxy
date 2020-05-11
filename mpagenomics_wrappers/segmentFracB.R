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
		make_option("--settings_type",type="character",default=NULL, dest="settingsType"),
		make_option("--output_graph",type="character",default=NULL, dest="outputgraph"),
		make_option("--zip_figures",type="character",default=NULL, dest="zipfigures"),
		make_option("--settings_tumor",type="character",default=NULL, dest="settingsTypeTumor"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log"),
		make_option("--userid",type="character",default=NULL, dest="userid"),
		make_option("--method",type="character",default=NULL, dest="method")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if(is.null(opt$input)){
	print_help(opt_parser)
	stop("input required.", call.=FALSE)
}

#loading libraries

args<-commandArgs(TRUE)

chrom=opt$chrom
datasetFile=opt$input
output=opt$output
tmp_dir=opt$new_file_path
input=opt$settingsType
outputfigures=type.convert(opt$outputgraph)
tumorcsv=opt$settingsTypeTumor
user=opt$userid
method=opt$method
log=opt$log
outputlog=opt$outputlog
outputgraph=opt$outputgraph
zipfigures=opt$zipfigures

#chrom=opt$chrom
#datasetFile=opt$input
#output=opt$output
#tmp_dir=opt$new_file_path
#nbcall=as.numeric(opt$nbcall)
#settingsType=opt$settingsType
#outputfigures=type.convert(opt$outputgraph)
#snp=type.convert(opt$snp)
#tumorcsv=opt$settingsTypeTumor
#cellularity=as.numeric(opt$cellularity)
#user=opt$userid
#method=opt$method
#log=opt$log
#outputlog=opt$outputlog
#outputgraph=opt$outputgraph
#zipfigures=opt$zipfigures

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


if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 


inputDataset=read.table(file=datasetFile,stringsAsFactors=FALSE)
dataset=inputDataset[1,2]



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

fig_dir = file.path("mpagenomics", user, "figures", dataset, "segmentation","fracB")
abs_fig_dir = file.path(tmp_dir, fig_dir)

if (outputgraph) {
	if (dir.exists(abs_fig_dir)) {
		system(paste0("rm -r ", abs_fig_dir))
	}
}

if (input == 'dataset') {
	segcall=segFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, savePlot=outputfigures, method=method)
	
} else {
	input_tmp <- strsplit(input,",")
	input_tmp_vecstring <-unlist(input_tmp)
	input_vecstring = sub("^([^.]*).*", "\\1", input_tmp_vecstring) 
	segcall=segFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, listOfFiles=input_vecstring, savePlot=outputfigures, method=method)
	
}
write.table(segcall,output,row.names = FALSE, quote=FALSE, sep = "\t")

if (outputgraph) {	
	setwd(abs_fig_dir)
	files2zip <- dir(abs_fig_dir)
	zip(zipfile = "figures.zip", files = files2zip)
	file.rename("figures.zip",zipfigures)
}

if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 

#sink(output)
#print(format(segcall))
#sink()


