module Filter_2
 # (
    parameter   DATA_WIDTH      = 8, 
				        ADDR_PARA       = 12,
				        VER_COUNT_PARA  = 12,
				        HEIGHT_IMG_PARA = 512, 
				        WIDTH_IMG_PARA  = 512,
 				        WEIGHT = 2 
 )
 (
  input wire                       clk ,
  input wire                       rstb,
  input wire                      i_hav,
  input wire                      i_vav,
  input wire   [DATA_WIDTH-1:0] data_in,
  output wire                   wr_file,
  output wire  [DATA_WIDTH-1:0] data_out 
) ; 
// local parameter 
// signal declaration 
// Initilization WIDHT_IMAGE and HEIGHT_IMAGE
wire [ADDR_PARA-1:0] WIDTH_IMAG       = WIDTH_IMG_PARA;
wire [VER_COUNT_PARA-1:0] HEIGHT_IMAG = HEIGHT_IMG_PARA; 
// delay i_hav and i_vav 
reg d_i_hav ; 
reg d_i_vav ; 
// delay input 
reg [DATA_WIDTH-1:0] d_data_in ; 
// 6 delay register 
reg [DATA_WIDTH-1:0] s1 ;  
reg [DATA_WIDTH-1:0] s2 ;
reg [DATA_WIDTH-1:0] s3 ; 
reg [DATA_WIDTH-1:0] s4 ; 
reg [DATA_WIDTH-1:0] s5 ;
reg [DATA_WIDTH-1:0] s6 ; 
// wire 
wire [DATA_WIDTH-1:0] w_s1 ;
wire [DATA_WIDTH-1:0] w_s2 ;
wire [DATA_WIDTH-1:0] w_s3 ;
wire [DATA_WIDTH-1:0] w_s4 ;
wire [DATA_WIDTH-1:0] w_s5 ;
wire [DATA_WIDTH-1:0] w_s6 ;
wire [DATA_WIDTH-1:0] w_s7 ;
wire [DATA_WIDTH-1:0] w_s8 ;
wire [DATA_WIDTH-1:0] w_s9 ;
// address register
reg [ADDR_PARA-1:0] ram_addr ; //  ram_addr = [0 -> width of image-1] 
// Vertical counter 
reg [VER_COUNT_PARA-1:0] ver_counter ; 
// output register 
reg [DATA_WIDTH-1:0] o_s1 ;
reg [DATA_WIDTH-1:0] o_s2 ;
reg [DATA_WIDTH-1:0] o_s3 ;
reg [DATA_WIDTH-1:0] o_s4 ;
reg [DATA_WIDTH-1:0] o_s5 ;
reg [DATA_WIDTH-1:0] o_s6 ;
reg [DATA_WIDTH-1:0] o_s7 ;
reg [DATA_WIDTH-1:0] o_s8 ;
reg [DATA_WIDTH-1:0] o_s9 ;
// filtered result 
reg [DATA_WIDTH-1:0] mean_filter ;  
// edge resutl 
reg [DATA_WIDTH:0] edge_point ; 
// enhanced result 
reg [17:0] en_img ; 
// last tick 
reg lst_tick ;
// enable signal
wire wr_en ;   
// delay d_i_hav for 1 clock cycle 
reg de_i_hav ; 
// negative edge signal of i_hav
wire neg_i_hav;
// SRAM declaration 
reg [DATA_WIDTH-1:0]ram_1[WIDTH_IMG_PARA-1:0] ; // the length of SRAM = WIDTH of image. It stores DATA_WIDTH bits for each image point
reg [DATA_WIDTH-1:0]ram_2[WIDTH_IMG_PARA-1:0] ; // the length of SRAM = WIDTH of image. It stores DATA_WIDTH bits for each image point
// body 
always@(posedge clk or negedge rstb) begin 
  if(!rstb) begin 
    d_i_hav   <= 0 ;
    d_i_vav   <= 0 ;
    d_data_in <= 0 ;
  end 
else begin
    d_i_hav   <= i_hav ;
    d_i_vav   <= i_vav ; 
    d_data_in <= data_in ; 
  end 
