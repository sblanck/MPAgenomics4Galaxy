import os
import sys
import subprocess

def main():

    inputdata=sys.argv[1]
    response=sys.argv[2]
    tmp_dir=sys.argv[3]
    nbfold=sys.argv[4]
    loss=sys.argv[5]
    outputlog=sys.argv[6] 
    output=sys.argv[7]
    log=sys.argv[8]
    
    script_dir=os.path.dirname(os.path.abspath(__file__))
        
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
 
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"markersSelection.R"), inputdata, response, tmp_dir, nbfold, loss, output], stdout = errfile, stderr = errfile)
    
#  if (plot=="TRUE"):
#      shutil.copy(os.path.join(tmp_dir,"mpagenomics","Rplots.pdf"), pdffigures)
    
    errfile.close()
       
    sys.exit(retcode)

if __name__ == "__main__":
    main()