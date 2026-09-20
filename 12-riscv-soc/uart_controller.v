`timescale 1ns / 1ps

module uart_controller(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx,
    output wire        tx,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    input  wire        we,
    input  wire        req,
    output reg         ack,
    output wire        irq
);
    
    // ============================================================
    // Registers Map:
    //   addr 0x0: DATA Register (R/W)
    //   addr 0x4: STATUS Register (R)
    //     bit 0: RX Ready (1 = data available)
    //     bit 1: TX Busy (1 = transmitting)
    // ============================================================
    
    // Baud rate generator (115200 baud)
    reg [15:0] baud_counter;
    reg        baud_tick;
    
    always @(posedge clk) begin
        if (rst) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (baud_counter == 868) begin // 100MHz / 115200
                baud_counter <= 0;
                baud_tick <= 1'b1;
            end else begin
                baud_counter <= baud_counter + 1;
                baud_tick <= 0;
            end
        end
    end
    
    // ============================================================
    // UART Transmitter
    // ============================================================
    reg [7:0] tx_data;
    reg [3:0] tx_bit_count;
    reg       tx_busy;
    reg       tx_reg;
    
    assign tx = tx_reg;
    
    always @(posedge clk) begin
        if (rst) begin
            tx_reg <= 1'b1;
            tx_busy <= 0;
            tx_bit_count <= 0;
        end else begin
            if (!tx_busy && we && req && addr == 4'h0) begin
                tx_data <= wdata[7:0];
                tx_busy <= 1'b1;
                tx_bit_count <= 0;
                tx_reg <= 1'b0; // Start bit
            end else if (tx_busy && baud_tick) begin
                if (tx_bit_count < 8) begin
                    tx_reg <= tx_data[tx_bit_count];
                    tx_bit_count <= tx_bit_count + 1;
                end else if (tx_bit_count == 8) begin
                    tx_reg <= 1'b1; // Stop bit
                    tx_bit_count <= tx_bit_count + 1;
                end else begin
                    tx_busy <= 0;
                end
            end
        end
    end
    
    // ============================================================
    // UART Receiver with Interrupt
    // ============================================================
    reg [7:0] rx_data;
    reg [3:0] rx_bit_count;
    reg       rx_busy;
    reg       rx_ready;
    reg       rx_ready_prev;
    reg       irq_reg;
    
    always @(posedge clk) begin
        if (rst) begin
            rx_data <= 8'b0;
            rx_bit_count <= 0;
            rx_busy <= 0;
            rx_ready <= 0;
            rdata <= 32'b0;
            ack <= 0;
            irq_reg <= 0;
        end else begin
            // Defaults
            ack <= 0;
            rx_ready_prev <= rx_ready;
            
            // UART Receive Logic
            if (!rx_busy && !rx) begin
                rx_busy <= 1'b1;
                rx_bit_count <= 0;
            end else if (rx_busy && baud_tick) begin
                if (rx_bit_count == 0) begin
                    // Start bit - sample in middle
                    rx_bit_count <= rx_bit_count + 1;
                end else if (rx_bit_count < 9) begin
                    rx_data[rx_bit_count - 1] <= rx;
                    rx_bit_count <= rx_bit_count + 1;
                end else begin
                    // Stop bit
                    rx_busy <= 0;
                    rx_ready <= 1'b1;  // Data available
                end
            end
            
            // Interrupt Generation (rising edge of rx_ready)
            if (rx_ready && !rx_ready_prev) begin
                irq_reg <= 1'b1;
            end
            
            // Register Read/Write
            if (req) begin
                if (addr == 4'h0) begin
                    if (we) begin
                        // Write to DATA register - handled by transmitter
                        // Nothing else to do here
                    end else begin
                        // Read DATA register
                        rdata <= {24'b0, rx_data};
                        ack <= 1'b1;
                        rx_ready <= 1'b0;   // Clear ready flag on read
                        irq_reg <= 1'b0;    // Clear interrupt
                    end
                end else if (addr == 4'h4) begin
                    // Read STATUS register
                    rdata <= {30'b0, tx_busy, rx_ready};
                    ack <= 1'b1;
                end
            end
        end
    end
    
    // Interrupt output
    assign irq = irq_reg;
    
endmodule