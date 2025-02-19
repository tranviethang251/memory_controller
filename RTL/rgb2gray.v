module rgb2gray
(
    input        clk, rstb,
    input        i_hav, i_vav,
    input  [7:0] i_r, i_g, i_b,
    output       o_hav, o_vav,
    output [7:0] o_y
);

// Clocking input data
reg       hav, vav;
reg [7:0] r, g, b;

always @(posedge clk or negedge rstb) begin
   if (~rstb) begin
      hav <= 0;
      vav <= 0;
      r   <= 0;
      g   <= 0;
      b   <= 0;
   end
   else begin
      hav <= i_hav;
      vav <= i_vav;
      r   <= (i_hav&i_vav) ? i_r : 0;
      g   <= (i_hav&i_vav) ? i_g : 0;
      b   <= (i_hav&i_vav) ? i_b : 0;
   end
end

// y = (77r + 150g + 29b)>>8
reg [15:0] y_r, y_g, y_b;
reg        hav_t1, vav_t1;

always @(posedge clk or negedge rstb) begin
   if (~rstb) begin
      y_r    <= 0;
      y_g    <= 0;
      y_b    <= 0;
      hav_t1 <= 0;
      vav_t1 <= 0;
   end
   else begin
      y_r    <= r * 8'd77;
      y_g    <= g * 8'd150;
      y_b    <= b * 8'd29;
      hav_t1 <= hav;
      vav_t1 <= vav;
   end
end

reg [15:0] y;
reg        hav_t2, vav_t2;

always @(posedge clk or negedge rstb) begin
   if (~rstb) begin
      y      <= 0;
      hav_t2 <= 0;
      vav_t2 <= 0;
   end
   else begin
      y      <= y_r + y_g + y_b;
      hav_t2 <= hav_t1;
      vav_t2 <= vav_t1;
   end
end
// output
assign o_y   = y[15:8] ;
assign o_hav = hav_t2;
assign o_vav = vav_t2;
endmodule