import os
import sys
import subprocess
import shutil

def main():

    input_file=sys.argv[1]
    tmp_dir=sys.argv[4]
    script_dir=os.path.dirname(os.path.abspath(__file__))
    plot=sys.argv[11]
    pdffigures=sys.argv[13]
    outputlog=sys.argv[14]
    log=sys.argv[15]
    user=sys.argv[16]
    package=sys.argv[17]
        
    iFile=open(input_file,'r')
    dataSetLine=iFile.readline()
    dataset=dataSetLine.split("\t")[1]
    iFile.close()    
        
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"selection.R"), dataset, sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8], sys.argv[9], sys.argv[10], sys.argv[11], sys.argv[12],sys.argv[16],package], stdout = errfile, stderr = errfile)
    
    if (plot=="TRUE"):
        shutil.copy(os.path.join(tmp_dir,"mpagenomics",user,"Rplots.pdf"), pdffigures)
    
    errfile.close()
       
    sys.exit(retcode)

if __name__ == "__main__":
    main()
