% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

clearvars;
addpath(fileparts(fileparts(mfilename('fullpath'))));

try
    a = auto_connect_arduino();
    
    % Initialize explicitly
    % a = arduino(port, ...);
catch ME
    error([ME.identifier, ': ', ME.message ...
        ' Explicitly initialize the Arduino object.']);
end

% Initialize OLED device
oled = initialize_oled(a);

% Include every supported character
test_string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';

% Test writing on the screen
display_write(oled, test_string)
pause(5);

clear_display(oled);
