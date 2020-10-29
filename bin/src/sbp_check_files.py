#! /project/tools/python3.6/bin/python3

import sys
import os
from collections import defaultdict
import re
import difflib

def parse_args():
    opts = {
        'check_src_files': 0,
        'check_include_files': 0,
        'dump_uniq_paths': 0,
        'dump_uniq_incdirs': 0,
        'dump_v_files': 0,
        'dump_mems': 0,
        'check_patch_dir': 0,
        'filelist': '',
        'path_to_patches': '',
        'check_dc_log': 0,
        'path_to_dc_log': '',
        }
    
    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '-patch_dir':
            opts['check_patch_dir'] = 1
            i+=1
            opts['path_to_patches'] = re.sub('/$', '', sys.argv[i])
        elif sys.argv[i] == '-check_dc_log':
            opts['check_dc_log'] = 1
            i+=1
            opts['path_to_dc_log'] = re.sub('/$', '', sys.argv[i])
        elif sys.argv[i] == '-check_design_src':
            opts['check_src_files'] = 1
        elif sys.argv[i] == '-check_design_includes':
            opts['check_include_files'] = 1
        elif sys.argv[i] == '-dump_paths':
            opts['dump_uniq_paths'] = 1
        elif sys.argv[i] == '-dump_incdirs':
            opts['dump_uniq_incdirs'] = 1
        elif sys.argv[i] == '-dump_v_files':
            opts['dump_v_files'] = 1
        elif sys.argv[i] == '-dump_mems':
            opts['dump_mems'] = 1
        elif sys.argv[i] == '-h':
            print("python check_filenames.py <file>")
            print("Options:")
            print("  -check_design_src    : prints all unique filenames in <file> and gives warnings for any filenames found in multiple locations")
            print("  -dump_paths          : prints all unique paths to files in <file>")
            print("  -dump_incdirs        : prints all unique include directories (+incdir+<path>) in <file>")
            print("  -check_design_includes       : prints all unique include files found in incdirs and gives warnings for any includes found in multiple incdirs")
            print("  -dump_v_files        : prints all files included with the -v flag in <file>")
            print("  -dump_mems           : prints location of all mems (any source starting with 'RR16FFGL'")
            print("  -patch_dir <path_to_patch_dir> : checks that included files in <path_to_patch_dir> are only included from <path_to_patch_dir>")
            sys.exit()
        elif os.path.exists(sys.argv[i]):
            opts['filelist'] = sys.argv[i]
        else:
            print("ERROR: Invalid argument")
            sys.exit()
        i+=1
    return opts
        

    

def prepare_for_diff(file):
    file_lines = []
    vhd_entities = []
    with open(file, 'r') as fin:
        for line in fin:
            # Strip whitespace and newlines from end of line & convert to all lowercase
            line = line.rstrip().lower()

            # For VHDL files, capture entity/package name if defined on line
            entity_found = re.search('^ *entity *([a-zA-Z0-9_]*) *is *$', line)
            package_found = re.search('^ *package *([a-zA-Z0-9_]*) *is *$', line)
            if file.endswith(".vhd") and bool(entity_found):
                vhd_entities.append(entity_found.group(1))
            if file.endswith(".vhd") and bool(package_found):
                vhd_entities.append(package_found.group(1))
                
            # replace multiple spaces/tabs with single space
            line = re.sub('[ \t]+', '', line)

            # drop if comment or blank
            if (file.endswith(".vhd") and line.startswith("--")) or (file.endswith(".v") and line.startswith("//")) or line.startswith("\n"):
                continue

            file_lines.append(line)
    return file_lines,vhd_entities

# VHDL Files with the same name are only a problem if they have the same entity/package, but with
#   different logic
def file_conflict(vhd_file0, vhd_file1):
    file0,entities0 = prepare_for_diff(vhd_file0)
    file1,entities1 = prepare_for_diff(vhd_file1)
    if len(entities0) > 0 and entities0 != entities1:
        #print("OK: Files Contain different Entities/Packages ({0}, {1})".format(vhd_file0,vhd_file1))
        return False
    else:
        diff = difflib.unified_diff(file0, file1, fromfile='file0', tofile='file1')
        if not list(diff):
            #print("OK: Files are the same ({0}, {1})".format(vhd_file0,vhd_file1))
            return False
        else:
            return True

# Check if any files with common name from different locations.  If so, check if it is a problem.
def check_source_files(src_dict, chk_type):
    print("Checking design {0} files...".format(chk_type))
    mult_files_found = 0
    error = 0
    for k in sorted(src_dict):
        if len(src_dict[k]) > 1:
            if mult_files_found == 0:
                mult_files_found = 1
                print("Warning: Files exist with the same name in multiple locations.  Checking for issues...")
            for i in range(1, len(src_dict[k])):
                if file_conflict(src_dict[k][0]+'/'+k, src_dict[k][i]+'/'+k):
                    error = 1
                    print("ERROR: Files do NOT Match: {0} : {1} : {2}".format(k, len(src_dict[k]), src_dict[k]))
                    break
    if error == 0:
        print("OK: All files either match or contain different entities/packages")
                    



#main
opts = parse_args()

