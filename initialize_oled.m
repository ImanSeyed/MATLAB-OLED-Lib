function [oled,a] = initialize_oled(a, options)
% initialize_oled - Initialize and clean up SSD1315 OLED display
%
%  Syntax
%    [oled, a] = initialize_oled(a);
%    [oled, a] = initialize_oled(a, print_log=true);
%    [oled, a] = initialize_oled(a, print_log=true, i2c_address='0x3C');
%
%  Input Arguments
%    a - Arduino object (with or without I2C Library)
%    print_log - Log OLED status to Command Window
%      false (default) | true
%    i2c_address - I2C address of OLED display
%      '0x3C' (default) | character vector | string scalar
%
%  Output Arguments
%    oled - OLED I2C device object
%      I2C object
%
%    a - Arduino connection (after ensuring I2C library)
%      Arduino object

%   Copyright 2024 Aradhya Chawla
    
    arguments
        a (1,1) arduino
        options.print_log {mustBeNumericOrLogical} = false
        options.i2c_address {mustBeText} = '0x3C' 
    end
    
    print_log = options.print_log;
    i2c_address = options.i2c_address;

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
    if any(strcmp(input_check, i2c_address))
        if print_log == true
            disp('::: OLED Screen Found :::')
        end
    elseif ~any(strcmp(input_check, i2c_address))
        disp('::: OLED SCREEN NOT FOUND :::')
        return
    end
    
    % OLED Display I2C Object
    oled = device(a,'I2CAddress', i2c_address);
    
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
    display_write(oled, flair);
    pause(1);
    clear_display(oled);
    
    % Ready statement
    if print_log == true
        disp('::: OLED Display Initialized :::')
    end
end
