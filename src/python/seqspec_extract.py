from seqspec.utils import load_spec
from seqspec.seqspec_find import run_find_by_type
from seqspec.utils import region_ids_in_spec
from seqspec.seqspec_index import run_index
from seqspec.seqspec_onlist import run_onlist
import os
import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(description="Extract x_string and generate onlist from seqspec")
    parser.add_argument("-s", "--spec", help="seqspec yaml file", required=True)
    parser.add_argument("-m", "--modality", help="Modality to retreive information from", required=True)
    parser.add_argument("-fmt", "--format", help="x_string format. Could be kb, chromap, etc", required=True)
    parser.add_argument("-fq", "--fastqs", help="List of input fastq files", required=True, nargs='+')
    return parser.parse_args()

def main():
    # get arguments
    args = parse_arguments()

    seqspec_fn = getattr(args, "spec")
    seqspec = load_spec(seqspec_fn)
    modality = getattr(args, "modality")
    format_string = getattr(args, "format")
    fastqs = getattr(args, "fastqs")


    rids_in_spec = region_ids_in_spec(seqspec, modality, [os.path.basename(i) for i in fastqs])
    
    index_string = run_index(seqspec, modality, rids_in_spec, fmt=format_string)
    
    #print(index_string)
    file1 = open("index_string.txt", "w")  # append mode
    file1.write(index_string)
    file1.close()
    
    onlist = run_onlist(seqspec, modality, "barcode")
    onlist_fn = os.path.join(os.path.dirname(seqspec_fn), onlist)
    
    #print(onlist_fn)
    file1 = open("onlist_filename.txt", "w")  # append mode
    file1.write(onlist_fn)
    file1.close()

if __name__ == "__main__":
    main()