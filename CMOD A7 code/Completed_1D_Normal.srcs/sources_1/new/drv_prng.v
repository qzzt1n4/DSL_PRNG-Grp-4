`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2025 17:56:47
// Design Name: 
// Module Name: PRNG_CODE
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


module drv_pnrg (
    input clk,
    input rstn,
    input [15:0] seed,
    output reg [15:0] outnum
);

    reg [15:0] lfsr1, lfsr2, lfsr3;

    wire feedback1 = lfsr1[15] ^ lfsr1[13] ^ lfsr1[12] ^ lfsr1[10]; // poly1
    wire feedback2 = lfsr2[15] ^ lfsr2[14] ^ lfsr2[11] ^ lfsr2[3];  // poly2
    wire feedback3 = lfsr3[15] ^ lfsr3[12] ^ lfsr3[7] ^ lfsr3[1];   // poly3

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            lfsr1 <= seed;
            lfsr2 <= {~seed[7:0], seed[7:0]};
            lfsr3 <= {seed[3:0], ~seed[15:4]};
        end else begin
            lfsr1 <= {lfsr1[14:0], feedback1};
            lfsr2 <= {lfsr2[14:0], feedback2};
            lfsr3 <= {lfsr3[14:0], feedback3};
        end
    end

    always @(*) begin
        outnum = lfsr1 ^ lfsr2 ^ lfsr3; // final output
    end

endmodule
