args<-commandArgs(TRUE)

chrom=args[1]
dataset=args[2]
output=args[3]
tmp_dir=args[4]
input=args[5]
tumorcsv=args[6]
signal=args[7]
snp=type.convert(args[8])
user=args[9]
symmetrize=args[10]

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
if (signal == "CN")
{
	if (input == "dataset") {
		if (tumorcsv== "None")
		{  		
			CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, onlySNP=snp)
					
	  	} else {
	  		CN=getCopyNumberSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv, onlySNP=snp)
	  	}
	} else {
		input_tmp <- strsplit(input,",")
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
		if (input == "dataset") {
			input_vecstring = getListOfFiles(dataset)
		} else {
			input_tmp <- strsplit(input,",")
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
		if (input == "dataset") {
			if (tumorcsv== "None")
			{  		
				fracB=getFracBSignal(dataset,chromosome=chrom_vec)
				
			} else {
				fracB=getFracBSignal(dataset,chromosome=chrom_vec, normalTumorArray=tumorcsv)
			}
		} else {
			input_tmp <- strsplit(input,",")
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