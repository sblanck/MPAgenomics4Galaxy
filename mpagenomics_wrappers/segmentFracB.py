import os
import sys
import subprocess
import zipfile
import getopt


def main(argv):
       
    try:
        opts, args = getopt.getopt(argv,"hc:i:o:f:s:og:fig:t:p:l:u:m:",["chrom=","input=","output=","new_file_path=","settings_type=","output_graph=","zip_figures=","settings_tumor=","outputlog=","log=","userid=","method="])
    except getopt.GetoptError as err:
        print str(err)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'extractCNopts.py'
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
        elif opt in ("-og", "--output_graph"):
            output_graph = arg
        elif opt in ("-fig", "--zip_figures"):
            zip_file = arg
        elif opt in ("-t", "--settings_tumor"):
            tumorcsv = arg
        elif opt in ("-p", "--outputlog"):
            outputlog = arg
        elif opt in ("-l", "--log"):
            log = arg
        elif opt in ("-u", "--userid"):
            user_id = arg
        elif opt in ("-m", "--method"):
            method = arg
  
    script_dir=os.path.dirname(os.path.abspath(__file__))
    
    iFile=open(input_file,'r')
    dataSetLine=iFile.readline()
    dataset=dataSetLine.split("\t")[1]
    iFile.close()
      

    if input_type=="dataset":
        input_type=dataset

    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    fig_dir=os.path.join("mpagenomics",user_id,"figures",dataset,"segmentation/fracB")

    abs_fig_dir=os.path.join(tmp_dir,fig_dir)
    if (os.path.isdir(abs_fig_dir)) and (output_graph=="TRUE"):
        old_files=os.listdir(abs_fig_dir)
        for ifile in old_files:
            os.remove(os.path.join(abs_fig_dir,ifile))
           
        
    retcode=subprocess.call(["Rscript", os.path.join(script_dir,"segmentFracB.R"),  chromosome, dataset, output_file, tmp_dir, input_type, output_graph, tumorcsv, user_id, method], stdout = errfile, stderr = errfile)
    
    errfile.close()
     
    if (retcode == 0):
        if (os.path.isdir(abs_fig_dir)) and (output_graph=="TRUE"):
        
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
    main(main(sys.argv[1:]))
