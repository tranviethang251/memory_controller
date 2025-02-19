%%=========================================================================
% - Student     : Tran Viet Thang
% - University  : The University of Da Nang
% - Purpose     : Testing the result of verilog using 3*3 kernel 
%==========================================================================
function filtered_image = mean_filter(ori_image) ; 
% mean filter is used for filtering digital image with symtric padding 
% ori_image   : original image 
% kernel_size : size of kernel 
% filtered_image : average image 
image_r = uint16(ori_image(:,:,1)) ; % red channel 
image_g = uint16(ori_image(:,:,2)) ; % green channel
image_b = uint16(ori_image(:,:,3)) ; % blue channel
% rgb to gray scale
gray_image = floor(double((image_r.*77+image_g.*150+image_b.*29))./256) ;
gray_image = uint16(gray_image) ; 
[H,W] = size(gray_image)        ; 
% padding step 
tmp_image = zeros(H+2,W+2); % expanding 
tmp_image(2:H+1,2:W+1) = gray_image         ; 
tmp_image(1,2:W+1)     = gray_image(2,:)    ; % up padding
tmp_image(H+2,2:W+1)   = gray_image(H-1,:)  ; % down padding
tmp_image(2:H+1,1)     = gray_image(:,2)    ; % left padding 
tmp_image(2:H+1,W+2)   = gray_image(:,W-1)  ; % right padding
tmp_image(1,1)         = gray_image(2,2)    ; % left up corner padding
tmp_image(1,W+2)       = gray_image(2,W-1)  ; % right up corner padding
tmp_image(H+2,1)       = gray_image(H-1,2)  ; % left down corner padding
tmp_image(H+2,W+2)     = gray_image(H-1,W-1); % right down corner pading 
% create 3*3 kernel 
kernel = (28*ones(3,3,'double')) ; % 28/256 = 1/9 <=> (sum of kernel)/9 when convert to 8 bit image 
% filtering step 
fil_tmp_image = floor(imfilter(double(tmp_image),kernel)./(256)); 
% extracting the filtered image.
filtered_image = fil_tmp_image(2:H+1,2:W+1) ;  
filtered_image = uint8(filtered_image) ; 
end 