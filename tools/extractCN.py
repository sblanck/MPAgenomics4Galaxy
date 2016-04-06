import os
import sys
import subprocess
import getopt

def main(argv):
    
    symmetrize="False"
    
    try:
        opts, args = getopt.getopt(argv,"hc:i:o:f:s:y:t:p:l:g:n:u:",["chrom=","input=","output=","new_file_path=","settings_type=","settings_tumor=","symmetrize=","outputlog=","log=","settings_signal=","settings_snp=","userid="])
    except getopt.GetoptError as err:
        print str(err)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'extractCN.py'
            sys.exit()
        elif opt in ("-c", "--chrom"):
            chromosome = arg
        elif opt in ("-i", "--input"):
            input_file = arg
        elif opt in ("-o", "--output"):
            output_file = arg
        elif opt in ("-f", "--new_file_path"):
            tmp_dir = arg
        elif opt in ("-s", "--settings_type"):
            input_type = arg
        elif opt in ("-t", "--settings_tumor"):
            settings_tumor = arg
        elif opt in ("-y", "--symmetrize"):
            symmetrize = arg
        elif opt in ("-p", "--outputlog"):
            outputlog = arg
        elif opt in ("-l", "--log"):
            log = arg
        elif opt in ("-g", "--settings_signal"):
            signal = arg
        elif opt in ("-n", "--settings_snp"):
            snp = arg
        elif opt in ("-u", "--userid"):
            user_id = arg
        
            
      
    #===========================================================================
    #chromosome=sys.argv[1]
    #input_file=sys.argv[2]
    # output_file=sys.argv[3]
    # tmp_dir=sys.argv[4]
    # input_type=sys.argv[5]
    # settings_tumor=sys.argv[6]
    # outputlog=sys.argv[7]
    # log=sys.argv[8]
    # signal=sys.argv[9]
    # snp=sys.argv[10]
    # user_id=sys.argv[11]
    #===========================================================================
    script_dir=os.path.dirname(os.path.abspath(__file__))
    
    iFile=open(input_file,'r')
    dataSetLine=iFile.readline()
    dataset=dataSetLine.split("\t")[1]
    iFile.close()
    
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"extractCN.R"), chromosome, dataset, output_file, tmp_dir, input_type, settings_tumor, signal,snp,user_id, symmetrize], stdout = errfile, stderr = errfile)
    
    errfile.close()
     
    sys.exit(retcode)

if __name__ == "__main__":
    main(main(sys.argv[1:]))
