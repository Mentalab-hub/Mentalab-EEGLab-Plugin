function [EEG, ORN, com] = loadbin(filepath, varargin)
    com = '';

    fid = fopen(filepath);
    read = 1;
    orn_data = [];
    orn_timestamp = [];
    exg_data = [];
    exg_timestamp = [];
    marker = [];
    sr = 0;

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
            case 'dev_info'
                adc_mask = reverse(packet.adc_mask);
                sr = packet.data_rate;
            case { 'unimplemented' }
                continue; % do nothing
            otherwise
                read = 0; % end of stream
        end
    end

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

    if sr == 0
        sr = getSamplingRate(exg_timestamp);
    end

    no_chan = size(exg_data, 1);
    eeg_ch_names = cell(1, no_chan);
    for i = 1:size(adc_mask, 2)
        if (str2num(adc_mask(i)) == 1) % If channel is on, add it
            eeg_ch_names(i) = {['Ch' num2str(i)]};
        end
    end

    eeg_chanlocs = struct('labels', eeg_ch_names);

    % Convert to EEGLAB structure
    EEG = pop_importdata('dataformat', 'array', 'nbchan', no_chan, 'data', ...
        exg_data, 'setname', 'raw_eeg', 'srate', sr, 'xmin', 0, ...
        'chanlocs', eeg_chanlocs);
    EEG = eeg_checkset(EEG);
    EEG = pop_importevent(EEG, 'event', eeg_marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    EEG = eeg_checkset(EEG);
    
    ORN = pop_importdata('dataformat', 'array', 'nbchan', 9, 'data', ...
        orn_data, 'setname', 'raw_orn', 'srate', orn_srate, 'xmin', 0);
    ORN = eeg_checkset(ORN);
    ORN = pop_importevent(ORN, 'event', orn_marker, 'fields', ...
        {'latency', 'type'}, 'timeunit', NaN);
    ORN = eeg_checkset(ORN);
end
