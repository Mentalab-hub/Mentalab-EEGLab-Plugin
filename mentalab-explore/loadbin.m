function [EEG, com] = loadbin(filepath, varargin)
    com = '';

    fid = fopen(filepath);
    read = 1;
    orn_data = [];
    orn_timestamp = [];
    exg_data = [];
    exg_timestamp = [];
    marker = [];

    orn_srate = 20; % Sampling rate of ORN data

    while read
        packet = parseBtPacket(fid);
        if ~isfield(packet, 'type')
            continue;
        end
        switch packet.type
            case 'orn'
                orn_data = cat(2, orn_data, packet.orn);
                orn_timestamp = cat(2, orn_timestamp, packet.timestamp);
            case { 'eeg4', 'eeg8' }
                exg_data = cat(2, exg_data, packet.data);
                exg_timestamp = cat(2, exg_timestamp, ...
                    repmat(packet.timestamp, 1, size(packet.data, 2)));
            case 'marker_event'
                marker = cat(1, marker, [packet.timestamp, floor(packet.code)]);
            case { 'env', 'ts', 'fw', 'dev_info', 'unimplemented' }
                continue; % do nothing
            otherwise
                read = 0; % end of stream
        end
    end

    % Event syncing - find the first timestamp that is close to the marker
    for i = 1:size(marker, 1)
        marker(i, 1) = find(exg_timestamp > marker(i, 1), 1);
    end

    sample_rate = getSamplingRate(exg_timestamp);

    % Convert to EEGLAB structure
    EEG = pop_importdata('dataformat', 'array', ...
        'nbchan', size(exg_data, 1), 'data', ...
        exg_data, 'setname', 'raw_eeg', 'srate', sample_rate, 'xmin', 0);
    EEG = eeg_checkset(EEG);
    EEG = pop_importevent( EEG, 'event', marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    EEG = eeg_checkset(EEG);
    
    ORN = pop_importdata('dataformat', 'array', 'nbchan', 9, 'data', ...
        orn_data, 'setname', 'raw_orn', 'srate', orn_srate, 'xmin', 0);
    ORN = eeg_checkset(ORN);
    ORN = pop_importevent(ORN, 'event', marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    ORN = eeg_checkset(ORN);
end
