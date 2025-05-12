%% MATLAB script to download files from ds003548-1.0.1 dataset
%% Dataset link: https://openneuro.org/datasets/ds003548/versions/1.0.1
% Read the shell script file
fid = fopen('ds003548-1.0.1.sh', 'r');
if fid == -1
    error('Could not open the shell script file');
end

% Read all lines from the file
lines = {};
line = fgetl(fid);
while ischar(line)
    lines{end+1} = line;
    line = fgetl(fid);
end
fclose(fid);

% Filter for files
filt_lines = {};
for i = 1:length(lines)
    if contains(lines{i}, 'curl')
        filt_lines{end+1} = lines{i};
    end
end

% Process each curl command
for i = 1:length(filt_lines)
    % Extract URL and output path from curl command
    curl_cmd = filt_lines{i};
    
    % Find the URL (between https:// and the space before -o)
    url_start = strfind(curl_cmd, 'https://');
    url_end = strfind(curl_cmd, ' -o ');
    url = curl_cmd(url_start:url_end-1);
    
    % Find the output path (after -o)
    output_start = url_end + 3; % Skip ' -o '
    output_path = strtrim(curl_cmd(output_start:end));
    
    % Create directory structure if it doesn't exist
    [dir_path, ~, ~] = fileparts(output_path);
    if ~exist(dir_path, 'dir')
        fprintf('Creating directory: %s\n', dir_path);
        mkdir(dir_path); % Uncomment to actually create directories
    end
    
    % Print the download command that would be executed
    fprintf('Downloading: %s to %s\n', url, output_path);
    websave(output_path, url); % Uncomment to actually download files
end

% Finally unzip all the .nii.gz files because SPM cannot read unzipped
% files
fl=dir('ds003548-1.0.1/**/*.gz');
fl=fullfile({fl.folder},{fl.name});
gunzip(fl);