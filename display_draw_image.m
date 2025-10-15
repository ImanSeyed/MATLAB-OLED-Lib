function display_draw_image(oled, imagePath, minThreshold, maxThreshold)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Draw an image on the display
% Author: Aradhya Chawla
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FUNCTION
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Draws image on the display
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% oled : oled device object
% imagePath : load sample or provide path to image
% minThreshold : minimum (black) threshold of image
% maxThreshold : maximum (white) threshold of image
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % maximum threshold must always be larger than minimum threshold
    if maxThreshold <= minThreshold
        waitfor(msgbox("Maximum threshold must be greater than the minimum " + ...
            "threshold","Error","error"));
        return
    end

    % Loading image
    if strcmp(imagePath, 'sample')
        % Photo by Helena Lopes from Pexels: 
        % https://www.pexels.com/photo/white-horse-on-green-grass-1996333/
        image = imread('assets/images/sample.png');
    else
        try
            image = imread(imagePath);
        catch ME
            msgbox(["File does not exist or"; "Invalid file path"], ...
                'Error', 'error')
            return
        end
    end

    % Convert to grayscale for monochromatic display
    bwImage = rgb2gray(image);

    % Get picture height and width
    [pH,pW] = size(bwImage);

    % Defining screen dimensions
    screen_height = 64;
    screen_width = 128;

    % Get picture height to screen height ratio
    pHS_ratio = pH/screen_height;
    % Get picture width to screen width ratio
    pWS_ratio = pW/screen_width;

    % Determine and proceed to scale along the largest dimension
    if pHS_ratio > pWS_ratio
        c = 1;
        image_resized = imresize(bwImage,[screen_height,NaN]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = floor((screen_width - pWr)/2);
        wrRemainder = ceil((screen_width - pWr)/2);
        hlRemainder = '0';
        hrRemainder = '0';
    elseif pHS_ratio < pWS_ratio
        c = 2;
        image_resized = imresize(bwImage,[NaN,screen_width]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = '0';
        wrRemainder = '0';
        hlRemainder = floor((screen_height - pHr)/2);
        hrRemainder = ceil((screen_height - pHr)/2);
    else
        c = 3;
        image_resized = imresize(bwImage,[screen_height,screen_width]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = floor((screen_width - pWr)/2);
        wrRemainder = ceil((screen_width - pWr)/2);
        hlRemainder = floor((screen_height - pHr)/2);
        hrRemainder = ceil((screen_height - pHr)/2);
    end
    
    % Converting to binary matrix
    thresholds = [minThreshold maxThreshold];
    
    for i = 1:pHr
        for j = 1:pWr
            if image_resized(i,j) < thresholds(2) && ...
                    image_resized(i,j) > thresholds(1)
                binImage(i,j) = '0';
            else
                binImage(i,j) = '1';
            end
        end
    end
    
    % Filling in gaps
    f1 = repmat(hlRemainder,pHr,wlRemainder);
    f2 = repmat(hrRemainder,pHr,wrRemainder);
    if c == 1
        final_image = [f1 binImage f2];
    elseif c == 2
        final_image = [f1;binImage;f2];
    else
        final_image = binImage;
    end
    temp_Count = 1;
    for i = 1:8:64
        image_rows(:,:,temp_Count) = final_image(i:i+7,:);
        temp_Count = temp_Count + 1;
    end
    temp_Count = 1;
    for i = 1:8
        temp_mat = image_rows(:,:,i);
        for j = 1:8:128
            image_matrix(:,:,temp_Count) = temp_mat(:,j:j+7);
            temp_Count = temp_Count + 1;
        end
    end
    
    % Set column i2cAddress
    write(oled, [hex2dec('00'), hex2dec('21'), 0, 127]);
    % Set page i2cAddress
    write(oled, [hex2dec('00'), hex2dec('22'), 0, 7]);
    
    % Draw to screen
    for i = 1:128
        temp_mat = flipud(image_matrix(:,:,i));
        temp_mat = temp_mat';
        for j = 1:8
            write(oled,[hex2dec('40'), bin2dec(string(temp_mat(j,:)))])
        end
    end
end
