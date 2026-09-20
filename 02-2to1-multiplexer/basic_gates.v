`timescale 1ns / 1ps

module basic_gates(

 input [1:0] sw, // sw[0]=A, sw[1]=B
 output [3:0] led // result display
 );
 // 1. AND Gate (outputs 1 only when both inputs are 1)
 assign led[0] = sw[0] & sw[1];
 // 2. OR Gate (outputs 1 when at least one input is 1)
 assign led[1] = sw[0] | sw[1];
 // 3. XOR Gate (outputs 1 when inputs are different, 0 when equal)
 assign led[2] = sw[0] ^ sw[1];
 // 4. NAND Gate (inverse AND)
 assign led[3] = ~(sw[0] & sw[1]);

endmodule
