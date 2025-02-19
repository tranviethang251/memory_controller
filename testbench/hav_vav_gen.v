//////////////////////////////////////////////////////////////////
////                                                          ////
////                 HAV and VAV generator                    ////
////                                                          ////
//////////////////////////////////////////////////////////////////
module hav_vav_gen
   #(
   parameter WIDTH   = 1023,        // frame's width - 1
   parameter HEIGHT  = 1023,        // frame's height - 1
   parameter H_BLANK = 205,         // 20% of frame's width
   parameter V_BLANK = 205,         // 20% of frame's height
   parameter H_COUNTER_LENGTH = 11, // floor(log2(WIDTH + H_BLANK) + 1)
   parameter V_COUNTER_LENGTH = 11  // floor(log2(HEIGHT + V_BLANK) + 1)
   )
   (
   input      clk,
   input      rstb,
   output reg hav,
   output reg vav
   );

// Signals declaration
reg  [H_COUNTER_LENGTH-1:0] h_count_reg;
reg  [V_COUNTER_LENGTH-1:0] v_count_reg;

wire [H_COUNTER_LENGTH:0]   h_count_1_cmp      = {1'b0, h_count_reg} + (~(WIDTH + 2*H_BLANK)) + 1'b1;
wire                        h_count_1_cmp_flag = ~|h_count_1_cmp;
wire [H_COUNTER_LENGTH:0]   h_count_2_cmp      = {1'b0, h_count_reg} + (~(WIDTH + H_BLANK)) + 1'b1;
wire                        h_count_2_cmp_flag = ~|h_count_2_cmp;
wire [V_COUNTER_LENGTH:0]   v_count_end_cmp    = {1'b0, v_count_reg} + (~(HEIGHT + V_BLANK)) + 1'b1;
wire                        v_end              = ~|v_count_end_cmp;

reg                         h_end;
reg  [H_COUNTER_LENGTH-1:0] h_count_next;
reg  [V_COUNTER_LENGTH-1:0] v_count_next;

wire [H_COUNTER_LENGTH:0]   h_count_3_cmp      = {1'b0, h_count_reg} + (~H_BLANK) + 1'b1;
wire                        h_count_3_cmp_flag = ~h_count_3_cmp[H_COUNTER_LENGTH];
wire [H_COUNTER_LENGTH:0]   h_count_4_cmp      = (WIDTH + H_BLANK) + (~{1'b0, h_count_reg}) + 1'b1;
wire                        h_count_4_cmp_flag = ~h_count_4_cmp[H_COUNTER_LENGTH];
wire [V_COUNTER_LENGTH:0]   v_count_1_cmp      = (HEIGHT + V_BLANK) + (~{1'b0, v_count_reg}) + 1'b1;
wire                        v_count_1_cmp_flag = ~v_count_1_cmp[V_COUNTER_LENGTH];
wire [V_COUNTER_LENGTH:0]   v_count_2_cmp      = {1'b0, v_count_reg} + (~V_BLANK) + 1'b1;

wire                        hav_next_tmp       = h_count_3_cmp_flag & h_count_4_cmp_flag & v_count_1_cmp_flag;
wire                        vav_next           = ~v_count_2_cmp[V_COUNTER_LENGTH];
wire                        hav_next           = hav_next_tmp & vav_next;

// Combinational circuit
always @(*) begin
   case (v_end)
      1'b1   : h_end = h_count_1_cmp_flag;
	  default: h_end = h_count_2_cmp_flag;
   endcase
   
   case (h_end)
      1'b1   : h_count_next = {H_COUNTER_LENGTH{1'b0}};
	  default: h_count_next = h_count_reg + 1'b1;
   endcase
   
   case ({v_end, h_end})
      2'b11  : v_count_next = {V_COUNTER_LENGTH{1'b0}};
	  2'b01  : v_count_next = v_count_reg + 1'b1;
	  default: v_count_next = v_count_reg;
   endcase
end

// Registers
always @(posedge clk or negedge rstb) begin
   if (!rstb) begin
      h_count_reg <= {H_COUNTER_LENGTH{1'b0}};
	  v_count_reg <= {V_COUNTER_LENGTH{1'b0}};
	  hav         <= 1'b0;
	  vav         <= 1'b0;
   end
   else begin
      h_count_reg <= h_count_next;
	  v_count_reg <= v_count_next;
	  hav         <= hav_next;
	  vav         <= vav_next;
   end
end
		
endmodule
