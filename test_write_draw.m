% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Tests to ensure correct functionality of drawing and writing operations
% of library
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clearvars;

% Find any available and connected serial ports
available_ports = serialportlist("available");

% Check if at least one port is available before attempting to connect
if ~isempty(available_ports)
    % Assume the last available port corresponds to the Arduino device
    port = available_ports(end);
    a = arduino(port);
else
    error('No available serial ports found. Please connect your Arduino and try again.');
end

% Initialize OLED device
[oled, a] = initialize_oled(a);

% Include every supported character
test_string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';

% Test writing on the screen
display_write(oled, test_string)
pause(5);

clear_display(oled);

% Test drawing an image on the screen
display_draw_image(oled, path="assets/images/sample.png");
pause(5);

clear_display(oled);
