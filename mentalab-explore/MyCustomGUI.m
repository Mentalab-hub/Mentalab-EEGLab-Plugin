function [channelNameList] = MyCustomGUI(channelCount, prompt_i, definput_i)
    % Create a figure window
    fig = figure('Name', 'Dynamic UI Example', 'Position', [100, 100, 700, 700]);
    
    % Create a scrollable panel to hold the UI components
    scrollPanel = uipanel('Parent', fig, 'Position', [0.1, 0.1, 0.8, 0.8], 'Units', 'normalized');
    
    % Create a button to add rows
    addBtn = uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'OK',...
        'Position', [150, 20, 100, 30], 'Callback', @exitTable);
    
    % Create a uitable
    table = uitable('Parent', scrollPanel, 'Position', [10, 10, 380, 280]);
    
    % Initialize the table data
    data = {}; % Initial row
    colNames = {'Channel Number', 'Name'};
    colEditable = [false, true]; 
    
    % Set the table data and properties
    table.Data = data;
    table.ColumnName = colNames;
    table.ColumnEditable = colEditable;
    table.CellEditCallback = @editField;

    channelNameList = {};

    addTable();
    waitfor(fig);
    
    % Callback function for the 'Add Row' button
    function exitTable(~, ~)
        % Add an empty row to the table
        extractNames();
        disp(['...............................']);
        assignin('base', 'chn', channelNameList);
        close(fig, "hidden");
    end

        % Callback function for the 'Add Row' button
    function addTable(~, ~)
         for i = 1:channelCount
              data = [data; prompt_i(i), definput_i(i)];
              table.Data = data;
         end
       
    end

     % Callback function for editing the 'Field' column
    function editField(~, eventdata)
        % Check if the edited cell is in the 'Field' column
        if eventdata.Indices(2) == 1
            % Get the edited value
            editedValue = eventdata.EditData;
            
            % Update the data with the edited value
            data(eventdata.Indices(1), eventdata.Indices(2)) = {editedValue};
        end
    end
    
    function extractNames(~, ~)
     for i = 1:channelCount
          channelNameList(i) = table.Data(i, 2);
     end
    end
end
