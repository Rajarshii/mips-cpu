`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 02:08:21 PM
// Design Name: 
// Module Name: IF_ID_Reg
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


module IF_ID_Reg(
    input clk, 
    input Reset_L,
    input [31:0] Instruction, 
    input [31:0] PCPlus4,
    input IFWrite,
    output reg [31:0] IM_IF_ID,
    output reg [31:0] Normal_PC_IF_ID 
    );
    
    always @ (negedge clk or negedge Reset_L) begin
    if(~Reset_L) begin
        IM_IF_ID <= 32'b0;
        Normal_PC_IF_ID <= 32'b0;
    end
    else if(IFWrite) begin
        IM_IF_ID <= Instruction;
        Normal_PC_IF_ID <= PCPlus4;
    end
    end
endmodule
