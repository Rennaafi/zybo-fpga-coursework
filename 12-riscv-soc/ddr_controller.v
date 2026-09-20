`timescale 1ns / 1ps

module ddr_controller(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    input  wire [3:0]  we,
    input  wire        req,
    output reg         ack,
    output reg  [31:0] mig_addr,
    output reg  [31:0] mig_wdata,
    input  wire [31:0] mig_rdata,
    input  wire        mig_rvalid,
    output reg         mig_cmd_en,
    output reg  [2:0]  mig_cmd_instr,
    output reg  [6:0]  mig_cmd_bl,
    input  wire        mig_cmd_empty,
    input  wire        mig_cmd_full,
    input  wire        mig_rd_empty,
    input  wire        mig_rd_full,
    input  wire        mig_wr_empty,
    input  wire        mig_wr_full,
    input  wire        mig_init_done
);
    
    localparam IDLE = 2'b00,
               WRITE = 2'b01,
               READ = 2'b10,
               WAIT_RD = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ack <= 0;
            mig_cmd_en <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (req && mig_init_done && !mig_cmd_full) begin
                        if (we) begin
                            state <= WRITE;
                            mig_cmd_instr <= 3'b000; // Write
                            mig_cmd_bl <= 7'b0000001;
                            mig_addr <= addr;
                            mig_wdata <= wdata;
                            mig_cmd_en <= 1'b1;
                        end else begin
                            state <= READ;
                            mig_cmd_instr <= 3'b001; // Read
                            mig_cmd_bl <= 7'b0000001;
                            mig_addr <= addr;
                            mig_cmd_en <= 1'b1;
                        end
                    end
                end
                WRITE: begin
                    mig_cmd_en <= 0;
                    if (!mig_cmd_full) begin
                        ack <= 1'b1;
                        state <= IDLE;
                    end
                end
                READ: begin
                    mig_cmd_en <= 0;
                    if (mig_rvalid) begin
                        rdata <= mig_rdata;
                        ack <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
    
endmodule