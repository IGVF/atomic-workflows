from seqspec.utils import load_spec
from seqspec.seqspec_find import run_find_by_type
from seqspec.utils import region_ids_in_spec
from seqspec.seqspec_index import run_index
from seqspec.seqspec_onlist import run_onlist
import os

seqspec = load_spec("bmmc_spec-bc.yaml")
modality = "atac"


rids_in_spec = region_ids_in_spec( seqspec, modality, [os.path.basename(i) for i in ['BMMC_single_donor_ATAC_L001_R1.fastq.gz','BMMC_single_donor_ATAC_L001_R2.fastq.gz']] )
x_string = run_index(seqspec, modality, rids_in_spec, fmt="kb")
x_string

##RNA corrected '1,50,58,1,58,66,1,66,74:1,0,10:0,0,50'

##RNA corrected 1,50,74:1,0,10:0,0,50


##ATAC BMMC uncorrected 1,65,73,1,103,111,1,141,149:-1,-1,-1:0,0,50,1,0,50

##ATAC BMMC corrected 1,50,74:-1,-1,-1:0,0,50,1,0,50