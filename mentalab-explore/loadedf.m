function [EEG, ORN, com] = loadedf(filepath, varargin)
    com = '';
    EEG = [];
    EEG = eeg_emptyset;

    ORN = [];
    ORN = eeg_emptyset;

    dat = openbdf(filepath);
    dat.Head.NRec = 100;
    
    blockrange = [1 dat.Head.NRec];
    
    vectrange = [blockrange(1):min(blockrange(2), dat.Head.NRec)];
    DAT=readbdf(dat, vectrange);
    
    all_channel_items = cellstr(dat.Head.Label);
    locations = {};

    if(contains(filepath,'.bdf'))
        for i = 2:length(all_channel_items) -1
            locations{i-1} = all_channel_items{i};
        end
    else
        for i = 1:length(all_channel_items) -1
            locations{i} = all_channel_items{i};
        end
    end

    eeg_chanlocs = struct('labels', locations);

    if(contains(filepath,'.bdf'))
        voltage_data = DAT.Record(2:end-1,:);
        channel_number = size(DAT.Record,1) - 2;
    else
        voltage_data = DAT.Record(1:end-1,:);
        channel_number = size(DAT.Record,1) -1;
    end
    
%     EEG.nbchan          = size(DAT.Record,1) - 2;
%     EEG.srate           = dat.Head.SampleRate(1);
%     EEG.data            = DAT.Record(2:end-1,:);
%     EEG.pnts            = size(EEG.data,2);
%     EEG.trials          = 1;
%     EEG.setname 		= 'BDF file';
%     disp('Event information might be encoded in the last channel');
%     disp('To extract these events, use menu File > Import event info > From data channel'); 
%     EEG.filename        = filename;
%     EEG.filepath        = '';
%     EEG.xmin            = 0; 
%     EEG.chanlocs        = eeg_chanlocs;
    

    EEG = pop_importdata('dataformat', 'array', 'nbchan', ...
        channel_number, 'data', voltage_data, 'setname', 'raw_eeg', ...
        'srate', dat.Head.SampleRate(1), 'xmin', 0, 'chanlocs', eeg_chanlocs);
    EEG = eeg_checkset(EEG);
end



    