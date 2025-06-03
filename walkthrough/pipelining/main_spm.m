%% SPM main pipeline
% This file runs the main SPM pipeline for:
% preprocessing
% first level analysis
% second level analysis
%%

%% Check origins
anat_aux = {dir('/**/anat/sub*_T1w.nii')}; % get the original anatomical files
anat_aux = anat_aux{1}; % MATLAB/SPM logic for cell vectors
anat_files = strcat({anat_aux.folder},filesep,{anat_aux.name}); % create full filepaths for each anat file
for i=1:length(anat_files) % now loop over every anat file
    spm_image('Display', anat_files{i}) % display each image
    fig_handle=gcf;
    waitfor(fig_handle) % and wait until the previous window is destroyed(closed)
end

%% Set some constants
main_path = 'C:\Users\Cagatay\Documents\MATLAB\data\ds003548-1.0.1'; % main BIDS path
task_name = 'task-emotionalfaces_run-1';% name of the fMRI task to be analysed
deriv_path = fullfile(main_path, 'derivatives'); % derivatives path
prep_path = fullfile(main_path, 'derivatives', 'preprocessing'); % preprocessing path
events_file = fullfile(main_path, 'task-emotionalfaces_run-1_events.tsv');% BIDS events file in the format of '.tsv'
output_mat_file = fullfile(prep_path, 'mult_conds.mat'); % Output path to the multiple conditions file
% Get the participant ids
sub_nos = string(ls(main_path));
sub_nos = {sub_nos{contains(sub_nos,'sub-')}}; % remove unnecessary items
sub_nos = strtrim(sub_nos);
sub_nos = sort(sub_nos);

%% Preprocessing
prep_spm(main_path, task_name)
% SPM BIDS file arranger
bids_prep_mover(main_path)
% Regressor arranger
reg_arrange(prep_path, sub_nos, task_name)

%% First-level
firstlevel_spm(deriv_path, sub_nos)

%% Second-level
secondlevel_spm(deriv_path)