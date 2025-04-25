`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2025 12:30:41
// Design Name: 
// Module Name: Normal_code
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


module Normal_code(

        input sysclk,     
        input rst_btn,
        
        //Start Game button
        input btn_start,
        
        //Button matrix
        input [8:0] btn_vec,
        
        //LED matrix
        output [8:0] led_vec,
        
        //External ADC MCP3202 Pin;
        output adc_din,
        output adc_clk,
        output adc_csn,
        input  adc_dout  
    );

//RESET SYSTEM CONFIG;
wire rstn;
assign rstn = ~rst_btn;

//CLOCK TREE CONFIG;
wire CLK500Hz,CLK1Hz,CLK_ADC;

clock_div clk_div_u1(rstn,sysclk,CLK500Hz);
clock_div clk_div_u2(rstn,CLK500Hz,CLK1Hz);
clock_div clk_div_u3(rstn,sysclk,CLK_ADC);


defparam clk_div_u1.FREQ_INPUT  = 12_000_000;
defparam clk_div_u1.FREQ_OUTPUT = 500;
defparam clk_div_u2.FREQ_INPUT  = 500;
defparam clk_div_u2.FREQ_OUTPUT = 1;
defparam clk_div_u3.FREQ_INPUT  = 12_000_000;
defparam clk_div_u3.FREQ_OUTPUT = 2_000_000;


reg [11:0] seed_data; // 12 bit ADC Data
        
//EXTERNAL ADC MCP3202 CONFIG;
// DRV FREQ : 2MHZ;
// CHANNEL : ONLY CHANNEL 0; 
localparam  SINGLE_CHAN0  = 2'b10;
localparam  SINGLE_CHAN1  = 2'b11;

reg adc_ready;
wire adc_vaild;
wire [11:0] adc_data;

drv_mcp3202 drv_mcp3202_u0(
    .rstn(rstn),
    .clk(CLK_ADC),
    .ap_ready(adc_ready),
    .ap_vaild(adc_vaild),  
    .mode(SINGLE_CHAN0),
    .data(adc_data),

    .port_din(adc_dout),
    .port_dout(adc_din), //adc_din
    .port_clk(adc_clk),
    .port_cs(adc_csn)
);

// ADC SAMPLING EVENT (FREQ:1HZ)
always @(negedge rstn, posedge adc_vaild,posedge CLK1Hz) begin
    if(!rstn) begin
        adc_ready <= 1'b0;
        seed_data <= 12'hABC;
    end else begin
        if(adc_vaild) begin
            seed_data <= adc_data;
            adc_ready <= 1'b0;
        end
        else begin
            adc_ready <= 1'b1;
        end
    end
end

// Code to make sure ADC is generating seed before sending to PRNG
reg isADCDone;
always @(negedge rstn, posedge CLK1Hz) begin
    if(!rstn) begin
        isADCDone <= 1'b0; // ADC is not ready
    end else begin
        isADCDone <= 1'b1; // ADC is ready
    end
end

//PRNG Code
wire [15:0] rng_num;
drv_pnrg prng_u0(
    .clk(CLK500Hz),
    .rstn(isADCDone),
//    .seed({4'b0000,seed_data}),
    .seed({16'b0000_1010_0101_0100}),
    .outnum(rng_num) 
);

led_game_ctrl led_game_ctrl_u0 (
    .clk(CLK500Hz),
    .rstn(rstn),
    .btn_start(btn_start),
    .btn_vec(btn_vec),
    .rng_num(rng_num),
    .led_vec(led_vec)
);
//assign led_vec = btn_vec;

endmodule
