`timescale 1ns / 1ps
    
module PipelinedProc
    (
        CLK,
        Reset_L,
        startPC,
        dMemOut
    );
        
    input CLK,Reset_L;
    input [31:0] startPC;
    output [31:0] dMemOut;
    
    //wire [31:0] Data;
    wire [31:0] Instruction;
    reg [31:0] Address;
    wire [31:0] PCPlus4;
    reg [31:0] nextPC;
    
    //output of Hazard Unit 
    wire [1:0] addrSel; // Mux select for PC
    wire IF_write; 
    wire PC_write;
    wire bubble;
    
    //Pipelined Control  
    wire RegDst;  
    wire MemToReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire Jump;
    wire SignExtend; 
    wire UseShamt;
    wire UseImmed;
    wire [3:0]ALUOp_IF_ID; 
    
    //Forwarding Unit 
    wire [1:0] AluOpCtrlA_ID;
    wire [1:0] AluOpCtrlB_ID;
    wire DataMemForwardCtrl_EX_IF_ID;
    wire DataMemForwardCtrl_MEM_IF_ID;
    
    
    //sign extended data 
    wire[31:0] sign_extension_data;
    
    //register RF1 wires IF_ID  STAGE 
    wire [31:0] Register_file_A_IF_ID, Register_file_B_IF_ID;
    wire [5:0] Opcode_IF_ID;
    wire [4:0] RS_IF_ID;
    wire [4:0] RT_IF_ID;
    wire [4:0] RD_IF_ID;
    wire [5:0] FUNC_IF_ID;
    wire [31:0] IM_IF_ID;
    wire [25:0] Jump_IF_ID;
    wire [15:0] Immedi_IF_ID;
    wire  [31:0] Normal_PC_IF_ID;
    
    
    // Stage 3 ID -> Execute 
    wire RegDst_ID_EX;
    wire MemToReg_ID_EX;
    wire RegWrite_ID_EX;
    wire MemRead_ID_EX;
    wire MemWrite_ID_EX;
    wire [3:0]ALUOp_ID_EX;
    wire [1:0] AluOpCtrlA_ID_EX;
    wire [1:0] AluOpCtrlB_ID_EX;
    wire DataMemForwardCtrl_EX_ID_EX;
    wire DataMemForwardCtrl_MEM_ID_EX;
    wire [20:0] IM_20_0_ID_EX;
    /*(* keep = "true"*)*/wire [31:0] Sign_Extended_ID_EX;
    wire [31:0] Registers_A_ID_EX;
    wire [31:0] Registers_B_ID_EX;
    
    wire [5:0] Funccode_ID_EX;
    wire [4:0] RT_ID_EX;
    wire [4:0] RD_ID_EX;
    wire [4:0] Shamt_ID_EX;
    wire [4:0] RW_ID_EX;
    wire [31:0] Data_Memory_Input_ID_EX;
     
    wire [31:0] jumpTarget, branchTarget;    
    
    //ALU CONTROL
    wire [31:0] ALU_OUT;
    reg [31:0] ALU_IN1;
    reg [31:0] ALU_IN2;
    wire ALU_Zero;
    wire [3:0] ALU_control;
    
    
    // Stage 4_ DATA Memory 
    wire [31:0] Data_memory_out;
    wire [31:0] Data_Memory_Input_EX_MEM;
    wire [31:0] ALU_OUT_EX_MEM;
    wire [4:0] RW_EX_MEM; 
    wire [31:0] Data_Memory_actual_in;
    
    wire MemToReg_EX_MEM;
    wire RegWrite_EX_MEM;
    wire MemRead_EX_MEM;
    wire MemWrite_EX_MEM;
    
    wire DataMemForwardCtrl_MEM_EX_MEM;
    
    
    // stage 5 - WB 
    wire MemToReg_MEM_WB;
    wire RegWrite_MEM_WB;
    wire [4:0] RW_MEM_WB;
    wire [31:0] DataOut_MEM_WB;
    wire [31:0] ALU_OUT_MEM_WB;
    wire [31:0] Register_W_MEM_WB;
    
    // Jump and Branch MUXes
    assign PCPlus4 = nextPC + 4;
   
    assign jumpTarget = {PCPlus4 [31:28], Jump_IF_ID, 2'b0};
	assign branchTarget = Normal_PC_IF_ID + {Sign_Extended_ID_EX[29:0], 2'b0};
    
    always @(*) begin
        case(addrSel)
            2'b00: Address = PCPlus4;
            2'b01: Address = jumpTarget;
            2'b10: Address = branchTarget;
            default: Address = PCPlus4; 
        endcase
    end
    
    // PC Control Logic 
    always @ (negedge CLK)begin 
    if (~Reset_L)
        nextPC <= startPC;
    else if (PC_write)
        nextPC <= Address;
    end 
    
    InstructionMemory InstructionROMInst(.Data(Instruction), .Address(nextPC));
    
    
    IF_ID_Reg IF_ID_Lat (.Instruction(Instruction), .PCPlus4(PCPlus4), .IFWrite(IF_write),.clk(CLK), .Reset_L(Reset_L), .IM_IF_ID(IM_IF_ID), .Normal_PC_IF_ID(Normal_PC_IF_ID));
    
    // Decode the instructions
    assign Opcode_IF_ID     = IM_IF_ID[31:26];
    assign FUNC_IF_ID       = IM_IF_ID [5:0];
    assign RS_IF_ID         = IM_IF_ID[25:21];
    assign RT_IF_ID         = IM_IF_ID[20:16];
    assign Jump_IF_ID       = IM_IF_ID[25:0];
    assign Immedi_IF_ID     = IM_IF_ID[15:0];
    
    
    PipeLineCycleControl PipelinedControlLogic (
        .RegDst(RegDst), 
        .ALUSrc1(UseShamt),
        .ALUSrc2(UseImmed), 
        .MemToReg(MemToReg), 
        .RegWrite(RegWrite), 
        .MemRead(MemRead),
        .MemWrite(MemWrite), 
        .Branch(Branch), 
        .Jump(Jump), 
        .SignExtend(SignExtend), 
        .ALUOp(ALUOp_IF_ID), 
        .Opcode(Opcode_IF_ID), 
        .Func(FUNC_IF_ID)
    );
    
    //sign extension
    assign sign_extension_data = SignExtend ? {{16{IM_IF_ID[15]}},IM_IF_ID[15:0]} : {{16{1'b0}},IM_IF_ID[15:0]}  ;
    
    
    //hazard unit 
    HazardUnit hazard (
        .IFWrite(IF_write), 
        .PCWrite(PC_write), 
        .Bubble(bubble), 
        .addrSel(addrSel), 
        .Jump(Jump), 
        .Branch(Branch), 
        .ALUZero(ALU_Zero),
        .memReadX(MemRead_ID_EX), 
        .currRs(RS_IF_ID), 
        .currRt(RT_IF_ID), 
        .prevRt(RT_ID_EX), 
        .UseShamt(UseShamt), 
        .UseImmed(UseImmed), 
        .CLK(CLK), 
        .Reset_L(Reset_L)
    );
    
    //Register file 
    RegisterFile RegFile (
        .BusA(Register_file_A_IF_ID), 
        .BusB(Register_file_B_IF_ID), 
        .BusW(Register_W_MEM_WB), 
        .RA(RS_IF_ID), .RB(RT_IF_ID), 
        .RW( RW_MEM_WB ), 
        .RegWr(RegWrite_MEM_WB), 
        .Clk(CLK)
    );
    
    // Data Forwarding Unit 
    ForwardingUnit forward( 
        .UseShamt(UseShamt), 
        .UseImmed(UseImmed), 
        .ID_Rs(RS_IF_ID),
        .ID_Rt(RT_IF_ID), 
        .EX_Rw(RW_ID_EX),
        .MEM_Rw(RW_EX_MEM), 
        .EX_RegWrite(RegWrite_ID_EX), 
        .MEM_RegWrite(RegWrite_EX_MEM), 
        .AluOpCtrlA(AluOpCtrlA_ID), 
        .AluOpCtrlB(AluOpCtrlB_ID),
        .DataMemForwardCtrl_EX(DataMemForwardCtrl_EX_IF_ID), 
        .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM_IF_ID)
        );
    
    // STAGE 2 ID --> EX 
    
    // Instantiate the latch
    ID_EXE_Reg ID_EXE_Lat(
        .clk                                 (CLK),
        .Reset_L                             (Reset_L),
        .Bubble                              (bubble),                
        .RegDst                              (RegDst), 
        .MemToReg                            (MemToReg), 
        .RegWrite                            (RegWrite), 
        .MemRead                             (MemRead), 
        .MemWrite                            (MemWrite), 
        //.Branch                              (Branch), 
        //.Jump                                (Jump), 
        //.SignExtend                          (SignExtend ), 
        //.UseShamt                            (UseShamt), 
        //.UseImmed                            (UseImmed), 
        .ALUOp_IF_ID                         (ALUOp_IF_ID ), 
        .AluOpCtrlA_ID                       (AluOpCtrlA_ID), 
        .AluOpCtrlB_ID                       (AluOpCtrlB_ID), 
        .DataMemForwardCtrl_EX_IF_ID         (DataMemForwardCtrl_EX_IF_ID), 
        .DataMemForwardCtrl_MEM_IF_ID        (DataMemForwardCtrl_MEM_IF_ID), 
        .sign_extension_data                 (sign_extension_data), 
        .Register_file_A_IF_ID               (Register_file_A_IF_ID), 
        .Register_file_B_IF_ID               (Register_file_B_IF_ID), 
        .IM_IF_ID                            (IM_IF_ID  ), 
        .RegDst_ID_EX                        (RegDst_ID_EX), 
        .MemToReg_ID_EX                      (MemToReg_ID_EX), 
        .RegWrite_ID_EX                      (RegWrite_ID_EX), 
        .MemRead_ID_EX                       (MemRead_ID_EX), 
        .MemWrite_ID_EX                      (MemWrite_ID_EX), 
        .ALUOp_ID_EX                         (ALUOp_ID_EX), 
        .AluOpCtrlA_ID_EX                    (AluOpCtrlA_ID_EX), 
        .AluOpCtrlB_ID_EX                    (AluOpCtrlB_ID_EX), 
        .DataMemForwardCtrl_EX_ID_EX         (DataMemForwardCtrl_EX_ID_EX), 
        .DataMemForwardCtrl_MEM_ID_EX        (DataMemForwardCtrl_MEM_ID_EX), 
        .IM_20_0_ID_EX                       (IM_20_0_ID_EX), 
        .Sign_Extended_ID_EX                 (Sign_Extended_ID_EX), 
        .Registers_A_ID_EX                   (Registers_A_ID_EX), 
        .Registers_B_ID_EX                   (Registers_B_ID_EX) 

    );
    
    // stage 3 Actual Execute
    
    assign RT_ID_EX = IM_20_0_ID_EX[20:16];
    assign RD_ID_EX = IM_20_0_ID_EX[15:11];
    assign Shamt_ID_EX = IM_20_0_ID_EX[10:6];
    assign Funccode_ID_EX = IM_20_0_ID_EX [5:0];
    
    // muxes for ALU Source 
    // ALU Input 1
    always @(*)begin 
        case (AluOpCtrlA_ID_EX)
            2'b00: ALU_IN1 = {27'b0, Shamt_ID_EX};
            2'b01: ALU_IN1 = Register_W_MEM_WB;
            2'b10: ALU_IN1 = ALU_OUT_EX_MEM;
            2'b11: ALU_IN1 = Registers_A_ID_EX;
        endcase
    end 
    // ALU Input 2
    always @(*)begin 
        case (AluOpCtrlB_ID_EX)
            2'b00: ALU_IN2 = Sign_Extended_ID_EX;
            2'b01: ALU_IN2 = Register_W_MEM_WB;
            2'b10: ALU_IN2 = ALU_OUT_EX_MEM;
            2'b11: ALU_IN2 = Registers_B_ID_EX;
        endcase
    end 
    
    
    //ALU 
    ALU TheALU (.BusW(ALU_OUT), .Zero(ALU_Zero), .BusA(ALU_IN1), .BusB(ALU_IN2), .ALUCtrl(ALU_control));
    
    //ALU Control Unit. 
    ALUControl ALUControlModule (.ALUCtrl(ALU_control), .ALUop(ALUOp_ID_EX), .FuncCode(Funccode_ID_EX));
    
    // MUXes for the two forwarding paths    
    assign RW_ID_EX = RegDst_ID_EX ? RD_ID_EX : RT_ID_EX;
    assign Data_Memory_Input_ID_EX = DataMemForwardCtrl_EX_ID_EX ?  Register_W_MEM_WB : Registers_B_ID_EX;
    
    //Execute --> MEMORY

    EXE_MEM_Reg EXE_MEM_Lat(
        .clk                             (CLK), 
        .Reset_L                         (Reset_L), 
        .Data_Memory_Input_ID_EX         (Data_Memory_Input_ID_EX), 
        .ALU_OUT                         (ALU_OUT), 
        .RW_ID_EX                        (RW_ID_EX), 
        .MemToReg_ID_EX                  (MemToReg_ID_EX), 
        .RegWrite_ID_EX                  (RegWrite_ID_EX), 
        .MemRead_ID_EX                   (MemRead_ID_EX), 
        .MemWrite_ID_EX                  (MemWrite_ID_EX), 
        .DataMemForwardCtrl_MEM_ID_EX    (DataMemForwardCtrl_MEM_ID_EX), 
        .Data_Memory_Input_EX_MEM        (Data_Memory_Input_EX_MEM), 
        .ALU_OUT_EX_MEM                  (ALU_OUT_EX_MEM), 
        .RW_EX_MEM                       (RW_EX_MEM), 
        .MemToReg_EX_MEM                 (MemToReg_EX_MEM), 
        .RegWrite_EX_MEM                 (RegWrite_EX_MEM), 
        .MemRead_EX_MEM                  (MemRead_EX_MEM), 
        .MemWrite_EX_MEM                 (MemWrite_EX_MEM), 
        .DataMemForwardCtrl_MEM_EX_MEM   (DataMemForwardCtrl_MEM_EX_MEM) 
    );
    
    // Stage 4 - MEMORY
    assign Data_Memory_actual_in = DataMemForwardCtrl_MEM_EX_MEM ? Register_W_MEM_WB :Data_Memory_Input_EX_MEM;
    
    // DATA MEMORY MODULE Instantiation:
    DataMemory DataMemoryInst (.ReadData(Data_memory_out), .Address(ALU_OUT_EX_MEM), .WriteData(Data_Memory_actual_in), .MemoryRead(MemRead_EX_MEM), .MemoryWrite(MemWrite_EX_MEM), .Clock(CLK));
    
    // MEM -to WB stage latch
    MEM_WB_Reg MEM_WB_Lat(
    .clk                     (CLK), 
    .Reset_L                 (Reset_L), 
    .MemToReg_EX_MEM         (MemToReg_EX_MEM), 
    .RegWrite_EX_MEM         (RegWrite_EX_MEM), 
    .RW_EX_MEM               (RW_EX_MEM), 
    .Data_memory_out         (Data_memory_out), 
    .ALU_OUT_EX_MEM          (ALU_OUT_EX_MEM), 
    .MemToReg_MEM_WB         (MemToReg_MEM_WB), 
    .RegWrite_MEM_WB         (RegWrite_MEM_WB), 
    .RW_MEM_WB               (RW_MEM_WB), 
    .DataOut_MEM_WB          (DataOut_MEM_WB), 
    .ALU_OUT_MEM_WB          (ALU_OUT_MEM_WB)
    );
    
    // stage 5 Write back
    assign Register_W_MEM_WB = MemToReg_MEM_WB ? DataOut_MEM_WB : ALU_OUT_MEM_WB;
    
    // actual output 
    assign dMemOut = DataOut_MEM_WB;

endmodule
