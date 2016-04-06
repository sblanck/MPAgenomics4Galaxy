import os
import sys
import subprocess
import zipfile


def main():

    input_file=sys.argv[2]
    tmp_dir=sys.argv[4]
    settingsType=sys.argv[6]
    zip_file=sys.argv[9]
    tumorcsv=sys.argv[10]
    cellularity=sys.argv[11]
    outputlog=sys.argv[12]
    log=sys.argv[13]
    user=sys.argv[14]
    method=sys.argv[15]
    script_dir=os.path.dirname(os.path.abspath(__file__))
    
    iFile=open(input_file,'r')
    dataSetLine=iFile.readline()
    dataset=dataSetLine.split("\t")[1]
    iFile.close()
   

    if settingsType=="dataset":
        settingsType=dataset

    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    fig_dir=os.path.join("mpagenomics",user,"figures",dataset,"segmentation/CN")

    abs_fig_dir=os.path.join(tmp_dir,fig_dir)
    if (os.path.isdir(abs_fig_dir)) and (sys.argv[7]=="TRUE"):
        old_files=os.listdir(abs_fig_dir)
        for ifile in old_files:
            os.remove(os.path.join(abs_fig_dir,ifile))
           
        
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"segcall.R"),  sys.argv[1], dataset, sys.argv[3], sys.argv[4], sys.argv[5], settingsType, sys.argv[7], sys.argv[8], tumorcsv, cellularity, user, method], stdout = errfile, stderr = errfile)
    
    errfile.close()
     
    if (retcode == 0):
        if (os.path.isdir(abs_fig_dir)) and (sys.argv[7]=="TRUE"):
        
            new_files=os.listdir(abs_fig_dir)
            zipbuf = zipfile.ZipFile(os.path.join(abs_fig_dir,zip_file), 'w', zipfile.ZIP_DEFLATED)
            for current_file in new_files:
                fn = os.path.join(abs_fig_dir,current_file)
                relfn=fn[len(abs_fig_dir)+len(os.sep):]
                zipbuf.write(fn,relfn)
        sys.exit(retcode)
    else:
        sys.exit(retcode)

if __name__ == "__main__":
    main()
