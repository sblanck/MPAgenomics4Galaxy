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
		make_option("--outputgraph",type="character",default=NULL, dest="outputgraph"),
		make_option("--graph",type="character",default=NULL, dest="graph"),
		make_option("--signalType",type="character",default=NULL, dest="signalType"),
		make_option("--cellularity",type="character",default=NULL, dest="cellularity"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log"),
		make_option("--user_id",type="character",default=NULL, dest="userid"),
		make_option("--method",type="character",default=NULL, dest="method")
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
nbcall=as.numeric(opt$nbcall)
outputgraph=type.convert(opt$outputgraph)
cellularity=as.numeric(opt$cellularity)
userId=opt$userid
method=opt$method
log=opt$log
outputlog=opt$outputlog
graph=opt$graph
signalType=opt$signalType

#args<-commandArgs(TRUE)
#
#input=args[1]
#tmp_dir=args[2]
#nbcall=as.numeric(args[3])
#cellularity=as.numeric(args[4]) 
#output=args[5]
#method=args[6]
#userId=args[7]
#signalType=args[8]

library(MPAgenomics)
workdir=file.path(tmp_dir,"mpagenomics",userId)
setwd(workdir)

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 

CN=read.table(input,header=TRUE)
uniqueChr=unique(CN$chromosome)
drops=c("chromosome","position","probeName")
CNsignal=CN[,!(names(CN)%in% drops),drop=FALSE]

samples=names(CNsignal)

if (signalType=="CN")
{

result=data.frame(sampleNames=character(0),chrom=character(0),chromStart=numeric(0),chromEnd=numeric(0),probes=numeric(0),means=numeric(0),calls=character(0),stringsAsFactors=FALSE)

for (chr in uniqueChr)
{
currentSubset=subset(CN, chromosome==chr)
currentPositions=currentSubset["position"]
for (sample in samples) 
  {
    currentSignal=currentSubset[sample]
	if (length(which(!is.na(unlist(currentSignal))))>1)
	{
		currentSeg=segmentation(signal=unlist(currentSignal),position=unlist(currentPositions),method=method)
    	callobj= callingObject(copynumber=currentSeg$signal, segmented=currentSeg$segmented,chromosome=rep(chr,length(currentSeg$signal)), position=currentSeg$startPos,sampleNames=sample)
	    currentCall=callingProcess(callobj,nclass=nbcall,cellularity=cellularity,verbose=TRUE)
	    currentResult=currentCall$segment
	    currentResult["sampleNames"]=c(rep(sample,length(currentCall$segment$chrom)))
	    result=rbind(result,currentResult)
	}
  }
}
finalResult=data.frame(sampleNames=result["sampleNames"],chrom=result["chrom"],chromStart=result["chromStart"],chromEnd=result["chromEnd"],probes=result["probes"],means=result["means"],calls=result["calls"],stringsAsFactors=FALSE)

write.table(finalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
} else {
	result=data.frame(sampleNames=character(0),chrom=character(0),start=numeric(0),end=numeric(0),points=numeric(0),means=numeric(0),stringsAsFactors=FALSE)
	
	for (chr in uniqueChr)
	{
		cat(paste0("chromosome ",chr,"\n"))
		currentSubset=subset(CN, chromosome==chr)
		currentPositions=currentSubset["position"]
		for (sample in samples) 
		{
			cat(paste0("  sample ",sample,"..."))
			currentSignal=currentSubset[sample]
			if (length(which(!is.na(unlist(currentSignal))))>1)
			{
				currentSeg=segmentation(signal=unlist(currentSignal),position=unlist(currentPositions),method=method)
				currentResult=currentSeg$segment
				currentResult["chrom"]=c(rep(chr,length(currentSeg$segment$means)))
				currentResult["sampleNames"]=c(rep(sample,length(currentSeg$segment$means)))
				result=rbind(result,currentResult)
				
			}
			cat(paste0("OK\n"))
		}
	}
	finalResult=data.frame(sampleNames=result["sampleNames"],chrom=result["chrom"],chromStart=result["start"],chromEnd=result["end"],probes=result["points"],means=result["means"],stringsAsFactors=FALSE)
	write.table(finalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
}

if (outputgraph){
	file.rename(file.path(tmp_dir,"mpagenomics",userId,"Rplots.pdf"), graph)
}

if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 
