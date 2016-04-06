args<-commandArgs(TRUE)

input=args[1]
tmp_dir=args[2]
nbcall=as.numeric(args[3])
cellularity=as.numeric(args[4]) 
output=args[5]
method=args[6]
userId=args[7]
signalType=args[8]

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics",userId)
setwd(workdir)

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
sink(output)
print(format(finalResult))
sink()
#write.table(finalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
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
	sink(output)
	print(format(finalResult))
	sink()
	#write.table(finalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
}
	
