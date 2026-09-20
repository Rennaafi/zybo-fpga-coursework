module comparator_4bit (
 input [3:0] a, // 4-bit input A
 input [3:0] b, // 4-bit input B
 output reg eq_r, // Equal (A == B)
 output reg gt_g, // Greater Than (A > B)
 output reg lt_b // Less Than (A < B)
 );
 // Use always @(*) because this is combinational logic
 always @(*) begin
 // Set default values (prevent Latch generation)
 eq_r = 0;
 gt_g = 0;
 lt_b = 0;
 if (a > b) begin
 gt_g = 1;
 end
 else if (a < b) begin
 lt_b = 1;
 end
 else begin
 eq_r = 1;
 end
 end
endmodule