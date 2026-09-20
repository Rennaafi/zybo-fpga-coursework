`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2026 07:00:03 PM
// Design Name: 
// Module Name: gates
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gates(
      input a,
    input b,
    output ld0,
    output ld1,
    output ld2,
    output ld3,
    output ld4
);

assign ld0 = a & b;      // AND gate
assign ld1 = a | b;      // OR gate
assign ld2 = ~a;         // NOT gate (inverter) on input a
assign ld3 = ~(a & b);   // NAND gate
assign ld4 = a ^ b;      // XOR gate

endmodule
