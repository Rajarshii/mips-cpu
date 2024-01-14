`timescale 1ns / 1ps

module EXE_MEM_Reg(
    input clk,
    input Reset_L,
    input [31:0] Data_Memory_Input_ID_EX,
    input [31:0] ALU_OUT,
    input [4:0] RW_ID_EX,
    input MemToReg_ID_EX,
    input RegWrite_ID_EX,
    input MemRead_ID_EX,
    input MemWrite_ID_EX,
    input DataMemForwardCtrl_MEM_ID_EX,
    
    output reg [31:0] Data_Memory_Input_EX_MEM,
    output reg [31:0] ALU_OUT_EX_MEM,
    output reg [4:0] RW_EX_MEM,
    output reg MemToReg_EX_MEM,
    output reg RegWrite_EX_MEM,
    output reg MemRead_EX_MEM,
    output reg MemWrite_EX_MEM,
    output reg DataMemForwardCtrl_MEM_EX_MEM
    );
    
    always @ (negedge clk or negedge Reset_L) begin
        if (~Reset_L)begin     
            Data_Memory_Input_EX_MEM        <= 32'b0;
            ALU_OUT_EX_MEM	                <= 32'b0;
            RW_EX_MEM		                <= 5'b0;
            MemToReg_EX_MEM	                <= 1'b0;
            RegWrite_EX_MEM	                <= 1'b0;
            MemRead_EX_MEM	                <= 1'b0;
            MemWrite_EX_MEM	                <= 1'b0;
            DataMemForwardCtrl_MEM_EX_MEM   <= 1'b0;
        end 
        else 
        begin 
            Data_Memory_Input_EX_MEM        <= Data_Memory_Input_ID_EX;
            ALU_OUT_EX_MEM	                <= ALU_OUT;
            RW_EX_MEM		                <= RW_ID_EX;
            MemToReg_EX_MEM	                <= MemToReg_ID_EX;
            RegWrite_EX_MEM	                <= RegWrite_ID_EX;
            MemRead_EX_MEM	                <= MemRead_ID_EX;
            MemWrite_EX_MEM	                <= MemWrite_ID_EX;
            DataMemForwardCtrl_MEM_EX_MEM   <= DataMemForwardCtrl_MEM_ID_EX;
        end 
    end 
endmodule
