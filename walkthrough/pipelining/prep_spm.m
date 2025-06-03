function prep_spm(main_path, task_name)
    %% Init SPM defaults and variables
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    %% Init the batches
    prep_slice = struct;
    prep_realign = struct;
    prep_segm = struct;
    prep_coreg = struct;
    prep_norm = struct;
    prep_smooth = struct;
    %% Get the participant ids
    sub_nos = string(ls(main_path));
    sub_nos = {sub_nos{contains(sub_nos,'sub-')}}; % remove unnecessary items
    sub_nos = sort(sub_nos);
    %% Get functional files
    func_files = {dir(fullfile(main_path, 'sub-*',  ['func/*' task_name '*.nii']))};
    %% Slice timing
    disp('Start Slice Timing...')
    % Select all slice timing files
    st_files = cellstr(spm_select('ExtFPListRec', main_path, ['sub-\d+_task-' task_name '_bold\.nii'], [1 Inf]));
    filt_st_files = st_files(~contains(st_files, 'derivatives')); % filter out the derivatives folders
    V = spm_vol(filt_st_files{1}); % get number of volumes
    dims = V(1).dim; % get dimensions
    % Get TR and slice timing info from the JSON files
    [TR, slice_timing] = read_bids_timing_info(main_path, 'sub-01', task_name, 'run-1')
    [~, slice_order] = sort(slice_timing); % calculate the slice order
    % 
    prep_slice.matlabbatch{1}.spm.temporal.st.scans = {filt_st_files};
    prep_slice.matlabbatch{1}.spm.temporal.st.nslices = dims(3); % number of slices is the third dimension
    prep_slice.matlabbatch{1}.spm.temporal.st.tr = TR;
    prep_slice.matlabbatch{1}.spm.temporal.st.ta = prep_slice.matlabbatch{1}.spm.temporal.st.tr - prep_slice.matlabbatch{1}.spm.temporal.st.tr/prep_slice.matlabbatch{1}.spm.temporal.st.nslices;
    prep_slice.matlabbatch{1}.spm.temporal.st.so = slice_order;
    prep_slice.matlabbatch{1}.spm.temporal.st.refslice = ceil(prep_slice.matlabbatch{1}.spm.temporal.st.nslices/2); % middle slice
    prep_slice.matlabbatch{1}.spm.temporal.st.prefix = 'a';
    % Run
    spm_jobman('run',prep_slice.matlabbatch); % run the batch
    disp('Slice Timing done..!')
    %% Realignment
    disp('Start Realignment...')
    % Select all slice timing arranged files
    realign_files = cellstr(spm_select('ExtFPListRec', main_path, ['asub-\d+_task-' task_name '_bold\.nii'], [1 Inf]));
    filt_realign_files = realign_files(~contains(realign_files, 'derivatives')); % filter out the derivatives folders
    %
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.data = {filt_realign_files};
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.95;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 1.5;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    prep_realign.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    % Run
    spm_jobman('run',prep_realign.matlabbatch); % run the batch
    disp('Realignment done..!')
    %% Segmentation
    disp('Start Segmentation...')
    % Select all T1w files for segmentation
    segment_files = cellstr(spm_select('ExtFPListRec', main_path, ['^sub-\d+_T1w\.nii'], [1 Inf]));
    filt_segm_files = segment_files(~contains(segment_files, 'derivatives')); % filter out the derivatives folders
    %
    prep_segm.matlabbatch{1}.spm.spatial.preproc.channel.vols = filt_segm_files;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.0001;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',1']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',2']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',3']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',4']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',5']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm('Dir') filesep 'tpm' filesep 'TPM.nii' ',6']};
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0 0.1 0.01 0.04];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    prep_segm.matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN NaN NaN NaN];
    % Run
    spm_jobman('run',prep_segm.matlabbatch); % run the batch
    disp('Segmentation done..!')
    %% Coregistration
    disp('Start Coregistration...')
    ref_files = cellstr(spm_select('ExtFPListRec', main_path, ['^meanasub-\d+_task-' task_name '_bold\.nii'], [1 Inf]));
    filt_ref_files = ref_files(~contains(ref_files, 'derivatives')); % filter out the derivatives folders
    ref_file_path = ref_files;
    src_file_path = filt_segm_files(1);
    %
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.ref = ref_file_path;
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.source = src_file_path;
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    prep_coreg.matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    % Run
    spm_jobman('run',prep_coreg.matlabbatch); % run the batch
    disp('Coregistration done..!')
    %% Normalisation
    disp('Start Normalisation...')
    def_field = cellstr(spm_select('ExtFPListRec', main_path, ['^y_sub-\d+_T1w\.nii'], [1 Inf]));
    filt_def_field = def_field(~contains(def_field, 'derivatives')); % filter out the derivatives folders
    def_field = filt_def_field(1);
    %
    write_files = cellstr(spm_select('ExtFPListRec', main_path, ['^rasub-\d+_task-' task_name '_bold\.nii'], [1 Inf]));
    filt_write_files = write_files(~contains(write_files, 'derivatives')); % filter out the derivatives folders
    %
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.subj.def = {strrep(def_field{1}, ',1','')};
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.subj.resample = filt_write_files;
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 7;
    prep_norm.matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    % Run
    spm_jobman('run',prep_norm.matlabbatch); % run the batch
    disp('Normalisation done..!')
    %% Smoothing
    disp('Start Smoothing...')
    smooth_files = cellstr(spm_select('ExtFPListRec', main_path, ['^wrasub-\d+_task-' task_name '_bold\.nii'], [1 Inf]));
    filt_smooth_files = smooth_files(~contains(smooth_files, 'derivatives')); % filter out the derivatives folders
    %
    prep_smooth.matlabbatch{1}.spm.spatial.smooth.data = filt_smooth_files;
    prep_smooth.matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    prep_smooth.matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    prep_smooth.matlabbatch{1}.spm.spatial.smooth.im = 0;
    prep_smooth.matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    % Run
    spm_jobman('run',prep_smooth.matlabbatch); % run the batch
    disp('Smoothing done..!')

end