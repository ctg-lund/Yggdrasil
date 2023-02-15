#!/usr/bin/env python3
# This script starts the Yggdrasil workflow
# it has three main functions:
# 1. It checks if there are new files in the upload folder
# 2. As nextflow is crap at dealing with symlinks, 
# it sets up the output structure and symlinks the raw data there
# 3. It starts the nextflow workflow

import os
from pathlib import Path
import multiprocessing as mp
import subprocess
import shlex

def get_project_ids(path):
    # the project id is found in ./ctg.config
    # it is a comma separated list
    conf = path.glob('*CTG_*.csv')
    try: 
        with open(conf, 'r') as f:
            for line in f:
                if line.lstrip().startswith(''):
                    return line.split('=')[1]\
                            .strip().replace('\'','').split(',')
    except:
        # do nothing if the file does not exist and return None
        pass

def setup_output_structure(output_root, path, project_ids):
    # we need to set up the output structure
    # this is done by creating a folder for each project id
    # and symlinking the raw data there
    # the output structure is:
    # /projects/fs1/shared/Test_Jobs/<project_id>/<results>
    # turning this to void function
    out_paths = []
    
    for project_id in project_ids:
        output_path = output_root / project_id
        output_path.mkdir(parents=True, exist_ok=True)
        out_paths.append(output_path)
        # symlink the raw data directory
        raw_data = output_path / 'raw' / path.stem
        raw_data.parent.mkdir(parents=True, exist_ok=True)
        if not raw_data.exists():
            raw_data.symlink_to(path)
        

def start_yggdrasil(project_list, raw_data):
    # give raw data comma separated list of project ids
    cmd = shlex.split('echo " nextflow run /projects/fs1/nas-sync/yggdrasil.nf'  
       f'--projectids {project_list} "')
    
    subprocess.run(cmd, capture_output=True)
    


if __name__ == '__main__':
    # for the sake of multiprocessing
    upload_dir = Path('/projects/fs1/nas-sync/upload')
    output_root = Path('/projects/fs1/shared/Test_Jobs')

    # set script umask to 0002
    os.umask(0o0002)

    # check if there are new files in the upload folder
    # we know that sync is done when ctg.sync.done is present
    # when processing is started we add cron.yggdrasil.start
    ready_for_processing = []
    for p in upload_dir.glob('*/ctg.sync.done'):
        if not (p.parent / 'yggdrasil.cron.start').exists():
            ready_for_processing.append(p.parent)
    
    for p in ready_for_processing:
        result = get_project_ids(p)
        if result:    
            setup_output_structure(output_root=output_root, path=p, project_ids=result)
            #start_yggdrasil(project_list=result, raw_data=p)
            start_yggdrasil(project_list=result, raw_data=p)
            
