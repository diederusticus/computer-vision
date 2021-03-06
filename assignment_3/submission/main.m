% Tushar Nimbhorkar & Diede Rusticus
% Computer Vision '17
% Artificial Intelligence Master
% University of Amsterdam

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Select assignment and image by uncommenting the line %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. choose which part of the task you want to execute ('harris', 'lucas', 'tracking')
% 2. for part 3.1 and 3.4 select either 'toy' or 'pingpong'
% 3. for part 3.3 select either 'syn' and 'sphere'

% test = 'harris';
test = 'lucas';
% test = 'tracking';

image_1_4 = 'toy';
% image_1_4 = 'pingpong';

% imgage_3 = 'syn';
imgage_3 = 'sphere';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Global variables %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(image_1_4, 'toy')
    region_size = 15;
    sigma = 3;
    kernel_size = 13;
    threshold = 200;
    window_size = 19;
    
elseif strcmp(image_1_4, 'pingpong')
    region_size = 15;
    sigma = 3;
    kernel_size = 17;
    threshold = 3000;
    window_size = 19;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% 3.1 Harris Corner Detector %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(test,'harris'))

    if (strcmp(image_1_4,'toy'))
    
        I = imread('../person_toy/00000001.jpg');
        [H,r,c,smoothed_image_x,smoothed_image_y] = harris_corner_detector(I, sigma, kernel_size, threshold, window_size);
        
    elseif(strcmp(image_1_4,'pingpong'))
    
        I = imread('../pingpong/0000.jpeg');
        [H,r,c,smoothed_image_x,smoothed_image_y] = harris_corner_detector(I, sigma, kernel_size, threshold, window_size);
        
    end

    % plots
    figure;
    subplot(1,3,1)
    imshow(smoothed_image_x)
    title('Derivative in X direction')
    subplot(1,3,2)
    imshow(smoothed_image_y)
    title('Derivative in Y direction')
    
    subplot(1,3,3)
    imshow(I)
    hold on;
    plot(c,r,'r.','MarkerSize',15)
    title('original image with Corners')
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% 3.2 - 3.3 Lucas-Kanade %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(test,'lucas'))

    if (strcmp(imgage_3,'syn'))
        img1 = imread('../synth1.pgm');
        img2 = imread('../synth2.pgm');
    elseif (strcmp(imgage_3,'sphere'))
        img1 = imread('../sphere1.ppm');
        img2 = imread('../sphere2.ppm');
    end
    
    % creating the centres for the window. This is beacuse we will take
    % corners from the harris-corner method for the tracking.
    
    M = zeros(floor(size(img1,1)/region_size)*floor(size(img1,2)/region_size),2);
    
    M_point_r = floor(region_size/2) +1 : region_size : size(img1,1)-1; % -1 because we dont want the last one index goes out of bound
    M_point_c = floor(region_size/2) +1 : region_size : size(img1,2)-1;
    
    i = 1; % keeps track of the index in M of the to-be-defined coordinates
    for j = M_point_r
        for k = M_point_c
            M(i,1) = j;
            M(i,2) = k;
            i = i + 1;
        end
    end    
    
    % computing the optical flow with lucas-kanade. 
    % u = horizontal velocity, v = vertical velocity        
    [u, v] = lk(region_size, img1, img2, M);
    
    % show results
    figure;
    axis equal
    imshow(img1);
    hold on
    q=quiver(M(:,2) , M(:,1), u' , v');
    q.Color = 'red';

    % set titles
    if (strcmp(imgage_3,'syn'))
        title('Synth with optical flow')
    elseif(strcmp(imgage_3,'sphere'))
        title('Sphere with optical flow')
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% 3.4 Tracking %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if (strcmp(test,'tracking'))

    % set scale factor in x direction (same for person_toy and pingpong)
    S1 = 2.9;
    
    if strcmp(image_1_4, 'toy')
    
        % amount of frames in video
        nr_images = 103;
        
        % Getting the corners of the fist image/frame
        [~,r,c,~,~] = harris_corner_detector(imread('../person_toy/00000001.jpg'), sigma, kernel_size, threshold, window_size);
        
        % scale factor in y direction
        S2 = 1.2;
        
    elseif strcmp(image_1_4, 'pingpong')
    
        % amount of frames in video
        nr_images = 53;
        
        % Getting the corners of the fist image/frame
        [~,r,c,~,~] = harris_corner_detector(imread('../pingpong/0000.jpeg'), sigma, kernel_size, threshold, window_size);
        
        % scale factor in y direction
        S2 = 1.5;
        
    end

    % Putting the coordinates of the corners into a matrix c
    C = [r c];
    
    % for every image in the folder
    for i = 1:nr_images
        if strcmp(image_1_4, 'toy')
            img1 = imread(['../person_toy/00000' num2str(i,'%03d') '.jpg']);
            img2 = imread(['../person_toy/00000' num2str(i+1,'%03d') '.jpg']);
        elseif strcmp(image_1_4, 'pingpong')
            img1 = imread(['../pingpong/00' num2str(i-1,'%02d') '.jpeg']);
            img2 = imread(['../pingpong/00' num2str(i,'%02d') '.jpeg']);
        end
        
        % Getting the optical flow arrows with Lucas-Kanade
        [u, v] = lk(region_size, img1, img2, C);
        
        % plots
        fig = figure(i);   
        axis equal
        imshow(rgb2gray(img1))
        hold on;
        
        q = quiver(C(:,2),C(:,1),u',v');
        q.Color = 'red';
        q.LineWidth = 1;
        hold on;
        
        plot(C(:,2),C(:,1),'r.','MarkerSize',15)
        n_f = ['new1/' num2str(i) '.png'];
        saveas(fig,n_f)
        pause(0.8);
        close(fig)

        % Getting the corners based on previous opical flow
        C(:,1) = int16(C(:,1)) + int16(S1 * v');
        C(:,2) = int16(C(:,2)) + int16(S2 * u');
        
    end
end

    
    
    
