`timescale 1ns / 1ps

module bus_arbiter(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    output wire [31:0] cpu_rdata,
    input  wire [3:0]  cpu_we,
    input  wire        cpu_req,
    output wire        cpu_ack,
    input  wire [31:0] bram_rdata,
    input  wire        bram_ack,
    input  wire [31:0] ddr_rdata,
    input  wire        ddr_ack,
    input  wire [31:0] periph_rdata,
    input  wire        periph_ack,
    output wire [31:0] bus_addr,
    output wire [31:0] bus_wdata,
    input  wire [31:0] bus_rdata,
    output wire [3:0]  bus_we,
    output wire        bus_req,
    input  wire        bus_ack
);
    
    reg [1:0] state;
    reg [31:0] read_data;
    reg        ack_out;
    
    localparam IDLE = 2'b00,
               BRAM = 2'b01,
               DDR  = 2'b10,
               PERIPH = 2'b11;
    
    assign cpu_rdata = read_data;
    assign cpu_ack = ack_out;
    
    assign bus_addr = cpu_addr;
    assign bus_wdata = cpu_wdata;
    assign bus_we = cpu_we;
    assign bus_req = cpu_req & (state == IDLE);
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ack_out <= 0;
            read_data <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_req) begin
                        if (cpu_addr[31:16] == 16'h0000) begin
                            state <= BRAM;
                        end else if (cpu_addr[31:24] == 8'h80) begin
                            state <= DDR;
                        end else if (cpu_addr[31:24] == 8'hA0) begin
                            state <= PERIPH;
                        end
                    end
                end
                BRAM: begin
                    if (bram_ack) begin
                        read_data <= bram_rdata;
                        ack_out <= 1'b1;
                        state <= IDLE;
                    end
                end
                DDR: begin
                    if (ddr_ack) begin
                        read_data <= ddr_rdata;
                        ack_out <= 1'b1;
                        state <= IDLE;
                    end
                end
                PERIPH: begin
                    if (periph_ack) begin
                        read_data <= periph_rdata;
                        ack_out <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
            if (!cpu_req) begin
                ack_out <= 0;
            end
        end
    end
    
endmodule