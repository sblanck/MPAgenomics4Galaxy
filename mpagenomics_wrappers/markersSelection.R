args<-commandArgs(TRUE)

input=args[1]
response=args[2]
tmp_dir=args[3]
nbFolds=as.numeric(args[4])
loss=args[5]
output=args[6]

library(MPAgenomics)
workdir=file.path(tmp_dir, "mpagenomics")
setwd(workdir)

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

sink(output)
print(format(CNsignalResult),row.names=FALSE)
sink()
#write.table(CNsignalResult,output,row.names = FALSE, quote=FALSE, sep = "\t")
