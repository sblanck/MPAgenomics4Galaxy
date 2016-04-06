import os
import sys
import subprocess
import shutil
import getopt


def main(argv):

    #default values 
    cellularity="1"
    nbcall="3"

    try:
        opts, args = getopt.getopt(argv,"h:i:f:p:o:l:og:g:m:st:u:",["input=","new_file_path=","outputlog=","output=","log=","outputgraph=", "graph=", "method=", "signalType=", "user_id=", "nbcall=", "cellularity="])
    except getopt.GetoptError as err:
        print str(err)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'segmentation.py'
            sys.exit()
        elif opt in ("-i", "--input"):
            inputdata = arg
        elif opt in ("-f", "--new_file_path"):
            tmp_dir = arg
        elif opt in ("-p", "--outputlog"):
            outputlog = arg
        elif opt in ("-o", "--output"):
            output = arg
        elif opt in ("-l", "--log"):
            log = arg
        elif opt in ("-og", "--outputgraph"):
            plot = arg
        elif opt in ("-g", "--graph"):
            pdffigures = arg
        elif opt in ("-m", "--method"):
            method = arg
        elif opt in ("-st", "--signalType"):
            signalType = arg
        elif opt in ("-u", "--user_id"):
            userId = arg
        elif opt in ("-c", "--nbcall"):
            nbcall = arg
        elif opt in ("-e", "--cellularity"):
            cellularity = arg

    #===========================================================================
    # inputdata=sys.argv[1]
    # tmp_dir=sys.argv[2]
    # nbcall=sys.argv[3]
    # cellularity=sys.argv[4]
    # outputlog=sys.argv[5] 
    # output=sys.argv[6]
    # log=sys.argv[7]
    # plot=sys.argv[8]
    # pdffigures=sys.argv[9]
    # method=sys.argv[10]
    #===========================================================================
    
    script_dir=os.path.dirname(os.path.abspath(__file__))
        
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"segmentation.R"), inputdata, tmp_dir, nbcall, cellularity, output, method, userId, signalType], stdout = errfile, stderr = errfile)
    
    if (plot=="TRUE"):
        shutil.copy(os.path.join(tmp_dir,"mpagenomics",userId,"Rplots.pdf"), pdffigures)
    
    errfile.close()
       
    sys.exit(retcode)

if __name__ == "__main__":
    main(main(sys.argv[1:]))