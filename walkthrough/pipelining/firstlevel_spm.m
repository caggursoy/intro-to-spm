%% SPM First level analysis script
% Performs SPM first level analysis
% Inputs:
%   deriv_path: Main path for all participants' derivatives folder
%% Start function definition
function firstlevel_spm(deriv_path, sub_nos)
    %% Clear the screen
    clc
    %% Handle paths and directories
    % First set the firstlevel and preprocessing paths
    flevel_path = fullfile(deriv_path, 'first-level');
    prep_path = fullfile(deriv_path, 'preprocessing');
    % Create the firstlevel directories if they don't exist
    for ind=1:length(sub_nos)
        sub_no = sub_nos{ind}; % get the subject no
        try
            if ~exist(fullfile(flevel_path, sub_no), 'dir')
                mkdir(fullfile(flevel_path, sub_no));
            else % if they exist, remove and recreate them so we can restart the analyses
                rmdir(fullfile(flevel_path, sub_no), 's');
                mkdir(fullfile(flevel_path, sub_no));
            end
        catch
            continue
        end
    end
    % Create folders to save batch files
    batch_main_path = fullfile(flevel_path, 'batches');
    if ~isfolder(batch_main_path)
       mkdir(batch_main_path)
    end
    %% Init SPM defaults and variables
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    %% First Level Analysis
    % Create the multiple conditions file
    ind_path = strfind(deriv_path, '\');
    bids_main_path = deriv_path(1:ind_path(end)-1);
    tsv_path = fullfile(bids_main_path, 'task-emotionalfaces_run-1_events.tsv');
    conds_mat_path = fullfile(flevel_path, 'multiple_conditions.mat');
    create_spm_multiple_conds(tsv_path, conds_mat_path);
    %% Model specification
    % Start a for loop for all participants
    for ind=1:length(sub_nos)
        % Init the batches
        task_specify = struct; % init batch struct file
        task_estim = struct; % init batch struct file
        task_contrast = struct; % init batch struct file
        % Set the subject no
        sub_no = sub_nos{ind};
        disp(['Running First Level Specification for: ', sub_no, '...'])
        % Find the movement regressor file and set it to a variable
        multi_reg_file = dir(fullfile(prep_path,'**',['rp_a', sub_no, '*.txt']));
        multi_reg_file = fullfile(multi_reg_file.folder, multi_reg_file.name);
        %
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(fullfile(flevel_path, sub_no));
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        %
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList', fullfile(prep_path, sub_no, 'func'), '^swra.*', [1 Inf]));
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.multi = cellstr(conds_mat_path);
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(multi_reg_file);
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
        task_specify.matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        % Run
        spm_jobman('run',task_specify.matlabbatch); % run the batch
        disp(['First Level Specification for: ', sub_no, ' is done...'])
        % And save the batch file for future
        if ~exist(fullfile(batch_main_path, sub_no), 'dir')
                mkdir(fullfile(batch_main_path, sub_no));
        end
        save(fullfile(batch_main_path, sub_no, 'task_specify_batch.mat'), 'task_specify')
        %% Model estimation
        % Continue inside the same for loop
        disp(['Running First Level Estimation for: ', sub_no, '...'])
        %
        task_estim.matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(task_specify.matlabbatch{1}.spm.stats.fmri_spec.dir{1}, 'SPM.mat'));
        task_estim.matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1;
        task_estim.matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        % Run
        spm_jobman('run',task_estim.matlabbatch); % run the batch
        disp(['First Level Estimation for: ', sub_no, ' is done...'])
        % And save the batch file for future
        save(fullfile(batch_main_path, sub_no, 'task_estim_batch.mat'), 'task_estim')
        %% Model contasts
        %% Define constrasts odour task
        task_contrast.matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(task_specify.matlabbatch{1}.spm.stats.fmri_spec.dir{1}, 'SPM.mat'));
        disp(['Building First Level Contrasts for: ', sub_no, '...'])
        %
        task_contrast.matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Happy vs Sad';
        task_contrast.matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [0 0 1 -1 0 0 0];
        task_contrast.matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        %
        task_contrast.matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Happy vs Angry';
        task_contrast.matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 0 1 0 -1 0 0];
        task_contrast.matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        %
        task_contrast.matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Happy vs Blank';
        task_contrast.matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = [-1 0 1 0 0 0 0];
        task_contrast.matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        %
        task_contrast.matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'Sad vs Angry';
        task_contrast.matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = [0 0 0 1 -1 0 0];
        task_contrast.matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        %
        task_contrast.matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Sad vs Blank';
        task_contrast.matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = [-1 0 0 1 0 0 0];
        task_contrast.matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        %
        task_contrast.matlabbatch{1}.spm.stats.con.delete = 1;
        spm_jobman('run',task_contrast.matlabbatch);
        disp(['Building First Level Contrasts for: ', sub_no, ' is done...'])
        % And save the batch file for future
        save(fullfile(batch_main_path, sub_no, 'task_contrast_batch.mat'), 'task_contrast')
    end
end
