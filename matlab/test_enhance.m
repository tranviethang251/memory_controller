%%=========================================================================
% - Student     : Tran Viet Thang
% - University  : The University of Da Nang
% - Purpose     : compare result between verilog and matlab
%                 Input image must be an integer RGB [0,255]
%==========================================================================
clc ; 
close all; 
clear all ;
% read an original image 
original_image = imread('Image\02_ori.png') ; 
infor_image    = imfinfo('Image\02_ori.png') ; 
H = infor_image.Height ;
W = infor_image.Width; 
%rgb to gray scale 
gray_image = ones(H,W,'uint8') ; % gray image 
image_r  =  uint16(original_image(:,:,1)) ; % red channel 
image_g  =  uint16(original_image(:,:,2)) ; % green channel
image_b  =  uint16(original_image(:,:,3)) ; % blue channel 
gray_image = floor(double((image_r.*77+image_g.*150+image_b.*29))./256) ; % rbg scale to gray scale function 
gray_image = uint8(gray_image) ; 
% filtering the image using 3*3 average filter 
filter_image = mean_filter(original_image) ;  
% ehancing image 
w_para = int32(5) ; 
edge = int32(gray_image) - int32(filter_image);   % extracting edge points                      
en_image = (int32(filter_image) + w_para*edge) ;  % enhanced image 
en_image = uint8(en_image) ;                       
% read data from verilog result 
ver_data = (importdata('../py/out_y.txt')); 
ver_image   = reshape(ver_data,W,H) ;    % reshape image from verilog data
ver_image   = uint8(ver_image')       ;  % transform to 8-bit image
mat_result  = en_image(:)             ;  % conver to vector for comparing
ver_result  = ver_image(:)            ;  % conver to vector for comparing
% differece between verilog and matlab
diff = int32(ver_result) - int32(mat_result) ; 
% show image 
figure(1) ;  
subplot(1,3,1); imshow(ver_image)    ; title('verilog result') ; 
subplot(1,3,2); imshow(filter_image) ; title('base image')     ;
subplot(1,3,3); imshow(gray_image)   ; title('original image') ; 
%show difference
figure(2) ; 
stem(diff) ; title('difference between verilog and matlab result')  ; 