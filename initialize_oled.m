% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

function [oled,a] = initialize_oled(a, print_ready, varargin)
% initialize_oled - Initialize and clean up SSD1315 OLED display
%
%  Syntax
%    [oled, a] = initialize_oled(a, print_ready)
%    [oled, a] = initialize_oled(a, print_ready, i2cAddress)
%
%  Input Arguments
%    a - Arduino object (with or without I2C Library)
%    print_ready - Print status to Command Window
%      logical scalar
%
%  Optional Input
%    i2cAddress - I2C address of OLED display
%      '0x3C' (default) | character vector | string scalar
%
%  Output Arguments
%    oled - OLED I2C device object
%      I2C object
%
%    a - Arduino connection (after ensuring I2C library)
%      Arduino object

% Checks re-initializes arduino object 
% if it is not initalized with I2C Library
if ~ismember('I2C',a.Libraries)
    port = a.Port;            % given arduino port
    board = a.Board;          % given arduino board
    libs = a.Libraries;       % Libraries of given arduino object
    disp('::: Re-initializing Arduino with I2C Library :::');
    evalin("base",'clear a')  % clears arduino object in base workspace
    clear a;                  % clears arduino object in function
    a = arduino(port,board,'libraries',{libs{1,1}, libs{1,2}, 'I2C'});
end

% Scans for I2C Devices
input_check = scanI2CBus(a,0);

% Checks if OLED Screen is attached
if nargin == 3
    i2cAddress = varargin{1};
    if any(strcmp(input_check, i2cAddress))
        if print_ready == true
            disp('::: OLED Screen Found :::')
        end
    elseif ~any(strcmp(input_check, i2cAddress))
        disp('::: OLED SCREEN NOT FOUND :::')
        return
    end
elseif nargin > 3
    msgbox("ERROR: Too many inputs","Error","error")
    return
else
    i2cAddress = '0x3C';
    if any(strcmp(input_check, i2cAddress))
        if print_ready == true
            disp('::: OLED Screen Found :::')
        end
    elseif ~any(strcmp(input_check, i2cAddress))
        disp('::: OLED SCREEN NOT FOUND :::')
        return
    end
end

% OLED Display I2C Object
oled = device(a,'I2CAddress', i2cAddress);

% Display initialization
% Turn off the display
write(oled, [hex2dec('00'), hex2dec('AE')]);
% Set memory mode
write(oled, [hex2dec('00'), hex2dec('20'), hex2dec('00')]);
% Set column address
write(oled, [hex2dec('00'), hex2dec('21'), hex2dec('00'), hex2dec('7F')]);
% Set page address
write(oled, [hex2dec('00'), hex2dec('22'), hex2dec('00'), hex2dec('07')]);
% Set contrast control
write(oled, [hex2dec('00'), hex2dec('81'), hex2dec('FF')]);
write(oled, [hex2dec('00'), hex2dec('C0')]); % Set scan direction
write(oled, [hex2dec('00'), hex2dec('A0')]); % Set segment remap
write(oled, [hex2dec('00'), hex2dec('A6')]); % Set normal display
write(oled, [hex2dec('00'), hex2dec('40')]); % Set display start line
% Enable charge pump regulator
write(oled, [hex2dec('00'), hex2dec('8D'), hex2dec('14')]);
pause(0.1);
write(oled, [hex2dec('00'), hex2dec('AF')]); % Turn on the display

% Clear garbage data, show startup flair, clear display
flair = '---------------- MATLAB OLED LIB ARADHYA CHAWLA ----------------';
clear_display(oled);
display_write(oled,1,128,1,8,1,flair);
pause(1);
clear_display(oled);

% Ready statement
if print_ready == true
    disp('::: OLED Display Initialized :::')
end
end
