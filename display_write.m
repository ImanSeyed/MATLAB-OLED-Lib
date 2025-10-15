% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

function display_write(oled, column_start, column_end, page_start, ...
    page_end, font_scale, input_text)
% display_write - Write text on the display
%
%  Input Arguments
%    oled - OLED I2C device object
%      I2C object
%    column_start - Starting column
%      1 to 128
%    column_end - Ending column
%      1 to 128
%    page_start - Starting page (1 to 8)
%      1 to 8
%    page_end - Ending page
%      1 to 8
%    font_scale - Changes the dimensions of the output picture
%      1 | 2
%    input_text - Text to display on screen
%      character vector

    column_start = column_start - 1;
    column_end = column_end - 1;
    page_start = page_start - 1;
    page_end = page_end - 1;

    % Check if column starts and end points are correct
    if column_start > 127 || column_start < 0 || ...
            column_end > 127 || column_end < 0
        waitfor(msgbox("Invalid column_start and/or column_end values", ...
            "Error","error"));
    elseif column_end <= column_start
        waitfor(msgbox("column_end must be greater than column_start"));
        return
    end

    % Check if page start and end points are correct
    if page_start > 7 || page_start < 0 || page_end > 7 || page_end < 0
        waitfor(msgbox("Invalid page_start and/or page_end values", ...
            "Error","error"));
        return
    elseif page_end < page_start
        waitfor(msgbox("page_end must be greater than page_start"))
        return
    end

    % Check that supported font scale is requested
    if font_scale < 1
        waitfor(msgbox("font_scale cannot be less than 1","Error","error"));
        return
    elseif font_scale > 2
        waitfor(msgbox("font_scale greater than 2 is not supported", ...
            "Error","error"));
        return
    end

    % make sure input text is not empty
    if (sum(isstrprop(input_text,'alpha')) + ...
            sum(isstrprop(input_text,'digit'))) - ...
            sum(isstrprop(input_text,'wspace')) < 0 || ...
            strcmp(input_text,'')
        waitfor(msgbox("input_text cannot be empty","Error","error"));
        return
    end


    % Variables
    import_characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';
    space_char = 0;
    col_start = column_start;
    col_end = column_end;
    page_begin = page_start;
    page_endpoint = page_end;

    % Read and store characters
    % Generate and store binary version of character images
    for i = 1:length(import_characters)
        if import_characters(i) == ':'
            charread = imread('assets/characters/colon.png');
        else
            charread = imread('assets/characters/'+ ...
                string(import_characters(i))+'.png');
        end
        charread = rgb2gray(charread);
        [h,w] = size(charread);
        for x = 1:1:h
            for y = 1:1:w
                if charread(x,y) == 255
                    charout(x,y) = '1';
                else
                    charout(x,y) = '0';
                end
            end
        end
        Characters(:,:,i) = charread;
        Char_bin(:,:,i) = charout;
    end
    % Split and store larger scaled characters into equal 8x8 grids
    if font_scale > 1
        [~,~,page] = size(Characters);
        for i = 1:page
            scale_col_loc = 1;
            scale_row_loc = 1;
            sChars(:,:,i) = imresize(Characters(:,:,i), ...
                [h*font_scale w*font_scale],'nearest');
            [a_scaled, b_scaled] = size(sChars(:,:,i));
            
            for x = 1:8:a_scaled
                for y = 1:8:b_scaled
                    temp_mat = sChars(x:x+7,y:y+7,i);
                    for h = 1:height(temp_mat)
                        for l = 1:width(temp_mat)
                            if temp_mat(h,l) == 255
                                temp_binmat(h,l) = '1';
                            else
                                temp_binmat(h,l) = '0';
                            end
                        end
                    end
                    if scale_row_loc - 1 == font_scale
                        scale_row_loc = 1;
                        scale_col_loc = scale_col_loc + 1;
                    end
                    scaled_char{scale_row_loc,scale_col_loc,i}=temp_binmat;
                    scale_row_loc = scale_row_loc + 1;
                end
            end
        end
    end
    
    % Text to print to screen
    txt_to_print = upper(input_text);
    
    % Set column i2cAddress (from 0 - 127)
    write(oled, [0, hex2dec('21'), col_start, col_end]);
    % Set page i2cAddress (from 0 - 7)
    write(oled, [0, hex2dec('22'), page_begin, page_endpoint]);
    
    col_tracker = col_start;
    page_tracker = page_begin;
    
    % Begin printing
    for i = 1:length(txt_to_print)
        cId = strfind(import_characters,txt_to_print(i));
        % Handling larger font printing
        if font_scale > 1
            [row,col,~] = size(scaled_char(:,:,cId));
            for r = 1:row
                for c = 1:col
                    % If text has space
                    if isspace(txt_to_print(i)) == true
                        cId = space_char;
                        for j = 1:8
                            col_tracker = col_tracker + 1;
                            write(oled,[hex2dec('40'), cId])
                        end
                    else
                        q = flipud(scaled_char{c,r,cId});
                        q = q';
                        for k = 1:8
                            col_tracker = col_tracker + 1;
                            write(oled,[hex2dec('40'), ...
                                bin2dec(string(q(k,:)))])
                        end
                    end
                end
                % Track and set current column and page
                if r ~= row
                    col_tracker = col_start;
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                    page_tracker = page_tracker + 1;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                elseif r == row
                    page_tracker = page_begin;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                    col_start = col_tracker;
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                end
    
                if col_tracker == 128
                    page_tracker = page_begin + font_scale;
                    page_begin = page_tracker;
                    col_tracker = column_start;
                    col_start = column_start;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                end
    
            end
        % For standard size characters
        else
            if isspace(txt_to_print(i)) == true
                cId = space_char;
                for j = 1:8
                    col_tracker = col_tracker + 1;
                    write(oled,[hex2dec('40'), cId])
                end
            else
                cId = flipud(Char_bin(:,:,cId));
                cId = cId';
                for j = 1:8
                    col_tracker = col_tracker + 1;
                    write(oled,[hex2dec('40'), bin2dec(string(cId(j,:)))])
                end
            end
        end
    end
end
