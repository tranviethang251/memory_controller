clc ; 
close all; 
clear all ;
image = imread('test_image.png') ; 
image_red   = uint16(image(:,:,1)) ; % red   channel 
image_green = uint16(image(:,:,2)) ; % green channel
image_blue  = uint16(image(:,:,3)) ; % blue  channel 
gray_image  = floor(double((image_red.*77+image_green.*150+image_blue.*29))./256) ; 
gray_image  = uint8(gray_image) ; 
[H,W] = size(gray_image) ; 
% padding
total_image = ones(H+2,W+2) ; 
total_image(2:513,2:513) = gray_image ; 
total_image(1,2:513)     = gray_image(2,:)   ; % 
total_image(514,2:513)   = gray_image(511,:) ; % 
total_image(2:513,1)     = gray_image(:,2)   ; % 
total_image(2:513,514)   = gray_image(:,511) ; % 
total_image(1,1)         = total_image(1,3) ;  
total_image(1,514)       = total_image(1,512) ; 
total_image(514,1)       = total_image(514,3) ;   
total_image(514,514)     = total_image(514,512) ;
total_image = uint16(total_image) ;
kernel = double((28+29)*ones(3,3)) ; 
% processing 
fil_image = floor(imfilter(double(total_image),kernel)./(256*2)); 
avg_fil_image(:,:,:) = uint8(fil_image(2:H+1,2:W+1,1)); 
check_data = uint8(importdata('../py/out_y.txt')) ; 
check_image = reshape(check_data,W,H) ; 
check_image = check_image' ;   
figure(2) ; 
subplot(1,2,1) ; imshow(check_image) ; title('verilog image') ; 
subplot(1,2,2) ; imshow(avg_fil_image) ; title('matlab image') ; 
diff = int32(check_image(:)) - int32(avg_fil_image(:)) ;  
figure(3) ; 
stem(diff); 
