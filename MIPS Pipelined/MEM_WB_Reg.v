`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 03:11:50 PM
// Design Name: 
// Module Name: MEM_WB_Reg
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


module MEM_WB_Reg(
    input clk,
    input Reset_L,
    input MemToReg_EX_MEM,
    input RegWrite_EX_MEM,
    input [4:0] RW_EX_MEM,
    input [31:0] Data_memory_out,
    input [31:0] ALU_OUT_EX_MEM,
    //Outputs
    output reg MemToReg_MEM_WB,
    output reg RegWrite_MEM_WB,
    output reg [4:0] RW_MEM_WB,
    output reg [31:0] DataOut_MEM_WB,
    output reg [31:0] ALU_OUT_MEM_WB   
    );
    
    always @(negedge clk or negedge Reset_L)begin 
        if (~Reset_L)begin
            MemToReg_MEM_WB <=1'b0;
            RegWrite_MEM_WB <=1'b0;
            RW_MEM_WB       <=5'b0;
            DataOut_MEM_WB  <=32'b0;
            ALU_OUT_MEM_WB  <=32'b0; 
        end 
        else begin 
            MemToReg_MEM_WB <=MemToReg_EX_MEM;
            RegWrite_MEM_WB <=RegWrite_EX_MEM;
            RW_MEM_WB       <=RW_EX_MEM;
            DataOut_MEM_WB  <=Data_memory_out;
            ALU_OUT_MEM_WB  <=ALU_OUT_EX_MEM; 
        end 
    end     
endmodule
