%% SPM Second level analysis script
% Performs SPM second level analysis
% Inputs:
%   deriv_path: Main path for all participants' derivatives folder
%% Start function definition
function secondlevel_spm(deriv_path)
    %% Clear the screen
    clc
    % First set the firstlevel and preprocessing paths
    slevel_path = fullfile(deriv_path, 'second-level');
    prep_path = fullfile(deriv_path, 'preprocessing');
    flevel_path = fullfile(deriv_path, 'first-level');
    % Get the contrast files and their definitions
    all_cons = spm_select('ExtFPListRec', flevel_path, 'con.*', [1 Inf]);
    con_names = dir(fullfile(flevel_path, '**', 'con*.nii'));
    con_dirs = unique({con_names.folder});
    con_names = unique({con_names.name});
    con_descrip = cell(1, length(con_names));
    % Now read the con_names and get the descriptions
    for i=1:numel(con_names)
        V = spm_vol(fullfile(con_dirs{i}, con_names{i}));
        con_descrip{i} = V.descrip;
        con_descrip{i} = replace(con_descrip{i}, ['Contrast ', int2str(i), ': '], '');
    end
    %% Init SPM defaults and variables
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    %% Model specification
    for ind=1:numel(con_descrip)
        disp(['Running First Level Specification for: ', con_descrip{ind}, '...'])
        % Create the Second level directory first
        try
            if ~exist(fullfile(slevel_path, con_descrip{ind}), 'dir')
                mkdir(fullfile(slevel_path, con_descrip{ind}));
            else % if they exist, remove and recreate them so we can restart the analyses
                rmdir(fullfile(slevel_path, con_descrip{ind}), 's');
                mkdir(fullfile(slevel_path, con_descrip{ind}));
            end
        catch
            continue
        end
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(fullfile(slevel_path, con_descrip{ind}));
        cd(sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.dir{1})
        %%
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(spm_select('ExtFPListRec', flevel_path, con_names{ind}, [1 Inf]));
        %%
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        % Run
        spm_jobman('run',sleveltask_specify.matlabbatch); % run the batch
        disp(['Second Level Specification for contrast: ', con_descrip{ind}, ' is done...'])
        %% Model estimation
        disp(['Running Second Level Estimation for: ', con_descrip{ind}, '...'])
        sleveltask_estim.matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(sleveltask_specify.matlabbatch{1}.spm.stats.factorial_design.dir{1}, 'SPM.mat'));
        sleveltask_estim.matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
        sleveltask_estim.matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        % Run
        spm_jobman('run',sleveltask_estim.matlabbatch); % run the batch
        disp(['Second Level Estimation for contrast: ', con_descrip{ind}, ' is done...'])
    end
end


