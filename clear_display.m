% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

function clear_display(oled)
% clear_display - Clear the entire OLED display
%
%  Input Arguments
%    oled - OLED I2C device object
%      I2C object

% Set column i2cAddress
write(oled, [hex2dec('00'), hex2dec('21'), hex2dec('00'), hex2dec('7F')]); 
% Set page i2cAddress
write(oled, [hex2dec('00'), hex2dec('22'), hex2dec('00'), hex2dec('07')]); 
for i = 1:9*8
    write(oled,[hex2dec('40'),uint64(0)]);
end
end
