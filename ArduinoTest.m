% Delete all current serial ports in use
delete(serialportfind);

% Search for all available serial ports
serialportlist("available");

% Connect to the Arduino Due by creating a serialport object. Use the port and baud specified in the Arduino code.
serialObj = serialport("COM3", 9600);

% Configure the serialport object by configuring its properties and clearing old data.
configureTerminator(serialObj, "CR/LF");

% Flush the serialport object to remove any old data.
flush(serialObj);

% Prepare the UserData property to store the Arduino data.
serialObj.UserData = struct("Data", [], "Count", 1);

% Configure callback to read data
configureCallback(serialObj, "terminator", @(src, event) readData(src, event));

% Inform user how to stop the reading
disp('Type "STOP" and press Enter to stop reading...');

% Loop to check for user input
while true
    userInput = input('', 's'); % Read user input as a string
    if strcmpi(userInput, 'STOP') % Check if the input is 'STOP'
        disp('Stopping data collection.');
        configureCallback(serialObj, "off"); % Stop reading data
        break; % Exit the loop
    end
end
%%
function readData(src, ~)
    % Read the ASCII data from the serialport object.
    data = readline(src);

    % Check if the received data is the stop command
    % You can keep this in case you send "STOP" from Arduino
    if strcmp(data, 'STOP')
        configureCallback(src, "off"); % Stop reading data
        disp('Received STOP command. Stopping data collection.');
        return; % Exit the function
    end

    % Convert the string data to numeric type and save it in the UserData property
    src.UserData.Data(end + 1) = str2double(data);

    % Update the Count value of the serialport object
    src.UserData.Count = src.UserData.Count + 1;

    % Output the latest button press state to the command window
    fprintf('Latest Button Press State: %f\n', src.UserData.Data(end));
end