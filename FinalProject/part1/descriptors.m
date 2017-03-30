function [ f , d ] = descriptors(I, type, step_size)
    % Type = 'dense', 'keypoints', 'RGBsift', 'rgbsift', 'Oppsift' 
    
    % Dense SIFT
    binSize = 8 ;
    magnif = 3 ;
    I = im2single(I);
    
    if strcmp(type,'dense')
        % Function vl_dsift and vl_sift to get 
        % dense and keypoins descriptors
        
        % Convert to grayscale and to single precision
        if size(I,3) > 1
            I_gray = rgb2gray(I);
        end
        I_gray = im2single(I_gray);
        
        % Smooth image
        Is = vl_imsmooth(I_gray, sqrt((binSize/magnif)^2 - .25));
        
        % Dense sampling
        [f, ~] = vl_dsift(Is, 'size', binSize, 'step', step_size) ;
        f(3,:) = binSize/magnif ;
        f(4,:) = 0 ;
        
        if size(I,3) == 1
            r = I(:,:);
            g = I(:,:);
            b = I(:,:);
        else
            r = I(:,:,1);
            g = I(:,:,2);
            b = I(:,:,3);
        end
        % Point sampling
        [~ , d1] = vl_sift(single(r), 'frames', f);
        [~ , d2] = vl_sift(single(g), 'frames', f);
        [~ , d3] = vl_sift(single(b), 'frames', f);
        d = [d1';d2';d3'];
        d = d';
        
        
        
    end
    
    % Point SIFT
    if strcmp(type,'keypoints')
        
        % Convert to grayscale
        if size(I,3) >1
            I = rgb2gray(I);
        end

        [f, ~] = vl_sift(I);
        if size(I,3) == 1
            r = I(:,:);
            g = I(:,:);
            b = I(:,:);
        else
            r = I(:,:,1);
            g = I(:,:,2);
            b = I(:,:,3);
        end
        % Point sampling
        [~ , d1] = vl_sift(single(r), 'frames', f);
        [~ , d2] = vl_sift(single(g), 'frames', f);
        [~ , d3] = vl_sift(single(b), 'frames', f);
        d = [d1';d2';d3'];
        d = d';
        
        
        
    end

    % RGB SIFT
    if strcmp(type,'RGBSIFT')
        [f,d] = vl_phow(I,'color','rgb','step', step_size);
    end
    
    % rgb SIFT
    if strcmp(type,'rgbSIFT')
        if size(I,3) == 1
            r = I(:,:);
            g = I(:,:);
            b = I(:,:);
        else
            r = I(:,:,1);
            g = I(:,:,2);
            b = I(:,:,3);
        end
        
        [a1,b1] = size(r);
        
        sumrgb = r + g + b;
        r = double(r) ./ double(sumrgb);
        g = double(g) ./ double(sumrgb);
        b = double(b) ./ double(sumrgb);
        
        normImage = zeros(a1, b1, 3 );

        normImage(:,:,1) = r ;
        normImage(:,:,2) = g ;
        normImage(:,:,3) = b ;
        
        normImage = im2single(normImage);
        
        [~ , d1] = vl_sift(normImage(:,:,1));
        [~ , d2] = vl_sift(normImage(:,:,2));
        [~ , d3] = vl_sift(normImage(:,:,3));
        d = [d1';d2';d3'];
        d = d';
        f = 0;
    end

    % Opponent SIFT
    if strcmp(type,'opponent')
        [f,d] = vl_phow(I,'color','opponent', 'step', step_size);
    end

    

end

