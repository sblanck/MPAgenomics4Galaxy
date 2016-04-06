args<-commandArgs(TRUE)

chip=args[1]
dataset=args[2]
workdir=args[3]
celPath=args[4]
chipPath=args[4]
tumor=args[5]
settingType=args[6]
outputgraph=type.convert(args[7])
tag=args[8]

if (tag=="")
{
	tag=NULL
}

library(MPAgenomics)
setwd(workdir)
if (settingType=="standard")
{
	signalPreProcess(dataSetName=dataset, chipType=chip, dataSetPath=celPath,chipFilesPath=chipPath, path=workdir,createArchitecture=TRUE, savePlot=outputgraph, tags=tag)
} else {
	signalPreProcess(dataSetName=dataset, chipType=chip, dataSetPath=celPath,chipFilesPath=chipPath, normalTumorArray=tumor, path=workdir,createArchitecture=TRUE, savePlot=outputgraph, tags=tag)
}