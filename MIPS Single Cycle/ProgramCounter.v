`timescale 1ns / 1ps

module ProgramCounter
    #(parameter PC_WIDTH = 32)
    ( 
        input clk, 
        input reset,
        input [PC_WIDTH-1:0] startPC,
        input [PC_WIDTH-1:0] last_address,
        output reg [PC_WIDTH-1:0] address

    );
    
    
   // Asynchronous reset, and trigerred at negedge of the clock
   always @(negedge clk or negedge reset)begin
    // Load the start_pc if reset is low
    if (reset==1'b0)
        address <= startPC;
    else 
        address <= last_address;
    end
endmodule