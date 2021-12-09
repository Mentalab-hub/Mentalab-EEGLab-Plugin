function [EEG, com] = pop_loadfile(filepath, varargin)  
    com = '';

    if nargin > 0  % File provided in call
        runMain(filepath)
        return;
    end

    [filename, path] = getFileFromUser();
    [EEG, com] = runMain([path, filename]);
end


function [EEG, com] = runMain(filepath)
    [directory, filename, ext] = fileparts(filepath);
    if (contains(ext, 'csv'))
        checkFolderContents(filename, directory);
    end
    sampling_rate = getSamplingRate();
    [EEG, com] = loadBINCSV(filepath, sampling_rate, ext);
end


function [filename, path] = getFileFromUser() 
    [filename, path] = uigetfile({'*.BIN;*.CSV;' 'All BIN and CSV files';}, ...
        'Select a BIN or CSV file'); 
    if filename == 0
        error('---> File selection cancelled.')
    end

    if (~contains(filename, '_ExG.csv', 'IgnoreCase', true) ...
            && ~contains(filename, '_ORN.csv', 'IgnoreCase', true) ...
            && ~contains(filename, '_Marker.csv', 'IgnoreCase', true) ...
            && ~contains(filename, '.bin', 'IgnoreCase', true)) 
        error(['---> Error on: "' filename '". Unsuitable file type.' ...
            ' Please select a BIN file or CSV file with suffix "_ExG", "_ORN" or "_Marker".'])
    end
end


function [EEG, com] = loadBINCSV(filepath, sampling_rate, ext)
    if (contains(ext, "bin", 'IgnoreCase', true))
        error(['---> Binary data not currently supported - we' char(39) 're working on it!'])
        %loadbin(filepath);
    end

    [EEG, com] = loadcsv(filepath, sampling_rate);
end


function checkFolderContents(filename, directory) % Will be CSV file
    filename_split = split(filename, "_");
    name = char(filename_split(1));

    exg_orn_marker = false(1, 3);
    files = dir(directory);
    for i = 1:length(files)
        file_i = files(i).name;
        if (contains(file_i, [name '_ExG.csv']))
            exg_orn_marker(1) = true;
        elseif (contains(file_i, [name '_ORN.csv']))
            exg_orn_marker(2) = true;
        elseif (contains(file_i, [name '_Marker.csv']))
            exg_orn_marker(3) = true;
        end
    end

    if (~exg_orn_marker(1))
        error(['---> Selected directory does not contain: ' name '_ExG.csv.'])
    end
    if (~exg_orn_marker(2))
         error(['---> Selected directory does not contain: ' name '_ORN.csv.'])
    end
    if (~exg_orn_marker(3))
         error(['---> Selected directory does not contain: ' name '_Marker.csv.'])
    end
end


function sampling_rate = getSamplingRate()
    sampling_rate = inputgui( 'geometry', { [1 1] }, ... % Get the sampling rate from the user
        'geomvert', [3], 'uilist', { ...
        { 'style', 'text', 'string', [ 'Sampling rate:' 10 10 10 ] }, ...
        { 'style', 'popupmenu', 'string', '250 Hz|500 Hz|1k Hz' } } );

   if (isequal(sampling_rate, {[1]})) % First option... etc.
       sampling_rate = 250;
   elseif (isequal(sampling_rate, {[2]})) 
       sampling_rate = 500;
   elseif (isequal(sampling_rate, {[3]})) 
       sampling_rate = 1000;
   elseif (isempty(sampling_rate))
        error('---> Please select a sampling rate to proceed.')
    end
end