end
// SRAM controller ;
always@(posedge clk or negedge rstb)  begin 
   if(~rstb) ram_addr <= 0 ; 
	 else begin 
	      if(wr_en) begin 
	      ram_1[ram_addr]   <=  d_data_in ; 
		    ram_2[ram_addr]   <=  w_s4 ;                                               // w_s4 = ram_1[ram_addr]
        ram_addr          <= (ram_addr==(WIDTH_IMAG-1'b1)) ? 0 : ram_addr + 1'b1; // ram_addr == (WIDTH_IMAG - 1) to prevent ram_addr from going out of the range [0, WIDTH - 1]
	     end 
    end 
end  
// delay flip flop 
always@(posedge clk or negedge rstb) 
   begin 
       if(~rstb) begin 
			 s1<=0 ;
			 s2<=0; 
			 s3<=0;
			 s4<=0;
			 s5<=0;
			 s6<=0 ;
     end 
   else if (wr_en) begin 
       s1 <= d_data_in ; 
       s2 <= s1 ; 
	     s3 <= w_s4 ;
       s4 <= s3 ; 
	     s5 <= w_s7; 
       s6 <= s5 ; 
     end 
   end 
// wire 
assign w_s1 = d_data_in ; 
assign w_s2 = s1  ;
assign w_s3 = s2  ;
assign w_s4 = ram_1[ram_addr] ;
assign w_s5 = s3; 
assign w_s6 = s4; 
assign w_s7 = ram_2[ram_addr] ; 
assign w_s8 = s5 ; 
assign w_s9 = s6 ; 
// enable signal 
assign wr_en = (d_i_hav&d_i_vav)|(lst_tick);   
// verical counter used to count the row of image which is useful to decide the state of machine.
// verical counter 
always@(posedge clk or negedge rstb) begin 
   if(~rstb) ver_counter <=0 ; 
   else if(neg_i_hav) ver_counter <= (ver_counter==(HEIGHT_IMAG-1)) ? 0 : ver_counter + 1; 
   end 	
//  delay d_i_hav to 1 cycle clock 
always@(posedge clk or negedge rstb) begin 
    if(~rstb) de_i_hav <=0 ; 
    else de_i_hav <= d_i_hav ; 
    end 
assign neg_i_hav = (~d_i_hav)&de_i_hav; 
// FSM 
// state register
  reg [3:0] curr_state ;  // current state logic
  reg [3:0] next_state ;  // next state logic 
// state table
/* There are nine pixel cases that need to be processed
 state : 0000  -> do not process 
 state : 0001  -> process upper-left corner pixel at the first line of image 
 state : 0010  -> process pixels in the first line of image
 state : 0011  -> process upper-right corner pixel at the first line of image
 state : 0100  -> process the left edge pixels from the second image row to the (W-1)th image row
 state : 0101  -> Process the pixels from the second image row to the (W-1)th image row.
 state : 0110  -> Process the right edge pixels from the second image row to the (W-1)th image row
 state : 1111  -> dot not process. It's a temporary state before processing the last row 
 state : 0111  -> process the pixel at the lower-left corner of the last image row
 state : 1000  -> process the pixels in the last row 
 state : 1001  -> process the pixel at the lower-right corner of the last image row
  */
  // current state logic 
always@(posedge clk or negedge rstb) begin 
  if(~rstb) begin 
  curr_state <= 0 ; 
  end 
   else 
  curr_state <= next_state ; 
   end 
// next state logic
always@(*) begin 
  case(curr_state) 
   4'b0000 : begin  
       if(~wr_en) next_state = 4'b0000 ;                 // no data input 
       else if (ver_counter==0) next_state =  4'b0000;   // the first row are writing to ram_1 so we don't process.
       else if (ver_counter==1) next_state =  4'b0001;   // start processing the image from the first row.
       else if (ver_counter>=2) next_state =  4'b0100;   // start processing the pixels from the second image row to the (W)th image row 
	     else next_state = 4'b0000; 
	     lst_tick = 0 ;                                    // the last row are not writing to ram
   end
   4'b0001: begin
       next_state = 4'b0010 ;
	     lst_tick    = 0 ;                                                // the last row are not writing to ram
   end
  4'b0010: begin 
       next_state = (ram_addr!=WIDTH_IMAG-1) ?  4'b0010 : 4'b0011 ;     // Check whether the next pixel is the end of the row 
	     lst_tick = 0 ;
   end
  4'b0011 : begin 
       next_state = 4'b0000 ; 
       lst_tick = 0 ;                                                   // the last row are not writing to ram
   end 
  4'b0100: begin 
       next_state = 4'b0101 ; 
       lst_tick = 0 ;
   end 
  4'b0101 : begin  
       next_state = (ram_addr!=WIDTH_IMAG-1) ? 4'b0101 : 4'b0110 ;      // Check whether the next pixel is the end of the row
       lst_tick   = 0 ;                                                 // the last row are not writing to ram
   end
  4'b0110: begin // xu li diem anh cuoi cung cua dong anh 
       next_state = (ver_counter==HEIGHT_IMAG-1) ? 4'b1111 : 4'b0000;   // Check the last row 
	     lst_tick    = 0 ;                                                // if ver_counter = 0 at this state means that the last row wrote to the ram_1. 
   end
  4'b1111 : begin                                                       
       next_state = (d_i_vav==1)? 4'b1111 : 4'b0111 ;                   // wait for i_vav = 0, then it process the last row of image in the next state
       lst_tick   = (d_i_vav==0)? 1 : 0 ;                                // if i_vav = 0 then lst_tick = 1 to enable process pixels of last row.
   end 
  4'b0111 : begin 
       next_state = 4'b1000 ;  
	     lst_tick = 1;
   end 
  4'b1000: begin 
      next_state =(ram_addr!=WIDTH_IMAG-1) ? 4'b1000 : 4'b1001 ;      // Check whether the next pixel is the end of the row
	    lst_tick   = 1 ; 
   end 
  4'b1001 : begin                                                     // finish a image 
       next_state = 4'b0000 ; 
       lst_tick = 0 ;                                                 // "turn off" lst_tick to stop writing to SRAM or writing to SRAM.
   end 
     default : 
	begin 
	    next_state =4'b0000; 
	    lst_tick   = 0 ; 
	end
endcase 
end
// output logic 
always@(*) begin  
  case(curr_state) 
    4'b0001 : begin 
      o_s1 = w_s1 ; 
      o_s2 = w_s2 ; 
      o_s3 = w_s1 ;
      o_s4 = w_s4 ; 
      o_s5 = w_s5 ; 
      o_s6 = w_s4 ; 
      o_s7 = w_s1 ; 
      o_s8 = w_s2 ; 
      o_s9 = w_s1 ;  
    end
    4'b0010 : begin 
      o_s1 = w_s1 ; 
      o_s2 = w_s2 ; 
      o_s3 = w_s3 ; 
      o_s4 = w_s4 ; 
      o_s5 = w_s5 ; 
      o_s6 = w_s6 ;
      o_s7 = w_s1; 
      o_s8 = w_s2 ;
      o_s9 = w_s3 ; 
    end 
    4'b0011 : begin 
      o_s1 = w_s3 ; 
      o_s2 = w_s2 ;
      o_s3 = w_s3 ; 
      o_s4 = w_s6;
      o_s5 = w_s5 ;
      o_s6 = w_s6 ;  
      o_s7 = w_s3 ; 
      o_s8 = w_s2 ;
      o_s9 = w_s3 ;    
    end 
    4'b0100: begin 
      o_s1 = w_s1; 
      o_s2 = w_s2 ; 
      o_s3 = w_s1 ; 
      o_s4 = w_s4 ; 
      o_s5 = w_s5 ; 
      o_s6 = w_s4 ;
      o_s7 = w_s7 ;
      o_s8 = w_s8 ; 
      o_s9 = w_s7 ; 
    end 
    4'b0101 : begin 
      o_s1 = w_s1 ;
      o_s2 = w_s2 ;
      o_s3 = w_s3 ;
      o_s4 = w_s4 ; 
      o_s5 = w_s5 ;
      o_s6 = w_s6; 
      o_s7 = w_s7;
      o_s8 = w_s8;
      o_s9 = w_s9;
    end
    4'b0110 : begin 
      o_s1 = w_s3 ;
      o_s2 = w_s2 ;
      o_s3 = w_s3 ;
      o_s4 = w_s6; 
      o_s5 = w_s5 ;
      o_s6 = w_s6 ; 
      o_s7 = w_s9 ;
      o_s8 = w_s8 ;
      o_s9 = w_s9 ;  
    end 
    4'b0111 : begin  
      o_s1 = w_s7 ;
      o_s2 = w_s8 ;
      o_s3 = w_s7 ;
      o_s4 = w_s4 ; 
      o_s5 = w_s5 ; 
      o_s6 = w_s4 ;
      o_s7 = w_s7 ;
      o_s8 = w_s8 ; 
      o_s9 = w_s7 ; 
    end
   4'b1000: begin 
      o_s1 = w_s9 ;
      o_s2 = w_s8 ;
      o_s3 = w_s7 ; 
      o_s4 = w_s4; 
      o_s5 = w_s5 ;
      o_s6 = w_s6 ; 
      o_s7 = w_s7 ;
      o_s8 = w_s8 ; 
      o_s9 = w_s9 ; 
   end
   4'b1001 : begin 
      o_s1 = w_s9 ; 
      o_s2 = w_s8 ;
      o_s3 = w_s9 ;
      o_s4 = w_s6 ; 
      o_s5 = w_s5 ;
      o_s6 = w_s6 ; 
      o_s7 = w_s9 ;
      o_s8 = w_s8 ;
      o_s9 = w_s9 ;
   end 
   default : begin 
      o_s1 = 0 ;
      o_s2 = 0 ;
      o_s3 = 0 ;
      o_s4 = 0 ;
      o_s5 = 0 ;
      o_s6 = 0 ;
      o_s7 = 0 ;
      o_s8 = 0 ;
      o_s9 = 0 ;
   end 
  endcase 
 end 
// 
// delay o_s to 1 cycle clock , to limit timing fail in implementation stages.
reg wr_2_file_0 ;
reg [DATA_WIDTH-1:0] d_o_s1 ;
reg [DATA_WIDTH-1:0] d_o_s2 ;
reg [DATA_WIDTH-1:0] d_o_s3 ;
reg [DATA_WIDTH-1:0] d_o_s4 ;
reg [DATA_WIDTH-1:0] d_o_s5 ;
reg [DATA_WIDTH-1:0] d_o_s6 ;
reg [DATA_WIDTH-1:0] d_o_s7 ;
reg [DATA_WIDTH-1:0] d_o_s8 ;
reg [DATA_WIDTH-1:0] d_o_s9 ;
always@(posedge clk or negedge rstb) begin 
 if(!rstb) begin 
  d_o_s1 <= 0 ; 
  d_o_s2 <= 0 ; 
  d_o_s3 <= 0 ; 
  d_o_s4 <= 0 ; 
  d_o_s5 <= 0 ; 
  d_o_s6 <= 0 ; 
  d_o_s7 <= 0 ; 
  d_o_s8 <= 0 ; 
  d_o_s9 <= 0 ; 
  wr_2_file_0 <= 0 ;
  end 
  else begin 
  d_o_s1 <= o_s1 ; 
  d_o_s2 <= o_s2 ; 
  d_o_s3 <= o_s3 ; 
  d_o_s4 <= o_s4 ; 
  d_o_s5 <= o_s5 ; 
  d_o_s6 <= o_s6 ; 
  d_o_s7 <= o_s7 ; 
  d_o_s8 <= o_s8 ; 
  d_o_s9 <= o_s9 ;
  wr_2_file_0 <= (|curr_state)&(|(~curr_state))   ;    // curr_state is neither 1111 nor 0000 => write to text file 
  end 
  end 
// Processing the arithmetic operation 
// we first group pair of o_s[n] to process addition operation 
// internal register 
// output register 
reg [DATA_WIDTH:0] sum_1 ;      // sum_1 <= o_s1 + o_s2 
reg [DATA_WIDTH:0] sum_2 ;      // sum_2 <= o_s3 + o_s4 
reg [DATA_WIDTH:0] sum_3 ;      // sum_3 <= o_s6 + o_s7 
reg [DATA_WIDTH:0] sum_4 ;      // sum_3 <= o_s8 + o_s9 
reg [DATA_WIDTH-1:0] reg_s5_1 ; // reg_s5_1 <= o_s5 , delay o_s5 to 1 cycle clock.
reg wr_2_file_1 ; 
always@(posedge clk or negedge rstb) begin 
  if(!rstb) wr_2_file_1 <=0 ;
  else wr_2_file_1 <= wr_2_file_0 ; 
  end 
// body 
always@(posedge clk or negedge rstb) begin 
  if(!rstb) begin 
  sum_1        <= 0 ;
  sum_2        <= 0 ; 
  sum_3        <= 0 ;
  sum_4        <= 0 ; 
  reg_s5_1     <= 0 ;
end 
  else begin 
  sum_1        <= d_o_s1 + d_o_s2 ; 
  sum_2        <= d_o_s3 + d_o_s4 ; 
  sum_3        <= d_o_s6 + d_o_s7 ; 
  sum_4        <= d_o_s8 + d_o_s9 ; 
  reg_s5_1     <= d_o_s5 ; 
  end
  end 
// we continue group pairs to process
reg [DATA_WIDTH+1:0] sum_1_2 ;   // sum_1_2 <= sum_1 + sum_2 ; 
reg [DATA_WIDTH+1:0] sum_3_4 ;   // sum_3_4 <= sum_3 + sum_4 ; 
reg [DATA_WIDTH-1:0] reg_s5_2 ;  // reg_s5_2 <= reg_s5_1 ;
reg wr_2_file_2 ; 
always@(posedge clk or negedge rstb) begin 
  if(!rstb) wr_2_file_1 <=0 ;
  else wr_2_file_2 <= wr_2_file_1 ; 
  end
always@(posedge clk or negedge rstb) begin 
  if(!rstb) begin 
    sum_1_2 <= 0 ; 
    sum_3_4 <=  0 ; 
    reg_s5_2 <= 0 ; 
  end 

 else begin 

  sum_1_2 <= sum_1+sum_2 ; 
  sum_3_4 <=  sum_3+sum_4 ; 
  reg_s5_2 <= reg_s5_1 ; 

  end

 end

 //

reg[DATA_WIDTH+2:0] o_sum ; // o_sum <= sum_1_2 + sum_3_4 ; 
 reg[DATA_WIDTH-1:0] reg_s5_3 ; // 
 reg wr_2_file_3 ; 
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_3<=0 ; 
   else wr_2_file_3 <= wr_2_file_2 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) begin 
      o_sum<=0 ; 
      reg_s5_3 <=0 ; 
    end 
  else begin 
     o_sum <= sum_1_2 + sum_3_4 ; 
     reg_s5_3 <= reg_s5_2 ; 
  end 
 end 
 // 
 reg[DATA_WIDTH+3:0] total_sum ; // total_sum <= o_sum + reg_s5_3 ; 
 reg[DATA_WIDTH-1:0] reg_s5_4  ;// reg_s5_4  <= reg_s5_3 ;
 reg wr_2_file_4 ;
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_4<=0 ; 
   else wr_2_file_4 <= wr_2_file_3 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) begin 
     total_sum <= 0 ; 
     reg_s5_4 <= 0 ;
   end 
 else begin 
      total_sum <= o_sum + reg_s5_3 ; 
      reg_s5_4  <= reg_s5_3 ;
   end 
 end 
