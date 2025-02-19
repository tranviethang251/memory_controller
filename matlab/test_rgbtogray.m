clc ; 
close all; 
clear all ;
original_image = imread('lenna.png') ; 
infor_image    = imfinfo('lenna.png') ; 
H = infor_image.Height ;
W = infor_image.Width; 
%rgb to gray scale 
gray_image = ones(H,W,'uint8') ;
image_r  =  uint16(original_image(:,:,1)) ; 
image_g  =  uint16(original_image(:,:,2)) ; 
image_b  =  uint16(original_image(:,:,3)) ; 
gray_image = floor(double((image_r.*77+image_g.*150+image_b.*29))./256) ;
gray_image = uint8(gray_image) ; 
% read result from verilog 
ver_data = (importdata('../py/out_y_gray.txt')); 
ver_image = reshape(ver_data,[W,H]) ;  
ver_image = uint8(ver_image') ;
% difference between matlab and verilog
diff = int32(ver_image(:)) - int32(gray_image(:)) ; 
% show image
figure(1) ; 
subplot(1,3,1) ; imshow(original_image) ; title('original image') ; 
subplot(1,3,2) ; imshow(gray_image) ;     title('matlab result') ;   
subplot(1,3,3) ; imshow(ver_image) ;      title('verilog result') ; 
%show difference
figure(2) ; 
plot(diff) ; title('difference between verilog and matlab result')