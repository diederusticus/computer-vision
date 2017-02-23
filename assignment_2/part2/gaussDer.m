function [ imOut Gd ] = gaussDer ( image ,G , sigma )

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

kernel_size = length(G);
Gd = zeros(size(G));

temp = kernel_size/2;
temp = int16(temp) - 1;
values = (-temp):1:(temp) ;
constant = -1/(sigma^2) ;

for i=1:length(G)
    Gd(i) = double(constant) * double(values(i)) * G(i);
end

%Do convolution
imOut = conv2(image,Gd);

end

