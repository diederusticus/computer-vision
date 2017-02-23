function imOut = unsharp ( image , sigma , kernel_size , k )

smooth_image = gaussConv(image,sigma,sigma,kernel_size);

% size = [kernel_size kernel_size];
% kernel = fspecial('gaussian',size,sigma);
% smooth_image = conv2(image,kernel,'full');
% 
padding = int16((kernel_size-1)/2);

high_q_image = image;


height = (size(image,1));
width = (size(image,2));

imOut = zeros(size(image));

for i=1+padding:height-padding
    for j=1+padding:width-padding
        imOut(i-padding,j-padding) = high_q_image(i-padding,j-padding) - smooth_image(i,j) ;
    end
    
end
subtracted_image = imOut;
imOut = imOut .* k;
image = double(image);
imOut = imOut + image;




figure
subplot(2,2,1)
imshow(image,[])
title('input image')

subplot(2,2,2)
imshow(smooth_image,[])
title('smoothed image')

subplot(2,2,3)
imshow(subtracted_image,[])
title('subtracted image')

subplot(2,2,4)
imshow(imOut,[])
title('final image')




        














end