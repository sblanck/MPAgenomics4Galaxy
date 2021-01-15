#!/usr/bin/env Rscript
# setup R error handling to go to stderr
options( show.error.messages=F, error = function () { cat( geterrmessage(), file=stderr() ); q( "no", 1, F ) } )

# we need that to not crash galaxy with an UTF8 error on German LC settings.
loc <- Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")

library("optparse")

##### Read options
option_list=list(
		make_option("--input",type="character",default=NULL, dest="input"),
		make_option("--output",type="character",default=NULL, dest="output"),
		make_option("--new_file_path",type="character",default=NULL, dest="new_file_path"),
		make_option("--nbcall",type="character",default=NULL, dest="nbcall"),
		make_option("--length",type="character",default=NULL, dest="length"),
		make_option("--probes",type="character",default=NULL, dest="probes"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log")
	);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if(is.null(opt$input)){
	print_help(opt_parser)
	stop("input required.", call.=FALSE)
}

#loading libraries

input=opt$input
output=opt$output
tmp_dir=opt$new_file_path
nbcall=opt$nbcall
length=as.numeric(opt$length)
probes=as.numeric(opt$probes)
log=opt$log
outputlog=opt$outputlog

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 

nbcall_tmp <- strsplit(nbcall,",")
nbcall_vecstring <-unlist(nbcall_tmp)

nbcall_vecstring

library(MPAgenomics)
workdir=file.path(tmp_dir)
if (!dir.exists(workdir))
  dir.create(workdir, showWarnings = TRUE, recursive = TRUE)
setwd(workdir)

segcall = read.table(input, header = TRUE)
filtercall=filterSeg(segcall,length,probes,nbcall_vecstring)
#sink(output)
#print(format(filtercall),row.names=FALSE)
#sink()
if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 
write.table(filtercall,output,row.names = FALSE, quote = FALSE, sep = "\t")

