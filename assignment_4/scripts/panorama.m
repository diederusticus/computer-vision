function [ imOut ] = panorama( I1,I2,parameter)


if size(I1,3) > 1
        disp('hello')
        I1 = rgb2gray(I1);
        I2 = rgb2gray(I2);
end
parameter = [parameter(1) parameter(3) 0;
    parameter(2) parameter(4) 0;
    parameter(5) parameter(6) 1];

affineT = affine2d(parameter);
% from piazza: we can use imwarp to speed up the transformation process
% instead of using the multiple for loops

t_image = imwarp(I2 , affineT);

corners = [1 1 1 ; 
    1 size(I2, 1) 1 ;
    size(I2, 2) 1 1;
    size(I2, 2) size(I2, 1) 1];
% transforming the corners
t_corners = corners * parameter;
% extract the end points
LC = min(t_corners(:, 1));
TC = min(t_corners(:, 2));
%only need left corner and top corner


% disp('hello')
% disp(LC)
% disp(RC)
% disp(TC)
% disp(BC)
% disp(t_corners)


%check for out


%for translating the images

I1x = 0;
I2x=0;
I1y=0;
I2y=0;

% if LC<1
%     I1x =  abs(LC)+1;
% elseif LC >1
%     %do
%     I2x = LC -1;
%     
% elseif TC<1
%     %do
%     I1y = abs(TC) + 1;
% elseif TC>1
%     %do
%     I2y = TC -1;
% end
% 

if LC<1
    I1x =  abs(LC)+1;
end

if LC >1
    %do
    I2x = LC -1;
end
if TC<1
    %do
    I1y = abs(TC) + 1;
end
if TC>1
    %do
    I2y = TC -1;
end






newI1 = imtranslate(I1,[I1x , I1y],'OutputView','full');  %check for 'full'
newtransformed = imtranslate(t_image,[I2x,I2y],'OutputView','full');

% zero padding for padarray 
%getting error if we dont do this

padI1x = 0;
padI1y = 0;
padTx = 0;
padTy = 0;


if size(newtransformed,2) - size(newI1,2) > 0
    padI1y = size(newtransformed,2) - size(newI1,2);
else
    padTy = size(newI1,2) - size(newtransformed,2) ;
end

if size(newtransformed,1) - size(newI1,1) > 0
    padI1x = size(newtransformed,1) - size(newI1,1);
else
    padTx = size(newI1,1) - size(newtransformed,1) ;
end

padedI1 = padarray(newI1,[padI1x,padI1y],0,'post');
padedtransform = padarray(newtransformed,[padTx,padTy],0,'post');
% imOut = zeros(size(padedtransform));
% imOut =  (padedI1/2 + padedtransform/2);
imOut = max(padedI1,padedtransform);


imshow(uint8(imOut));
    
    

















% imOut = 0;






end

