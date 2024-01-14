`timescale 1ns / 1ps

module ForwardingUnit(
    UseShamt , 
    UseImmed , 
    ID_Rs , 
    ID_Rt , 
    EX_Rw, 
    MEM_Rw,
    EX_RegWrite , 
    MEM_RegWrite , 
    AluOpCtrlA , 
    AluOpCtrlB , 
    DataMemForwardCtrl_EX ,
    DataMemForwardCtrl_MEM
);
    input UseShamt , UseImmed;
    input [4:0] ID_Rs , ID_Rt , EX_Rw, MEM_Rw;
    input EX_RegWrite , MEM_RegWrite;
    output reg [1:0] AluOpCtrlA , AluOpCtrlB;
    output reg DataMemForwardCtrl_EX , DataMemForwardCtrl_MEM;
    
    // Rw is either Rd or Rt depending on the instruction - 
    // Insert a MUX outside.
    
    // Check if a write is happening to the register 0 -
    wire EXRw_Reg0, MEMWr_Reg0;
    assign EXRw_Reg0 = (EX_Rw == 5'b0);
    assign MEMWr_Reg0 = (MEM_Rw == 5'b0);
    
    // 
    // TODO // wire Rs_Eq_EXRw, Rt_Eq_EXRw;
    
    always @(*) begin
        if(UseShamt) begin       // No forwarding needed
            AluOpCtrlA <= 2'b00;
        end
        else if(EX_RegWrite & ID_Rs==EX_Rw & ~(EXRw_Reg0)) begin // Higher Priority - younger value
            AluOpCtrlA <= 2'b10; // COnfusing - Check the diagram
        end
        else if(MEM_RegWrite & ID_Rs==MEM_Rw & ~(MEMWr_Reg0)) begin
            AluOpCtrlA <= 2'b01; // Confusing - check the diagram
        end
        else AluOpCtrlA <= 2'b11;
    end
    
    always @(*) begin
        if(UseImmed) begin
            AluOpCtrlB <= 2'b00;
        end
        else if(EX_RegWrite & ID_Rt==EX_Rw & ~(EXRw_Reg0)) begin // Higher Priority - younger value
            AluOpCtrlB <= 2'b10; // Confusing - Check the diagram
        end
        else if(MEM_RegWrite & ID_Rt==MEM_Rw & ~(MEMWr_Reg0)) begin
            AluOpCtrlB <= 2'b01; // Confusing - check the diagram
        end
        else AluOpCtrlB <= 2'b11;
    end
    
    always @(*) begin  
        // Default value assignment
        DataMemForwardCtrl_EX = 1'b0;
        DataMemForwardCtrl_MEM = 1'b0;  
        if(MEM_RegWrite & ID_Rt==MEM_Rw & ~(MEMWr_Reg0)) begin
            DataMemForwardCtrl_EX = 1'b1;
            DataMemForwardCtrl_MEM = 1'b0;
        end
        else if(EX_RegWrite & ID_Rt==EX_Rw & ~(EXRw_Reg0)) begin
            DataMemForwardCtrl_EX = 1'b0;
            DataMemForwardCtrl_MEM = 1'b1;
        end
    end
    

endmodule