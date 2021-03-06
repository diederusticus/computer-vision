% Tushar Nimbhorkar & Diede Rusticus
% Computer Vision '17
% Artificial Intelligence Master
% University of Amsterdam

clear 
close all

%%%%%%%%% Select assignment and image by uncommenting the line %%%%%%%%%

% test = 'image_alignment';
test = 'image_stitching';

%%%%%%%%% 3.1 Image Alignment %%%%%%%%%

if (strcmp(test,'image_alignment'))
    
    im1 = imread('../boat1.pgm');
    im2 = imread('../boat2.pgm');
    [trans_params, ~, x, x_tf, y, y_tf] = image_alignment(im1, im2, 10, 3);
    m = reshape(trans_params(1:4),[2 2]);
    m = m';
    t = trans_params(5:6);
    [t_image] = transform(im1, m, t);
    
    % In build function
    a = [m';t'];
    result = [a';0,0,1]';
    trans = maketform('affine',result);
    newImage = imtransform(im1,trans);
    
    % Plot: with arrows between matches
    figure(1);
    doublefigure = cat(2, im1, im2);
    imshow(doublefigure)
    xa = x;
    xb = x_tf + size(im1,2);
    ya = y;
    yb = y_tf;
    hold on;
    h = line([xa ; xb], [ya ; yb]) ;
    set(h,'linewidth', 1, 'color', 'g') ;
    plot(xa, ya, 'o', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 2)
    plot(xb, yb, 'o', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 2) 
    title('Matched points with arrows in between');

    % Plot: Final result comparison
    figure(2)
    subplot(2,2,1)
    imshow(im1)
    title('Original image');
    subplot(2,2,2)
    imshow(t_image,[]);
    title('Custom image transform');
    subplot(2,2,3)
    imshow(im2);
    title('Goal rotation');
    subplot(2,2,4);
    imshow(newImage,[]);
    title('Built in matlab function');
end

if (strcmp(test,'image_stitching'))
    
    im1 = imread('../left.jpg');
    im2 = imread('../right.jpg');
    [trans_params, ~,~,~,~,~] = image_alignment(im2, im1, 10, 3);
    [stitch_divided, stitch_maximum] = panorama(im1,im2,trans_params);
    
    % Plot the images stiched
    figure;
    subplot(1,2,1)
    imshow(stitch_divided,[])
    title('Pixels are divided by 2');
    subplot(1,2,2)
    imshow(stitch_maximum,[])
    title('Pixels are the maximum of the images');
    
    
end
