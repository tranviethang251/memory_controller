`timescale 1 ns/1 ps

module testbench;

localparam WIDTH  =  384;   
localparam HEIGHT =  512;
localparam DATA_WIDTH = 8 ; 
localparam WEIGHT = 5 ; 
reg        clk;
reg        rstb;
reg  [7:0] i_r;
reg  [7:0] i_g;
reg  [7:0] i_b;
// using for test SRAM
reg  [DATA_WIDTH-1:0] data ; 
wire [DATA_WIDTH-1:0] data_o ;  
// ----------------------

wire [7:0] o_y;
wire       o_hav;
wire       o_vav;
wire       hav;
wire       vav;
reg        hav_ss;
reg        vav_ss;
wire en_wr_file ; 
reg  [7:0] r_data[0:HEIGHT*WIDTH-1];
reg  [7:0] g_data[0:HEIGHT*WIDTH-1];
reg  [7:0] b_data[0:HEIGHT*WIDTH-1];
integer    i;
integer    result_y_id, result_hist_id, result_y_gray ; 

// Unit instantiation
hav_vav_gen 
#(
   .WIDTH  (WIDTH-1 ),
   .HEIGHT (HEIGHT-1),
   .H_BLANK(38      ), // 51 
   .V_BLANK(51      )) 
 sync_gen (
   .clk    (clk     ),
   .rstb   (rstb    ),
   .hav    (hav     ),
   .vav    (vav     )
);
  Filter_2
  # (
    .DATA_WIDTH (DATA_WIDTH) ,
    .WIDTH_IMAG (WIDTH),
    .HEIGHT_IMAG (HEIGHT),
    .WEIGHT(WEIGHT) )
   uut_1
  (
  .clk     (clk)  , 
	.rstb    (rstb) ,
  .i_hav   (o_hav),
  .i_vav   (o_vav),
	.data_in (o_y)  ,
  .data_out(data_o),
  .wr_file(en_wr_file) 
  ) ;
  
rgb2gray uut_2
(
   .clk  (clk   ),
   .rstb (rstb  ),
   .i_hav(hav_ss),
   .i_vav(vav_ss),
   .i_r  (i_r   ),
   .i_g  (i_g   ),
   .i_b  (i_b   ),
   .o_y  (o_y   ),
   .o_hav(o_hav ),
   .o_vav(o_vav )
);  
  
// Clock generation
always #10 clk = ~clk;

// Other stimulation
initial begin
   result_y_id  = $fopen("../py/out_y.txt", "w");
   result_y_gray  = $fopen("../py/out_y_gray.txt", "w");
   /* result_hist_id  = $fopen("../py/hist.txt", "w"); */
   rstb = 0;
   clk  = 0;
   i    = 0;
   @(negedge clk) rstb = 1;
   $readmemh("../matlab/in_img_r.txt", r_data);
   $readmemh("../matlab/in_img_g.txt", g_data);
   $readmemh("../matlab/in_img_b.txt", b_data);
end

always @(posedge clk or negedge rstb)
   if (!rstb) begin
      hav_ss <= 1'b0;
      vav_ss <= 1'b0;
   end
   else begin
      hav_ss <= hav;
      vav_ss <= vav;
   end
always @(posedge clk or negedge rstb)
   if (!rstb) begin
      i_r <= 8'd0;
      i_g <= 8'd0;
      i_b <= 8'd0;
   end
   else begin
      if (en_wr_file) begin
         $fwrite(result_y_id, "%d\n",data_o);
      end
      if (o_vav&o_hav) begin 
        $fwrite(result_y_gray, "%d\n",o_y);
      end
      if (hav & vav) begin
         i_r <= r_data[i];
         i_g <= g_data[i];
         i_b <= b_data[i];
         i   <= i + 1;
      end

      if (i == HEIGHT*WIDTH+1) begin
         for (i=0; i<256; i=i+1) begin
             //$fwrite(result_hist_id, "%d\n", uut.hist[i]);
         end
         $fclose(result_y_id);
         //$fclose(result_hist_id);
         $stop;
      end
   end

endmodule