# Dictionary of lists where key = filename & value = list of paths
uniq_filename_dict = defaultdict(list)
uniq_path_list = []
uniq_incdir_list = []
uniq_v_list = []
uniq_mem_dict = defaultdict(list)

in_mem_files = 0;

# Read in file
with open(opts['filelist']) as fin:
    for line in fin:
        # Strip whitespace and newlines from line
        line = line.rstrip()
        
        # Skip Comments
        if line.startswith("//") or line.startswith("#"):
            continue
        elif in_mem_files == 1 and not line.endswith("\\"):
            in_mem_files = 0
            continue
        elif in_mem_files == 1:
            continue
        elif line.startswith("set memLibFiles") or line.startswith("set memMWFiles"):
            in_mem_files = 1
            continue
        
        # source files in flat.f
        if line.startswith("/"):
            path, filename = os.path.split(line)
            if path not in uniq_path_list:
                uniq_path_list.append(path)
            if filename not in uniq_filename_dict or path not in uniq_filename_dict[filename]:
                uniq_filename_dict[filename].append(path)
            if filename.startswith("RR16FFGL") and (filename not in uniq_mem_dict or path not in uniq_mem_dict[filename]):
                uniq_mem_dict[filename].append(path)

        # source files in .tcl
        if line.startswith("lappend hdlFiles") or line.startswith("lappend vhdlFiles"):
            line = re.sub('^ *lappend hdlFiles *', '', line)
            line = re.sub('^ *lappend vhdlFiles *', '', line)
            path, filename = os.path.split(line)
            if path not in uniq_path_list:
                uniq_path_list.append(path)
            if filename not in uniq_filename_dict or path not in uniq_filename_dict[filename]:
                uniq_filename_dict[filename].append(path)
            if filename.startswith("RR16FFGL") and (filename not in uniq_mem_dict or path not in uniq_mem_dict[filename]):
                uniq_mem_dict[filename].append(path)
                
        # include directories in flat.f
        elif line.startswith("+incdir+"):
            line = re.sub('^ *\+incdir\+ *', '', line)
            #line = line.replace('+incdir+', '')
            if line not in uniq_incdir_list:
                uniq_incdir_list.append(line)

        # include directories in .tcl
        elif line.startswith("lappend hdlSearchPath"):
            line = re.sub('^ *lappend hdlSearchPath *', '', line)
            if line not in uniq_incdir_list:
                uniq_incdir_list.append(line)

        # files included with -v flag
        elif line.startswith("-v "):
            line = re.sub('^ *-v *', '', line)
            #line = line.replace('-v ', '')
            if line not in uniq_v_list:
                uniq_v_list.append(line)
            path, filename = os.path.split(line)
            if filename.startswith("RR16FFGL") and (filename not in uniq_mem_dict or path not in uniq_mem_dict[filename]):
                uniq_mem_dict[filename].append(path)

# print warnings if file found in multiple locations
if opts['check_src_files'] == 1:
    check_source_files(uniq_filename_dict, 'source')
    
# print path to all directories where source files can be found
if opts['dump_uniq_paths'] == 1:         
    uniq_path_list.sort()
    print("\nAll Unique Paths:"        )
    for p in uniq_path_list:
        print(p)

# print paths to all directories include with +incdir+
if opts['dump_uniq_incdirs'] == 1:
    uniq_incdir_list.sort()
    print("\nUnique Include Directories:")
    for p in uniq_incdir_list:
        print(p)

# Check for any include files (.h/.vh/.svh/.fh/.fvh) that exist in multiple include directories (+incdir+)        
uniq_includes_dict = defaultdict(list)
if opts['check_include_files'] == 1:
    for d in uniq_incdir_list:
        for f in os.listdir(d):
            if f.endswith(".h") or f.endswith(".vh") or f.endswith(".svh") or f.endswith(".fh") or f.endswith(".fvh"):
                if f not in uniq_includes_dict or d not in uniq_includes_dict[f]:
                    uniq_includes_dict[f].append(d)
    check_source_files(uniq_includes_dict, 'include')

    #print("\nWarning: Following Include files exist in multiple included locations...")
    #for k in sorted(uniq_includes_dict):
    #    if len(uniq_includes_dict[k]) > 1:
    #        print("{0} : {1} : {2}".format(k, len(uniq_includes_dict[k]), uniq_includes_dict[k]))

# print all files included with -v flag
if opts['dump_v_files'] == 1:
    uniq_v_list.sort()
    print("\nUnique -v files:")
    for p in uniq_v_list:
        print(p)

# print all files included that start with "RR16FFGL"
if opts['dump_mems'] == 1:
    print("\nMemories:")
    for k in sorted(uniq_mem_dict):
        print("{0} : {1}".format(k, uniq_mem_dict[k]))

# Check that files existing in patch directory are included from patch directory and not elsewhere
if opts['check_patch_dir'] == 1:
    for f in os.listdir(opts['path_to_patches']):
        if f in uniq_filename_dict and (uniq_filename_dict[f][0] != opts['path_to_patches'] or len(uniq_filename_dict[f]) > 1):
            print("ERROR: {0} is being used from {1} when patch version available in {2}".format(f, uniq_filename_dict[f], opts['path_to_patches']))
        else:
            print("OK: {0} is being used from patch directory: {1}".format(f, opts['path_to_patches']))
    

