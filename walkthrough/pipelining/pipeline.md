# SPM Pipelining

All the scripts and functions listed below are bare minimum for creating a pipeline for the dataset we are working on.  
For different datasets, the scripts and functions need minimal adaptation; (for example timing data etc.) then it could be run succesfully.

- `main_spm.m`
    - Main pipeline file that calls all the functions
- `prep_spm.m`
    - Preprocessing function, handles everything related to the preprocessing
- `read_bids_timing_info.m`
    - Function that reads RepetitionTime and SliceTiming information from BIDS JSON files
- `bids_prep_mover.m`
    - A mover function, that *makes* the directory adhere to the BIDS rules; which SPM does not do on it's own (yet)
- `reg_arrange.m`
    - SPM saves movement regressors in one big file for all subjects. This function converts movement regressors from one big file to individual subjects files
- `create_spm_multiple_conds.m`
    - The function creates names, onsets, and durations variables required by SPM; especially useful if one do not want to input the conditions, onsets and timings by hand during First-level model specification (but VERY dangerous, so always double check the result of this!)
- `firstlevel_spm.m`
    - First-level analysis function
- `secondlevel_spm.m`
    - Second-level analysis function


**Contact me, if you have any questions regarding any step!**