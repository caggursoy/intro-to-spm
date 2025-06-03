function create_spm_multiple_conds(events_file, output_mat_file)
% CREATE_SPM_MULTIPLE_CONDITIONS Convert BIDS events.tsv to SPM multiple conditions .mat
%
% Usage: create_spm_multiple_conditions('sub-01_task-faces_events.tsv', 'multiple_conditions.mat')
%
% Inputs:
%   events_file    - Path to BIDS events.tsv file
%   output_mat_file - Output .mat filename for SPM
%
% The function creates names, onsets, and durations variables required by SPM

    % Read the events.tsv file
    events = readtable(events_file, 'FileType', 'text', 'Delimiter', '\t');
    
    % Get unique condition names
    conditions = unique(events.trial_type, 'stable');
    
    % Initialize cell arrays for SPM format
    names = {};
    onsets = {};
    durations = {};
    tmod = {}; % Optional: time modulation
    
    for i = 1:length(conditions)
        condition = conditions{i};
        names{i} = condition;
    
        % Find rows for this condition
        condition_idx = strcmp(events.trial_type, condition);
    
        % Extract onsets and durations as row vectors (SPM expects row vectors)
        onsets{i} = events.onset(condition_idx)';
        durations{i} = events.duration(condition_idx)';
    
        % Set time modulation (0 = none, or set as needed)
        tmod{i} = 0; % or 1, 2, ... as required
    end
    % Unwrap cells for durations and onsets
    % durations = cellfun(@(x) x{1}, durations, 'UniformOutput', false);  
    % onsets = cellfun(@(x) x{1}, onsets, 'UniformOutput', false);
    if isa(names, 'string')  
        names = cellstr(names);  
    end
    
    % Save as .mat file for SPM
    save(output_mat_file, 'names', 'onsets', 'durations', 'tmod');
    
    % Display summary
    fprintf('Created %s with %d conditions:\n', output_mat_file, length(names));
    for i = 1:length(names)
        fprintf('  %s: %d events\n', names{i}, length(onsets{i}));
    end 
end

% Example usage:
% create_spm_multiple_conds('task-emotionalfaces_run-1_events.tsv', 'multiple_conditions.mat');