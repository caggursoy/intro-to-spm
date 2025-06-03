% 
% % Set your main data directory
% data_dir = './ds003548-1.0.1/';
% 
% % List all subject folders
% subjects = dir(fullfile(data_dir, 'sub-*'));
% subjects = subjects([subjects.isdir]);
% 
% % Create the main derivatives directory
% main_deriv_dir = fullfile(data_dir, 'derivatives', 'preprocessing');
% 
% % Create main derivatives directory if it doesn't exist
% if ~exist(main_deriv_dir, 'dir')
%     mkdir(main_deriv_dir);
% end
% 
% for i = 1:length(subjects)
%     % Set directory names
%     subjects(i).name
%     subj_dir = fullfile(data_dir, subjects(i).name);
%     % Source directories
%     func_dir = fullfile(subj_dir, 'func');
%     anat_dir = fullfile(subj_dir, 'anat');
%     % Target directories
%     dst_func_dir = fullfile(main_deriv_dir, subjects(i).name, 'func');
%     dst_anat_dir = fullfile(main_deriv_dir, subjects(i).name, 'anat');
% 
%     % Create derivatives folder if it doesn't exist
%     mkdir(dst_func_dir)
%     mkdir(dst_anat_dir)
% 
%     % List of derivative file patterns for func files
%     patterns = {'swra*.nii',
%         'a*.nii'
%         'r*.nii', 
%         'w*.nii', 
%         'mean*.nii', 
%         'rmean*.nii', 
%         'rp_*.txt',
%         '*.mat'};
% 
%     % Move functional files
%     for p = 1:length(patterns)
%         files = dir(fullfile(func_dir, patterns{p}));
%         for f = 1:length(files)
%             src = fullfile(func_dir, files(f).name);
%             dest = fullfile(dst_func_dir, files(f).name);
%             movefile(src, dest);
%         end
%     end
% 
%     % List of derivative file patterns for anat files
%     patterns = {'y_*.nii',
%         'iy_*.nii',
%         'm*.nii',
%         '*.mat'};
% 
%     % Move anat files
%     for p = 1:length(patterns)
%         files = dir(fullfile(anat_dir, patterns{p}));
%         for f = 1:length(files)
%             src = fullfile(anat_dir, files(f).name);
%             dest = fullfile(dst_anat_dir, files(f).name);
%             movefile(src, dest);
%         end
%     end
% end

function bids_prep_mover(data_dir)
% ORGANIZE_PREPROCESSING_DERIVATIVES Organizes SPM preprocessing derivatives
%
% USAGE:
%   bids_prep_mover(data_dir)
%
% INPUT:
%   data_dir - Path to the main BIDS dataset directory (string or char)
%
% DESCRIPTION:
%   This function moves SPM preprocessing derivative files from subject
%   directories to a centralized derivatives/preprocessing folder structure.
%   It handles both functional and anatomical preprocessing outputs.
%
% EXAMPLE:
%   organize_preprocessing_derivatives('./ds003548-1.0.1/')

    % Validate input
    if nargin < 1
        error('Data directory path is required');
    end
    
    if ~exist(data_dir, 'dir')
        error('Data directory does not exist: %s', data_dir);
    end

    % List all subject folders
    subjects = dir(fullfile(data_dir, 'sub-*'));
    subjects = subjects([subjects.isdir]);
    
    if isempty(subjects)
        warning('No subject folders found in: %s', data_dir);
        return;
    end

    % Create the main derivatives directory
    main_deriv_dir = fullfile(data_dir, 'derivatives', 'preprocessing');

    % Create main derivatives directory if it doesn't exist
    if ~exist(main_deriv_dir, 'dir')
        mkdir(main_deriv_dir);
        fprintf('Created derivatives directory: %s\n', main_deriv_dir);
    end

    for i = 1:length(subjects)
        % Set directory names
        fprintf('Processing subject: %s\n', subjects(i).name);
        subj_dir = fullfile(data_dir, subjects(i).name);
        
        % Source directories
        func_dir = fullfile(subj_dir, 'func');
        anat_dir = fullfile(subj_dir, 'anat');
        
        % Target directories
        dst_func_dir = fullfile(main_deriv_dir, subjects(i).name, 'func');
        dst_anat_dir = fullfile(main_deriv_dir, subjects(i).name, 'anat');
            
        % Create derivatives folders if they don't exist
        if ~exist(dst_func_dir, 'dir')
            mkdir(dst_func_dir);
        end
        if ~exist(dst_anat_dir, 'dir')
            mkdir(dst_anat_dir);
        end
        
        % Process functional files if func directory exists
        if exist(func_dir, 'dir')
            move_files_by_patterns(func_dir, dst_func_dir, {
                'swra*.nii',
                'a*.nii',
                'r*.nii', 
                'w*.nii', 
                'mean*.nii', 
                'rmean*.nii', 
                'rp_*.txt',
                '*.mat'
            });
        end

        % Process anatomical files if anat directory exists
        if exist(anat_dir, 'dir')
            move_files_by_patterns(anat_dir, dst_anat_dir, {
                'y_*.nii',
                'iy_*.nii',
                'm*.nii',
                '*.mat'
            });
        end
    end
    
    fprintf('Preprocessing derivatives organization complete!\n');
end

function move_files_by_patterns(src_dir, dst_dir, patterns)
% Helper function to move files matching specific patterns
    
    for p = 1:length(patterns)
        files = dir(fullfile(src_dir, patterns{p}));
        for f = 1:length(files)
            src = fullfile(src_dir, files(f).name);
            dest = fullfile(dst_dir, files(f).name);
            try
                movefile(src, dest);
                fprintf('  Moved: %s\n', files(f).name);
            catch ME
                warning('Failed to move %s: %s', files(f).name, ME.message);
            end
        end
    end
end