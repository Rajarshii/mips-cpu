`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 02:22:32 PM
// Design Name: 
// Module Name: ID_IF_Reg
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


module ID_EXE_Reg(
    input clk,
    input Reset_L,
    input Bubble,
    // Control Unit outputs
    input RegDst,  
    input MemToReg,
    input RegWrite,
    input MemRead,
    input MemWrite,
    //input Branch,
    //input Jump,
    //input SignExtend, 
    //input UseShamt,
    //input UseImmed,
    input [3:0]ALUOp_IF_ID, 
     //Forwarding Unit 
    input [1:0] AluOpCtrlA_ID,
    input [1:0] AluOpCtrlB_ID,
    input DataMemForwardCtrl_EX_IF_ID,
    input DataMemForwardCtrl_MEM_IF_ID,
    //sign extended data 
    input [31:0] sign_extension_data,
    input [31:0] Register_file_A_IF_ID,    
    input [31:0] Register_file_B_IF_ID,
    input [20:0] IM_IF_ID,  
    
    //Outputs  
    output reg RegDst_ID_EX,
    output reg MemToReg_ID_EX,
    output reg RegWrite_ID_EX,
    output reg MemRead_ID_EX,
    output reg MemWrite_ID_EX,
    output reg [3:0] ALUOp_ID_EX,
    output reg [1:0] AluOpCtrlA_ID_EX,
    output reg [1:0] AluOpCtrlB_ID_EX,
    output reg DataMemForwardCtrl_EX_ID_EX,
    output reg DataMemForwardCtrl_MEM_ID_EX,
    output reg [20:0] IM_20_0_ID_EX,
    output reg [31:0] Sign_Extended_ID_EX,
    output reg [31:0] Registers_A_ID_EX,
    output reg [31:0] Registers_B_ID_EX
    );
    
    
    always @ (negedge clk or negedge Reset_L) begin
        if(~Reset_L) begin
            RegDst_ID_EX                <= 1'b0;
            MemToReg_ID_EX              <= 1'b0;
            RegWrite_ID_EX              <= 1'b0;
            MemRead_ID_EX               <= 1'b0;
            MemWrite_ID_EX              <= 1'b0;
            ALUOp_ID_EX                 <= 4'b0;
            AluOpCtrlA_ID_EX            <= 2'b0;
            AluOpCtrlB_ID_EX            <= 2'b0;
            DataMemForwardCtrl_EX_ID_EX <= 1'b0;
            DataMemForwardCtrl_MEM_ID_EX<= 1'b0;
            IM_20_0_ID_EX               <= 21'b0;
            Sign_Extended_ID_EX         <= 32'b0;
            Registers_A_ID_EX           <= 32'b0;
            Registers_B_ID_EX           <= 32'b0;
        end
        else if(Bubble) begin		// Bubble inserted in pipeline 
            RegDst_ID_EX                <= 1'b0;
            MemToReg_ID_EX              <= 1'b0;
            RegWrite_ID_EX              <= 1'b0;
            MemRead_ID_EX               <= 1'b0;
            MemWrite_ID_EX              <= 1'b0;
            ALUOp_ID_EX                 <= 4'b0;
            AluOpCtrlA_ID_EX            <= 2'b0;
            AluOpCtrlB_ID_EX            <= 2'b0;
            DataMemForwardCtrl_EX_ID_EX <= 1'b0;
            DataMemForwardCtrl_MEM_ID_EX<= 1'b0;
            IM_20_0_ID_EX               <= 21'b0;
            Sign_Extended_ID_EX         <= 32'b0;
            Registers_A_ID_EX           <= 32'b0;
            Registers_B_ID_EX           <= 32'b0;
        end 
        else begin 
            RegDst_ID_EX                <= RegDst;
            MemToReg_ID_EX              <= MemToReg;
            RegWrite_ID_EX              <= RegWrite;
            MemRead_ID_EX               <= MemRead;
            MemWrite_ID_EX              <= MemWrite;
            ALUOp_ID_EX                 <= ALUOp_IF_ID;
            AluOpCtrlA_ID_EX            <= AluOpCtrlA_ID;
            AluOpCtrlB_ID_EX            <= AluOpCtrlB_ID;
            DataMemForwardCtrl_EX_ID_EX     <= DataMemForwardCtrl_EX_IF_ID;
            DataMemForwardCtrl_MEM_ID_EX    <= DataMemForwardCtrl_MEM_IF_ID;
            IM_20_0_ID_EX               <= IM_IF_ID[20:0];
            Sign_Extended_ID_EX         <= sign_extension_data;
            Registers_A_ID_EX           <= Register_file_A_IF_ID;
            Registers_B_ID_EX           <= Register_file_B_IF_ID;
        end 
    end
endmodule
