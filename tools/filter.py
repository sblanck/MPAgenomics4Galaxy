import os
import sys
import subprocess

def main():

    tmp_dir=sys.argv[4]
    outputlog=sys.argv[7]
    log=sys.argv[8]
    script_dir=os.path.dirname(os.path.abspath(__file__))
    
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    
    retcode=(subprocess.call(["Rscript", os.path.join(script_dir,"filter.R"), sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]], stdout = errfile, stderr = errfile))
    errfile.close();
    sys.exit(retcode)
    
if __name__ == "__main__":
    main()