function [EEG, ORN, com] = loadcsv(filepath)
    com = '';
    EEG = [];
    EEG = eeg_emptyset;

    ORN = [];
    ORN = eeg_emptyset;

    orn_srate = 20; % Sampling rate of ORN data

    [directory, filename, ~] = fileparts(filepath);
    idx_final_underscore = find(filename == '_', 1, 'last');
    name = extractBefore(filename, idx_final_underscore);
    
    fullfile_EXG = fullfile(directory, append(name, '_ExG.csv'));
    EXG = importdata(fullfile_EXG, ',', 1);
    eeg_data = sortrows(EXG.data, 1);
    eeg_data = eeg_data(:, 2:end)';
    eeg_ch_names = EXG.textdata(2:end);
    eeg_timestamps = EXG.data(:, 1);
    
    fullfile_ORN = fullfile(directory, append(name, '_ORN.csv'));
    ORN = importdata(fullfile_ORN, ',', 1);
    orn_data = sortrows(ORN.data, 1);
    orn_data = orn_data(:, 2:end)';
    orn_ch_names = ORN.textdata(2:end);
    orn_timestamps = ORN.data(:, 1);
    
    fullfile_marker = fullfile(directory, append(name, '_Marker.csv'));
    marker = importdata(fullfile_marker, ',',1);
    eeg_marker = [];
    orn_marker = [];
    if isfield(marker,'data')
        eeg_marker = zeros(size(marker.data,1), 2);
        eeg_marker(:, 2) = marker.data(:, 2);
    
        orn_marker = zeros(size(marker.data,1), 2);
        orn_marker(:, 2) = marker.data(:, 2);
    end
    
    % Event syncing
    if isfield(marker, 'data')
        % Event syncing - find the first timestamp that is close to the marker
        for i = 1:size(marker, 1)
            idx_eeg_above_marker = find(exg_timestamp > marker(i, 1), 1);
            idx_eeg_below_marker = idx_eeg_above_marker - 1;
        
            diff_eeg_above = abs(exg_timestamp(idx_eeg_above_marker) - marker(i, 1));
            diff_eeg_below = abs(exg_timestamp(idx_eeg_below_marker) - marker(i, 1));

            if (diff_eeg_above > diff_eeg_below)
                eeg_marker(i, 1) = idx_eeg_below_marker;
            else
                eeg_marker(i, 1) = idx_eeg_above_marker;
            end

            idx_orn_above_marker = find(orn_timestamp > marker(i, 1), 1);
            idx_orn_below_marker = idx_orn_above_marker - 1;

            diff_orn_above = abs(orn_timestamp(idx_orn_above_marker) - marker(i, 1));
            diff_orn_below = abs(orn_timestamp(idx_orn_below_marker) - marker(i, 1));

            if (diff_orn_above > diff_orn_below)
                orn_marker(i, 1) = idx_orn_below_marker;
            else
                orn_marker(i, 1) = idx_orn_above_marker;
            end
        end
    end

    sample_rate = getSamplingRate(eeg_timestamps);
    
    % Convert to EEGLAB structure
    eeg_chanlocs = struct('labels', eeg_ch_names);
    EEG = pop_importdata('dataformat', 'array', 'nbchan', ...
        size(eeg_data, 1), 'data', eeg_data, 'setname', 'raw_eeg', ...
        'srate', sample_rate, 'xmin', 0, 'chanlocs', eeg_chanlocs);
    EEG = eeg_checkset(EEG);
    EEG = pop_importevent(EEG, 'event', eeg_marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    EEG = eeg_checkset(EEG);

    orn_chanlocs = struct('labels', orn_ch_names);
    ORN = pop_importdata('dataformat', 'array', 'nbchan', 9, 'data', ...
        orn_data, 'setname', 'raw_orn', 'srate', orn_srate, 'xmin', 0, ...
        'chanlocs', orn_chanlocs);
    ORN = eeg_checkset(ORN);
    ORN = pop_importevent(ORN, 'event', orn_marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    ORN = eeg_checkset(ORN);
end    