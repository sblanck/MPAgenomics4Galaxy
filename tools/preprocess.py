import os
import re
import shutil
import sys
import subprocess
import zipfile


def main():
    extra_files_directory = sys.argv[1]
    report = sys.argv[4]
    new_files_directory = sys.argv[6]
    dataset=sys.argv[7]
    cdffull_name=sys.argv[9]
    ufl_name=sys.argv[10]
    ugp_name=sys.argv[11]
    acs_name=sys.argv[12]
    cdffull=sys.argv[14]
    ufl=sys.argv[15]
    ugp=sys.argv[16]
    acs=sys.argv[17]
    tumor=sys.argv[18]
    settingType=sys.argv[19]
    outputgraph=sys.argv[20]
    zipfigures=sys.argv[21]
    outputlog=sys.argv[22]
    log=sys.argv[23]
    user=sys.argv[24]
          

    extra_file_names = sorted(os.listdir(extra_files_directory))
        
    if (cdffull_name.count(",") != 0):    
        chipType=cdffull_name.split(",",1)[0]
        tagExt=cdffull_name.split(",",1)[1]
        tag=tagExt.split(".",1)[0]
    else:
        chipType=cdffull_name.split(".",1)[0]
        tag=""
                
    data_dir = os.path.join(new_files_directory, user, dataset)
    mpagenomics_dir = os.path.join(new_files_directory, "mpagenomics",user)
        
    try:
        os.makedirs(data_dir)
    except:
        shutil.rmtree(data_dir)
        os.makedirs(data_dir)
    
    if (not os.path.isdir(mpagenomics_dir)):
        os.makedirs(mpagenomics_dir)
            
    for name in extra_file_names:
        source = os.path.join(extra_files_directory, name)
        # Strip _task_XXX from end of name
        name_match = re.match(r"^\d+_task_(.*).dat$", name)
        if name_match:
            name = name_match.group(1)
        else:
            # Skip indices, composite extra_files_paths, etc...
            continue
        #escaped_name = name.replace("_", "-")
        #dataset_name = "%s" % (name, 'visible', ext, db_key)
        destination = os.path.join(data_dir, name)
        _copy(source, destination)
#       datasets_created.append(name)
    
    _copy(cdffull,os.path.join(data_dir, cdffull_name))
    _copy(ugp,os.path.join(data_dir, ugp_name))
    _copy(ufl,os.path.join(data_dir, ufl_name))
    _copy(acs,os.path.join(data_dir, acs_name))
    
   
    fig_dir = os.path.join("mpagenomics", user, "figures", dataset, "signal")
    abs_fig_dir = os.path.join(new_files_directory, fig_dir)
       
    
    retcode = _preprocess(chipType, dataset, mpagenomics_dir, data_dir, new_files_directory, tumor, settingType, outputgraph, outputlog, log, tag)
        
    if (retcode == 0):
        if (os.path.isdir(abs_fig_dir)) and (outputgraph == "TRUE"):
        
            new_files = os.listdir(abs_fig_dir)
            zipbuf = zipfile.ZipFile(os.path.join(abs_fig_dir, zipfigures), 'w', zipfile.ZIP_DEFLATED)
            for current_file in new_files:
                fn = os.path.join(abs_fig_dir, current_file)
                relfn = fn[len(abs_fig_dir) + len(os.sep):]
                zipbuf.write(fn, relfn)
        
        f = open(report, "w")   
        # Create report
        try:
            for name in extra_file_names:
                f.write("%s\t%s\t%s\n" %(re.match(r"^\d+_task_(.*).dat$", name).group(1),dataset,chipType))
        finally:
            shutil.rmtree(data_dir)
            f.close()
        
        sys.exit(retcode)
        
    sys.exit(retcode)
    
    
def _copy(source, destination):
    try:
        os.link(source, destination)
    except:
        shutil.copy(source, destination)

def _preprocess (chipType,dataset,mpagenomics_dir,data_dir,tmp_dir,tumor,settingType,outputgraph,outputlog,log,tag):
    script_dir=os.path.dirname(os.path.abspath(__file__))
    
    if (outputlog=="TRUE"):
        errfile=open(log,'w')
    else:
        errfile=open(os.path.join(tmp_dir,"errfile.log"),'w')
    
    retcode = subprocess.call(["Rscript", os.path.join(script_dir,"preprocess.R"), chipType, dataset, mpagenomics_dir, data_dir, tumor, settingType, outputgraph, tag], stdout = errfile, stderr = errfile)
    return(retcode)

 
if __name__ == "__main__":
    main()
