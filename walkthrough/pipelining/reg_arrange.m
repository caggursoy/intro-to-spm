%% Get single movement regressors file and divide into all participants
% converts movement regressors from one subject to all subjects
% prep_path: Preprocessing path
% sub_nos: Subject numbers
% task_name: Name of the task
function reg_arrange(prep_path, sub_nos, task_name) % task-emotionalfaces_run-1
    % number of frames for each subject
    num_scans = zeros(1,numel(sub_nos));
    % now create an array for indexes of each task
    for i=1:numel(sub_nos)
        task_file = fullfile(prep_path, sub_nos{i}, 'func', ['swra', sub_nos{i}, '_', task_name, '_bold.nii']);
        V = spm_vol(task_file);
        if i == 1
            num_scans(i) = length(V);
        else
           num_scans(i) = num_scans(i-1) + length(V); 
        end
    end
    % get the index of the respective task
    % scan_ind = find(contains(fold_names,selected_task));
    % get the rp_ regressor file
    reg_file = dir([prep_path '/**/rp_*']);
    reg_file = strcat({reg_file.folder},filesep,{reg_file.name}); 
    reg_data = importdata(reg_file{1});
    % Now loop in the num_scans to correctly get the data
    for scan_ind=numel(num_scans):-1:1
        % if index is 1, 0:index else index-1:index
        if scan_ind == 1
            out_data = reg_data(1:num_scans(scan_ind), :);       
        else
            out_data = reg_data(num_scans(scan_ind-1)+1:num_scans(scan_ind), :);
        end
        disp(['Fixing regression file for: ', sub_nos{scan_ind}])
        % and then save the file as txt
        % filename = strcat(prep_path,filesep,selected_task,'.txt');
        filename = fullfile(prep_path, sub_nos{scan_ind}, 'func', ['rp_a', sub_nos{scan_ind}, '_', task_name, '_bold.txt']);
        mat = cellstr(filename);
        save(mat{1}, 'out_data', '-ASCII')
    end
end