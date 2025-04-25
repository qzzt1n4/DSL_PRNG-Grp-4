`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2025 22:45:41
// Design Name: 
// Module Name: led_game_ctrl
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


module led_game_ctrl (
    input clk,
    input rstn,
    input btn_start,
    input [8:0] btn_vec,
    input [15:0] rng_num,
    output reg [8:0] led_vec
);

    reg [8:0] captured_pattern;
    reg [8:0] user_input;
    reg [2:0] state;
    reg [15:0] counter;

    localparam [2:0]
        IDLE           = 3'd0,
        SHOW_PATTERN   = 3'd1,
        WAIT_CLEAR     = 3'd2,
        WAIT_INPUT     = 3'd3,
        DISPLAY_RESULT = 3'd4,
        CLEAR_DISPLAY  = 3'd5;

    localparam [8:0]
        PATTERN_O = 9'b111_101_111,
        PATTERN_X = 9'b101_010_101;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            led_vec          <= 9'b000_000_000;
            captured_pattern <= 9'b0;
            user_input       <= 9'b0;
            state            <= IDLE;
            counter          <= 0;
        end else begin
            case (state)
                IDLE: begin
                    led_vec <= 9'b000_000_000;
                    counter <= 0;
                    if (btn_start) begin
                        captured_pattern <= rng_num[8:0];
                        led_vec <= rng_num[8:0];
                        counter <= 0;
                        state <= SHOW_PATTERN;
                    end
                end

                SHOW_PATTERN: begin
                    if (counter < 1500) begin // 3 seconds
                        counter <= counter + 1;
                    end else begin
                        led_vec <= 9'b000_000_000;
                        counter <= 0;
                        state <= WAIT_INPUT;
                        user_input <= 9'd0;
                    end
                end

                WAIT_INPUT: begin
                    if (btn_vec != 9'b000_000_000) begin
                        user_input <= user_input | btn_vec;
                        counter <= 0;
                        led_vec <= user_input;
                    end else if (counter < 3000) begin // Wait 6 seconds
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= DISPLAY_RESULT;
                    end
                end

                DISPLAY_RESULT: begin
                    if (user_input == captured_pattern) begin
                        led_vec <= PATTERN_O;
                    end else begin
                        led_vec <= PATTERN_X;
                    end
                    counter <= 0;
                    state <= CLEAR_DISPLAY;
                end

                CLEAR_DISPLAY: begin
                    if (counter < 1500) begin // Show result for 3 seconds
                        counter <= counter + 1;
                    end else begin
                        led_vec <= 9'b000_000_000;
                        counter <= 0;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
