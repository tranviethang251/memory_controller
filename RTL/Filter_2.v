module Filter_2
 # (
    parameter   DATA_WIDTH     = 8, 
	              WIDTH_IMAG     = 4, 
				        HEIGHT_IMAG    = 4,
				        WEIGHT         = 2 
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
localparam ADDR_PARA       = $clog2(WIDTH_IMAG)  ;   // the number of bits to present the WIDTH of image 
localparam VER_COUNT_PARA = $clog2(HEIGHT_IMAG) ;   // the number of bits to present the HEIGHT of image
// signal declaration 
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
wire [15:0] f ; 
// edge resutl 
wire [DATA_WIDTH:0] e ; 
// enhanced result 
wire [17:0] r ; 
// reg use for write to test file.
reg wr_file_reg ; 
// enable signal
wire wr_en ;   
// check for last line of image 
reg lst_tick ; 
// SRAM declaration 
reg [DATA_WIDTH-1:0]ram_1[WIDTH_IMAG-1:0] ; // the length of SRAM = WIDTH of image. It stores DATA_WIDTH bits for each image point
reg [DATA_WIDTH-1:0]ram_2[WIDTH_IMAG-1:0] ; // the length of SRAM = WIDTH of image. It stores DATA_WIDTH bits for each image point
// body 
// SRAM controller
always@(posedge clk or negedge rstb) 
 begin 
   if(~rstb) ram_addr <= 0 ; 
	 else begin 
	      if(wr_en) begin 
	      ram_1[ram_addr] <= data_in ; 
		    ram_2[ram_addr] <= w_s4 ;  // w_s4 = ram_1[ram_addr]
        ram_addr        <= (ram_addr==(WIDTH_IMAG-1)) ? 0 : ram_addr + 1; // ram_addr == (WIDTH_IMAG - 1) to prevent ram_addr from going out of the range [0, WIDTH - 1
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
        s1 <= data_in ; 
        s2 <= s1 ; 
	      s3 <= w_s4 ; 
        s4 <= s3 ; 
	      s5 <= w_s7 ; 
        s6 <= s5 ; 
     end 
   end 
// wire 
assign w_s1 = data_in ; 
assign w_s2 = s1  ;
assign w_s3 = s2  ;
assign w_s4 = ram_1[ram_addr] ; 
assign w_s5 = s3; 
assign w_s6 = s4; 
assign w_s7 = ram_2[ram_addr] ; 
assign w_s8 = s5 ; 
assign w_s9 = s6 ; 
// enable signal 
assign wr_en = (i_hav&i_vav)|lst_tick;  
// verical counter used to count the row of image which is useful to decide the state of machine.
always@(negedge i_hav or negedge i_vav or negedge rstb) begin 
   if(~i_vav||~rstb) ver_counter <= 0 ; 
   else 
      ver_counter <= (ver_counter==(HEIGHT_IMAG-1)) ? 0 : ver_counter + 1 ; // ver_counter == (HEIGHT_IMAG-1) to  prevent ver_counter from going out [0->HEIGHT-1]
   end 	
// FSM 
  reg [3:0] curr_state ; 
  reg [3:0] next_state ; 
// 
 
/* 
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
	     lst_tick    = 0 ;                                 // the last row are not writing to ram
   end
  4'b0010: begin 
       next_state = (ram_addr!=WIDTH_IMAG-1) ?  4'b0010 : 4'b0011 ;  // Check whether the next pixel is the end of the row 
	     lst_tick = 0 ;
   end
  4'b0011 : begin 
       next_state = 4'b0000 ; 
       lst_tick = 0 ;                                                // the last row are not writing to ram
   end 
  4'b0100: begin 
       next_state = 4'b0101 ; 
       lst_tick = 0 ;
   end 
  4'b0101 : begin 
       next_state = (ram_addr!=WIDTH_IMAG-1) ? 4'b0101 : 4'b0110 ;  // Check whether the next pixel is the end of the row
       lst_tick   = 0 ;                                            // the last row are not writing to ram
   end
  4'b0110: begin 
       next_state = (ver_counter==0) ? 4'b1111 : 4'b0000;            // Check the last row 
	     lst_tick    = 0 ;                                            // if ver_counter = 0 at this state means that the last row wrote to the ram_1. 
   end
  4'b1111 : begin 
       next_state = (i_vav==1)? 4'b1111 : 4'b0111 ;                 // wait for i_vav = 0, then it process the last row of image in the next state
       lst_tick   = (i_vav==0)? 1 : 0 ;                            // if i_vav = 0 then lst_tick = 1 to enable process pixels of last row.
   end 
  4'b0111 : begin 
       next_state = 4'b1000 ;  
	     lst_tick = 1;
   end 
  4'b1000: begin 
      next_state =(ram_addr!=WIDTH_IMAG-1) ? 4'b1000 : 4'b1001 ;     // Check whether the next pixel is the end of the row
	    lst_tick   = 1 ; 
   end 
  4'b1001 : begin 
       next_state = 4'b0000 ; 
       lst_tick = 0 ;
   end 
     default : 
	begin 
	    next_state =4'b0000; 
	    lst_tick   = 0 ; 
	end
endcase 
end
always@(*) begin  
   wr_file_reg = 1 ;
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
      wr_file_reg = 0 ; 
   end 
  endcase 
 end 
 
 
// mean filter 
assign f  = (16'd0+o_s1 + o_s2 + o_s3 + o_s4 + o_s5 + o_s6 + o_s7 + o_s8 + o_s9)*28 ;
//edge = origin - base 
assign e  = $signed({1'b0,o_s5}) - $signed({1'b0,f[15:8]}) ; // we use $signed for representing the negative number
// enhanced image = base + WEIGHT*edge 
assign r  = $signed({1'b0,WEIGHT})*$signed(e) + $signed({1'b0,f[15:8]}) ; 
// output 
assign data_out = (r[17]==1)? 8'd0 : (r[8]==1) ? 8'd255 : r[7:0]; 
/* 
   if r[17] = 1, then r is a negative number so we set data_out = 0 
   then ,we will check the value of r[8], 
   if r[8] = 1 which means that overflow happens so we set data_o = 255 
   if r[8] = 0 , there are no problem with r , so data_o = r[7:0] 
*/    
assign wr_file = wr_file_reg ;  
endmodule 




