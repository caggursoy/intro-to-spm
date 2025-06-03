function [TR, slice_timing] = read_bids_timing_info(bids_root, subject, task, run)
% Read RepetitionTime and SliceTiming from BIDS JSON files
% Checks task-level JSON if SliceTiming not found in subject file
%
% Inputs:
%   bids_root - path to BIDS dataset root
%   subject   - subject ID (e.g., '01' or 'sub-01')
%   task      - task name (e.g., 'rest')
%   run       - run number (optional, e.g., '01' or 1)
%
% Outputs:
%   TR          - Repetition Time in seconds
%   slice_timing - Slice timing array

    % Remove run info from task name if exists
    task = replace(task, ['_' run], '');

    % Ensure subject has 'sub-' prefix
    if ~startsWith(subject, 'sub-')
        subject = ['sub-' subject];
    end
    
    % Build JSON filename
    if nargin > 3 && ~isempty(run)
        if isnumeric(run)
            run = sprintf('%02d', run);
        end
        json_file = sprintf('%s_task-%s_%s_bold.json', subject, task, run);
    else
        json_file = sprintf('%s_task-%s_bold.json', subject, task);
    end
    
    % Construct full path to subject-specific JSON
    json_path = fullfile(bids_root, subject, 'func', json_file);
    
    % Check if file exists
    if ~exist(json_path, 'file')
        error('JSON file not found: %s', json_path);
    end
    
    % Read subject-specific JSON file
    json_text = fileread(json_path);
    json_data = jsondecode(json_text);
    
    % Extract RepetitionTime
    if isfield(json_data, 'RepetitionTime')
        TR = json_data.RepetitionTime;
    else
        warning('RepetitionTime not found in %s', json_file);
        TR = [];
    end
    
    % Extract SliceTiming
    if isfield(json_data, 'SliceTiming')
        slice_timing = json_data.SliceTiming;
        slice_source = 'subject file';
    else
        % Check task-level JSON file in main BIDS directory
        task_json_file = sprintf('task-%s_bold.json', task);
        task_json_path = fullfile(bids_root, task_json_file);
        
        if exist(task_json_path, 'file')
            fprintf('SliceTiming not found in subject file, checking task file: %s\n', task_json_file);
            task_json_text = fileread(task_json_path);
            task_json_data = jsondecode(task_json_text);
            
            if isfield(task_json_data, 'SliceTiming')
                slice_timing = task_json_data.SliceTiming;
                slice_source = 'task file';
            else
                warning('SliceTiming not found in either %s or %s', json_file, task_json_file);
                slice_timing = [];
                slice_source = 'not found';
            end
        else
            warning('SliceTiming not found in %s and task file %s does not exist', json_file, task_json_file);
            slice_timing = [];
            slice_source = 'not found';
        end
    end
    
    % Display results
    fprintf('File: %s\n', json_file);
    if ~isempty(TR)
        fprintf('RepetitionTime: %.3f seconds\n', TR);
    end
    if ~isempty(slice_timing)
        fprintf('SliceTiming: [%s] (length: %d) - from %s\n', ...
                num2str(slice_timing', '%.3f '), length(slice_timing), slice_source);
    end
end