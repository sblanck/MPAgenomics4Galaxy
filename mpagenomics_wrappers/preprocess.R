#!/usr/bin/env Rscript
# setup R error handling to go to stderr
options( show.error.messages=F, error = function () { cat( geterrmessage(), file=stderr() ); q( "no", 1, F ) } )

# we need that to not crash galaxy with an UTF8 error on German LC settings.
loc <- Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")

library("optparse")

##### Read options
option_list=list(
		make_option("--summary",type="character",default=NULL, dest="summary"),
		make_option("--dataSetName",type="character",default=NULL, dest="dataSetName"),
		make_option("--new_file_path",type="character",default=NULL, dest="new_file_path"),
		make_option("--inputcdffull_name",type="character",default=NULL, dest="inputcdffull_name"),
		make_option("--inputufl_name",type="character",default=NULL, dest="inputufl_name"),
		make_option("--inputugp_name",type="character",default=NULL, dest="inputugp_name"),
		make_option("--inputacs_name",type="character",default=NULL, dest="inputacs_name"),
		make_option("--inputcdffull",type="character",default=NULL, dest="inputcdffull"),
		make_option("--inputufl",type="character",default=NULL, dest="inputufl"),
		make_option("--inputugp",type="character",default=NULL, dest="inputugp"),
		make_option("--inputacs",type="character",default=NULL, dest="inputacs"),
		make_option("--tumorcsv",type="character",default=NULL, dest="tumorcsv"),
		make_option("--settingsType",type="character",default=NULL, dest="settingsType"),
		make_option("--outputgraph",type="character",default=NULL, dest="outputgraph"),
		make_option("--zipfigures",type="character",default=NULL, dest="zipfigures"),
		make_option("--zipresults",type="character",default=NULL, dest="zipresults"),
		make_option("--outputlog",type="character",default=NULL, dest="outputlog"),
		make_option("--log",type="character",default=NULL, dest="log"),
		make_option("--user_id",type="character",default=NULL, dest="user_id"),
		make_option("--input",type="character",default=NULL, dest="input")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if(is.null(opt$input)){
	print_help(opt_parser)
	stop("input required.", call.=FALSE)
}

#loading libraries

summary=opt$summary
dataSetName=opt$dataSetName
newFilePath=opt$new_file_path
inputCDFName=opt$inputcdffull_name
inputUFLName=opt$inputufl_name
inputUGPName=opt$inputugp_name
inputACSName=opt$inputacs_name
inputCDF=opt$inputcdffull
inputUFL=opt$inputufl
inputUGP=opt$inputugp
inputACS=opt$inputacs
tumorcsv=opt$tumorcsv
settingsType=opt$settingsType
outputGraph=opt$outputgraph
zipfigures=opt$zipfigures
zipresults=opt$zipresults
outputlog=opt$outputlog
log=opt$log
userId=opt$user_id

destinationPath=file.path(newFilePath, userId, dataSetName)
mpagenomicsDir = file.path(newFilePath,"mpagenomics",userId)
dataDir = file.path(newFilePath, userId)
chipDir = file.path(newFilePath,"mpagenomics",userId,"annotationData","chipTypes")
createArchitecture=TRUE

if (dir.exists(chipDir))
	system(paste0("rm -r ", chipDir))

if (!dir.exists(mpagenomicsDir))
	dir.create(mpagenomicsDir, showWarnings = TRUE, recursive = TRUE)

if (!dir.exists(dataDir))
	dir.create(dataDir, showWarnings = TRUE, recursive = TRUE)

listInput <- trimws( unlist( strsplit(trimws(opt$input), ",") ) )
if(length(listInput)<2){
	stop("To few .CEL files selected : At least 2 .CEL files are required", call.=FALSE)
}


celList=vector()
celFileNameList=vector()

for (i in 1:length(listInput))
{
	inputFileInfo <- unlist( strsplit( listInput[i], ';' ) )
	celList=c(celList,inputFileInfo[1])
	celFileNameList=c(celFileNameList,inputFileInfo[2])
}


for (i in 1:length(celFileNameList))
	{
		source = celList[i]
		destination=file.path(dataDir,celFileNameList[i])
		file.copy(source, destination)
}
split=unlist(strsplit(inputCDFName,",",fixed=TRUE))
tag=NULL
if (length(split) != 0) {
	chipType=split[1]
	tagExt=split[2]
	tag=unlist(strsplit(tagExt,".",fixed=TRUE))[1]
	} else {
	chipType=split[1]
}

if(!file.exists(file.path(dataDir,inputCDFName)))
	file.symlink(inputCDF,file.path(dataDir,inputCDFName))
if(!file.exists(file.path(dataDir,inputACSName)))
	file.symlink(inputACS,file.path(dataDir,inputACSName))
if(!file.exists(file.path(dataDir,inputUFLName)))
	file.symlink(inputUFL,file.path(dataDir,inputUFLName))
if(!file.exists(file.path(dataDir,inputUGPName)))
	file.symlink(inputUGP,file.path(dataDir,inputUGPName))

fig_dir = file.path("mpagenomics", userId, "figures", dataSetName, "signal")
abs_fig_dir = file.path(newFilePath, fig_dir)

chip=chipType
dataset=dataSetName
workdir=mpagenomicsDir
celPath=dataDir
chipPath=dataDir		
tumor=tumorcsv
outputgraph=type.convert(outputGraph)


library(MPAgenomics)
setwd(workdir)

if (outputlog){
	sinklog <- file(log, open = "wt")
	sink(sinklog ,type = "output")
	sink(sinklog, type = "message")
} 

if (settingsType=="standard")
{
	signalPreProcess(dataSetName=dataset, chipType=chip, dataSetPath=celPath,chipFilesPath=chipPath, path=workdir,createArchitecture=createArchitecture, savePlot=outputgraph, tags=tag)
} else {
	signalPreProcess(dataSetName=dataset, chipType=chip, dataSetPath=celPath,chipFilesPath=chipPath, normalTumorArray=tumor, path=workdir,createArchitecture=createArchitecture, savePlot=outputgraph, tags=tag)
}
setwd(mpagenomicsDir)
zip(zipfile = "results.zip", files = ".")
file.rename("results.zip",zipresults)
setwd(abs_fig_dir)
files2zip <- dir(abs_fig_dir)
zip(zipfile = "figures.zip", files = files2zip)
file.rename("figures.zip",zipfigures)

summarydf=data.frame(celFileNameList,rep(dataSetName,length(celFileNameList)),rep(chipType,length(celFileNameList)))
write.table(summarydf,file=summary,quote=FALSE,row.names=FALSE,col.names=FALSE,sep="\t")

if (dir.exists(mpagenomicsDir))
  system(paste0("rm -r ", mpagenomicsDir))


if (outputlog){
	sink(type="output")
	sink(type="message")
	close(sinklog)
} 

