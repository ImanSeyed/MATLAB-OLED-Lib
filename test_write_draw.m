% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Tests to ensure correct functionality of drawing and writing operations
% of library
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%clear all; close all; clc

% Get Arduino object (define port and board type if more than one
% connected)
%a = arduino;

% Initialize OLED device
%[oled,a] = initialize_oled(a,0);

% Constants
testString = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';
% 
% Expected input for writing text
%display_write(oled, 1, 128, 1, 8, 1, testString)
%clear_display(oled);
%pause(3);
% Expected input for drawing sample image
display_write(oled, 'sample', 10, 100)
clear_display(oled);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TESTING FOR WRITING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % wrong clear_display value --> expected error message
% display_write(oled, 1, 128, 1, 8, 1, testString)
% 
% % incorrect column start value --> expected error message
% display_write(oled, 0, 128, 1, 8, 1, testString)
% 
% % incorrect column end value --> expected error message
% display_write(oled, 1, 129, 1, 8, 1, testString)
%
% % incorrect column end value --> expected error message
% display_write(oled, 1, 0, 1, 8, 1, testString)
% 
% % incorrect column start and end value --> expected error message
% display_write(oled, 13, 1, 1, 8, 1, testString)
% 
% % incorrect page start value --> expected error message
% display_write(oled, 1, 128, 0, 8, 1, testString)
% 
% % incorrect page end value --> expected error message
% display_write(oled, 1, 129, 1, 9, 1, testString)
% 
% % incorrect page start and end value --> expected error message
% display_write(oled, 1, 129, 8, 1, 1, testString)
% 
% % fontscale value less than 1 --> expected error message
%  display_write(oled, 1, 128, 1, 8, 0, testString)
% 
% % fontscale value greater than 2 --> expected error message
%  display_write(oled, 1, 128, 1, 8, 3, testString)
% 
% % empty input text --> expected error message
%  display_write(oled, 1, 128, 1, 8, 1, '')
% 
% % input text with spaces only --> expected error message
%  display_write(oled, 1, 128, 1, 8, 1, '   ')
% 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TESTING FOR DRAWING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% % Incorrect image path --> expected error message
% display_draw_image(oled, 'asdasf/xyz.jpg', 10, 100)
% 
% % Incorrect thresholds --> expected error message
% display_draw_image(oled, 'sample', 100, 10)
