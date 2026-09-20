module multiplexer(

 input d0, // Input data 0
 input d1, // Input data 1
 input sel, // Selection signal
 output y // output
 );
 
 // Method 1: Use ternary operator (most concise)
 assign y = (sel == 1'b1) ? d1 : d0;
 
 // condition ? if_true : if_false
 /* // Method 2: Use a logic expression (Sum of Products)
 assign y = (~sel & d0) | (sel & d1);

 // Method 3: Use if-else (Behavioral)
 reg y_reg;
 always @(*) begin
 if(sel) y_reg = d1;
 else y_reg = d0;
 end
 assign y = y_reg;
 */

endmodule
