%%=========================================================================
% - Student     : Tran Viet Thang
% - University  : The University of Da Nang
% - Purpose     : Extracting value for reading in verilog
%                 Input image must be an integer RGB [0,255]
%==========================================================================
clc ; 
close all; 
clear all ;
original_image = imread('Image\02_ori.png') ; 
image_r  =  (original_image(:,:,1)) ; % red channel
image_g  =  (original_image(:,:,2)) ; % green channel
image_b  =  (original_image(:,:,3)) ; % blue channel
image_r  = image_r' ;                 % convert to vector 
image_g  = image_g' ;                 % convert to vector
image_b =  image_b' ;                 % convert to vector
% write to file text with format of hexadecimal 
formatSpec = '%x\n' ; 
fileID = fopen('in_img_r.txt','w'); 
fprintf(fileID,formatSpec,image_r(:)) ; 
fclose(fileID) ; 
fileID = fopen('in_img_g.txt','w');  
fprintf(fileID,formatSpec,image_g(:)) ; 
fclose(fileID) ; 
fileID = fopen('in_img_b.txt','w'); 
fprintf(fileID,formatSpec,image_b(:)) ; 
fclose(fileID) ; 