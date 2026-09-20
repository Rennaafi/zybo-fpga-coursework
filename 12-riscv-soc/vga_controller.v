`timescale 1ns / 1ps

module vga_controller(
    input  wire        clk,
    input  wire        rst,

    output reg  [4:0]  vga_r,
    output reg  [5:0]  vga_g,
    output reg  [4:0]  vga_b,
    output reg         vga_hsync,
    output reg         vga_vsync
);

    // ============================================================
    // 640x480 @ 60 Hz
    //
    // Pixel clock = 25 MHz
    // ============================================================

    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = 800;

    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = 525;

    reg [9:0] h_counter;
    reg [9:0] v_counter;

    // ============================================================
    // VGA timing
    // ============================================================

    always @(posedge clk) begin

        if (rst) begin

            h_counter <= 10'd0;
            v_counter <= 10'd0;

            vga_hsync <= 1'b1;
            vga_vsync <= 1'b1;

            vga_r <= 5'd0;
            vga_g <= 6'd0;
            vga_b <= 5'd0;

        end

        else begin

            // ====================================================
            // Horizontal counter
            // ====================================================

            if (h_counter == H_TOTAL - 1) begin

                h_counter <= 10'd0;

                // =================================================
                // Vertical counter
                // =================================================

                if (v_counter == V_TOTAL - 1) begin
                    v_counter <= 10'd0;
                end
                else begin
                    v_counter <= v_counter + 10'd1;
                end

            end
            else begin
                h_counter <= h_counter + 10'd1;
            end

            // ====================================================
            // HSYNC
            // Active LOW
            // ====================================================

            if ((h_counter >= H_ACTIVE + H_FRONT) &&
                (h_counter <  H_ACTIVE + H_FRONT + H_SYNC)) begin

                vga_hsync <= 1'b0;

            end
            else begin

                vga_hsync <= 1'b1;

            end

            // ====================================================
            // VSYNC
            // Active LOW
            // ====================================================

            if ((v_counter >= V_ACTIVE + V_FRONT) &&
                (v_counter <  V_ACTIVE + V_FRONT + V_SYNC)) begin

                vga_vsync <= 1'b0;

            end
            else begin

                vga_vsync <= 1'b1;

            end

            // ====================================================
            // Active video
            // ====================================================

            if ((h_counter < H_ACTIVE) &&
                (v_counter < V_ACTIVE)) begin

                // -----------------------------------------------
                // Red
                // -----------------------------------------------

                if (h_counter < 128) begin

                    vga_r <= 5'b11111;
                    vga_g <= 6'b000000;
                    vga_b <= 5'b00000;

                end

                // -----------------------------------------------
                // Green
                // -----------------------------------------------

                else if (h_counter < 256) begin

                    vga_r <= 5'b00000;
                    vga_g <= 6'b111111;
                    vga_b <= 5'b00000;

                end

                // -----------------------------------------------
                // Blue
                // -----------------------------------------------

                else if (h_counter < 384) begin

                    vga_r <= 5'b00000;
                    vga_g <= 6'b000000;
                    vga_b <= 5'b11111;

                end

                // -----------------------------------------------
                // White
                // -----------------------------------------------

                else if (h_counter < 512) begin

                    vga_r <= 5'b11111;
                    vga_g <= 6'b111111;
                    vga_b <= 5'b11111;

                end

                // -----------------------------------------------
                // Gray
                // -----------------------------------------------

                else begin

                    vga_r <= 5'b10000;
                    vga_g <= 6'b100000;
                    vga_b <= 5'b10000;

                end

            end

            // ====================================================
            // Blanking
            // ====================================================

            else begin

                vga_r <= 5'b00000;
                vga_g <= 6'b000000;
                vga_b <= 5'b00000;

            end

        end

    end

endmodule