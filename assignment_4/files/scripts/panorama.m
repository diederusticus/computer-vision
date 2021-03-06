function [stitch_divided, stitch_maximum] = panorama(im1, im2, parameters)
    
    % Putting the parameters in a 3x3 matrix
    parameters =    [parameters(1) parameters(3) 0;
                    parameters(2) parameters(4) 0;
                    parameters(5) parameters(6) 1];

    % Create the object for the imwarp function
    affineT = affine2d(parameters);
    
    % From piazza: we can use imwarp to speed up the transformation
    % process, instead of using the for loops
    t_image = imwarp(im2 , affineT);

    % Defining the (x,y,z) coordinates of the corners
    corners =       [1 1 1 ; 
                    1 size(im2, 1) 1 ;
                    size(im2, 2) 1 1;
                    size(im2, 2) size(im2, 1) 1];
          
    % Transforming the corners
    t_corners = corners * parameters;
    
    % Extract the end points of the future transformed image. We only 
    % need the x-direction of the top-left corner (TL) and the y-direction
    % of the top-right corner (TR)
    TL = min(t_corners(:, 1));
    TR = min(t_corners(:, 2));

    % Calculating the shifts for linearly translating the images based on
    % the two corners
    left_x = 0;
    left_y = 0;
    right_x = 0;
    right_y = 0;

    if TL < 1
        left_x = abs(TL) + 1;
    end

    if TL > 1
        right_x = TL - 1;
    end
    
    if TR < 1
        left_y = abs(TR) + 1;
    end
    
    if TR > 1
        right_y = TR - 1;
    end

    % Inbuild function to translate the images according to the shifts
    shifted_left = imtranslate(im1, [left_x, left_y], 'OutputView', 'full');
    shifted_right = imtranslate(t_image, [right_x, right_y], 'OutputView', 'full');

    % Adding zero-padding with inbuild function padarray 
    % We need padding because our image sizes are not same as the size of
    % the final stitched image

    pad_left_x = 0;
    pad_left_y = 0;
    pad_right_x = 0;
    pad_right_y = 0;

    if size(shifted_right,1) - size(shifted_left,1) > 0
        pad_left_x = size(shifted_right,1) - size(shifted_left,1);
    else
        pad_right_x = size(shifted_left,1) - size(shifted_right,1) ;
    end
    
    if size(shifted_right,2) - size(shifted_left,2) > 0
        pad_left_y = size(shifted_right,2) - size(shifted_left,2);
    else
        pad_right_y = size(shifted_left,2) - size(shifted_right,2) ;
    end

    left_padded = padarray(shifted_left,[pad_left_x,pad_left_y],0,'post');
    right_padded = padarray(shifted_right,[pad_right_x,pad_right_y],0,'post');
    
    % One method could be to divide every pixel by 2. However, this results
    % in darker non-overlapping parts
    stitch_divided =  (left_padded/2 + right_padded/2);

    % The other method is to get the maximum value. So the pixels 
    % in the overlapping area will be based either on the left image or on
    % the right image
    stitch_maximum = max(left_padded,right_padded);
end