// 
reg [15:0] mul_sum ; // mul_sum <= {total_sum,4'd0} + {total_sum,3'd0} + {total_sum,2'd0} ;
reg [DATA_WIDTH-1:0] reg_s5_5 ; // reg_s5_5 <= reg_s5_4 ; 
 reg wr_2_file_5 ;
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_5<=0 ; 
   else wr_2_file_5 <= wr_2_file_4 ; 
 end
always@(posedge clk or negedge rstb) begin  
  if(!rstb) begin 
     mul_sum <= 0 ; 
     reg_s5_5 <= 0 ;
  end else 
  begin 
    mul_sum <= {total_sum,4'd0} + {total_sum,3'd0} + {total_sum,2'd0} ;
    reg_s5_5 <= reg_s5_4 ;
    end 
end 
// 
reg wr_2_file_6 ;
reg [DATA_WIDTH-1:0] reg_s5_6 ; 
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_6<=0 ; 
   else wr_2_file_6 <= wr_2_file_5 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) begin 
     mean_filter <= 0 ; 
     reg_s5_6    <= 0 ; 
   end 
 else begin 
     mean_filter <= mul_sum[15:8] ; 
     reg_s5_6 <= reg_s5_5 ;
    end 
 end 
//
reg [DATA_WIDTH-1:0] d_mean_filter ;  
reg wr_2_file_7 ; 
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_7<=0 ; 
   else wr_2_file_7 <= wr_2_file_6 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) begin 
     edge_point <= 0 ;
     d_mean_filter <= 0 ; 
   end 
 else begin 
     edge_point <= $signed({1'b0,reg_s5_6}) - $signed({1'b0,mean_filter}) ; 
     d_mean_filter <= mean_filter ;
   end 
 end 
