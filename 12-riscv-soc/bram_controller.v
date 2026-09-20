`timescale 1ns / 1ps

module bram_controller(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    input  wire [3:0]  we,
    input  wire        req,
    output reg         ack
);
    
    reg [31:0] bram [0:8191]; // 32KB
    
    always @(posedge clk) begin
        if (rst) begin
            ack <= 0;
            rdata <= 32'b0;
        end else begin
            ack <= 0;
            if (req) begin
                if (we[0] || we[1] || we[2] || we[3]) begin
                    if (we[0]) bram[addr[14:2]][7:0] <= wdata[7:0];
                    if (we[1]) bram[addr[14:2]][15:8] <= wdata[15:8];
                    if (we[2]) bram[addr[14:2]][23:16] <= wdata[23:16];
                    if (we[3]) bram[addr[14:2]][31:24] <= wdata[31:24];
                end
                rdata <= bram[addr[14:2]];
                ack <= 1'b1;
            end
        end
    end
    
endmodule