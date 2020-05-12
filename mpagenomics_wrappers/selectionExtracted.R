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
		make_option("--response",type="character",default=NULL, dest="response"),
		make_option("--loss",type="character",default=NULL, dest="loss"),
		make_option("--folds",type="character",default=NULL, dest="folds"),
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
response=opt$response
output=opt$output
tmp_dir=opt$new_file_path
nbFolds=as.numeric(opt$folds)
loss=opt$loss
log=opt$log
outputlog=opt$outputlog


#args<-commandArgs(TRUE)
#
#input=args[1]
#response=args[2]
#tmp_dir=args[3]
#nbFolds=as.numeric(args[4])
#loss=args[5]
#output=args[6]

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics")
setwd(workdir)

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 

CN=read.table(input,header=TRUE,check.names=FALSE)
drops=c("chromosome","position","probeName")
CNsignal=CN[,!(names(CN)%in% drops)]
samples=names(CNsignal)
CNsignalMatrix=t(data.matrix(CNsignal))
resp=read.table(response,header=TRUE,sep=",")
listOfFile=resp[[1]]
responseValue=resp[[2]]
index = match(listOfFile,rownames(CNsignalMatrix))
responseValueOrder=responseValue[index]

result=variableSelection(CNsignalMatrix,responseValueOrder,nbFolds=nbFolds,loss=loss,plot=TRUE)

CNsignalResult=CN[result$markers.index,(names(CN)%in% drops)]

CNsignalResult["coefficient"]=result$coefficient
CNsignalResult["index"]=result$markers.index

if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 

#sink(output)
#print(format(CNsignalResult),row.names=FALSE)
#sink()
write.table(CNsignalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