// 
reg wr_2_file_8 ; 
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_8<=0 ; 
   else wr_2_file_8 <= wr_2_file_7 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) begin  
      en_img <= 0 ; 
    end 
  else begin 
       en_img <= $signed({1'b0,WEIGHT})*$signed(edge_point) + $signed({1'b0,d_mean_filter})  ;
  end 
 end 
 //
 reg wr_2_file_9 ; 
 reg [DATA_WIDTH-1:0] de_result ; 
  always@(posedge clk or negedge rstb) begin 
   if(!rstb) wr_2_file_9<=0 ; 
   else wr_2_file_9 <= wr_2_file_8 ; 
 end
 always@(posedge clk or negedge rstb) begin 
   if(!rstb) de_result <= 0 ;
   else de_result      <=  (en_img[17]==1)? 8'd0 : (|(en_img[16:8])==1) ? 8'd255 : en_img[7:0]; 
 end 
assign wr_file = wr_2_file_9; 
 assign data_out = de_result ;
//assign data_out = o_s5 ; 
//assign wr_file = wr_en ;
/* 
   if r[17] = 1, then r is a negative number so we set data_out = 0 
   then ,we will check the value of r[8], 
   if r[8] = 1 which means that overflow happens so we set data_o = 255 
   if r[8] = 0 , there are no problem with r , so data_o = r[7:0] 
*/    
endmodule 
