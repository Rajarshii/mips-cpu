`timescale 1ns / 1ps

module SingleCycleProc
    (
        input CLK,Reset_L,
        input [31:0] startPC,
        output [31:0] dMemOut
    );
    

wire [31:0] Instruction;
wire [31:0] PC;
wire [31:0] next_PC;

//Single Cycle Control wires 
wire RegDst;
wire ALUSrc;
wire MemToReg;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire Branch;
wire Jump;
wire SignExtend;
wire [3:0]ALUOp;

//register RF1 wires 
wire [31:0] BusA, BusB;
wire[4:0] RegWrite_addr;
wire [31:0] RegWrite_data;


//ALU CONTROL wire
wire [3:0] ALU_control;

//ALU 
wire [31:0] ALU_Output;
wire ALU_Zero;

//DATA MEMORY 
wire [31:0] data_memory_out;

//shift left for branch;
wire [31:0] branch_aligned;

//branch address
wire [31:0] branch_address;

//pc update - computes PC = PC + 4
wire[31:0] PC_incr;

//and of branch and zero 

wire [31:0] branch_sel ;

//input to branch mux;

wire [31:0] branch_muxed;

//shift left 2 bits 25 to 0
wire [27:0] jump_shifted;

// jump address
wire [31:0] jump_addr;

//wire [31:0] final_output;

wire [31:0] ALU_BusB;
wire [31:0] ALU_BusA;

//MUX - for ALU In 
wire[31:0] sign_extended_imm;

//--------------------------Start of module inst -------------------------------//{

// Control Path ----
// Instantiate the control unit 
SingleCycleControl control (.RegDst(RegDst), .ALUSrc(ALUSrc), .MemToReg(MemToReg), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Jump(Jump), .SignExtend(SignExtend), .ALUOp(ALUOp), .Opcode(Instruction[31:26]));

//Instantiate the ALU Control Unit. 
ALUControl aluctl (.ALUCtrl(ALU_control), .ALUop(ALUOp), .FuncCode(Instruction[5:0]));


//---- Data Path ----
// Instantiate the instruction memory - fetch the instr from here
InstructionMemory instr_mem (.Data(Instruction), .Address(PC));

// Program Counter - with starting PC 
ProgramCounter pc ( .clk(CLK) , .reset(Reset_L) ,.startPC(startPC),.last_address(next_PC),.address(PC));

//Instantiate the Register _file;
RegisterFile reg_file (.BusA(BusA), .BusB(BusB), .BusW(RegWrite_data), .RA(Instruction[25:21]), .RB(Instruction[20:16]), .RW(RegWrite_addr), .RegWr(RegWrite), .Clk(CLK));

// Instantiate the ALU 
ALU alu_inst (.BusW(ALU_Output), .Zero(ALU_Zero), .BusA(ALU_BusA), .BusB(ALU_BusB), .ALUCtrl(ALU_control));

// Instantiate the data memory
DataMemory data_mem (.ReadData(data_memory_out), .Address(ALU_Output[5:0]), .WriteData(BusB), .MemoryRead(MemRead), .MemoryWrite(MemWrite), .Clock(CLK));

//--------------------------End of module inst -------------------------------//}
//--------------------------------------------------------------------------- //{
// Multiplexers and other calculation---- 
// sign extension logic
assign sign_extended_imm = SignExtend ? {{16{Instruction[15]}},Instruction[15:0]} : {{16{1'b0}},Instruction[15:0]}  ;

// write register src selection using RegDst 
assign RegWrite_addr = RegDst ? Instruction[15:11] : Instruction[20:16];

// ALU Input selection logic MUXes
// Operand B - either from reg file or from sign_extended imm
assign ALU_BusB = ALUSrc ? sign_extended_imm :BusB; // Select if we want immediate or reg out
// TODO //assign final_bus_A = ((ALU_control == 4'b0011) || (ALU_control == 4'b0100) || (ALU_control == 4'b1101)) ? Instruction[10:6] : BusA;
assign ALU_BusA = BusA;


// Instruction_written in register - either from data memory or from ALU
assign RegWrite_data = MemToReg ? data_memory_out: ALU_Output;

//shift left for branch - instr address aligned to word boundary
assign branch_aligned = sign_extended_imm << 2;
 
//pc update - next PC = PC + 4 (no branch prediction)
assign PC_incr =  PC + 32'd4 ; // Connects to 0 of MUX

//branch address calculation - no Branch prediction
assign branch_address = branch_aligned + PC_incr; // Should connect to 1 of MUX
assign branch_sel = Branch & ALU_Zero; // Select line for branch target - AND of Branch and ALU Zero output
assign branch_muxed = branch_sel ?  branch_address : PC_incr; // MUX

assign jump_shifted = Instruction[25:0] << 2;  // Added this for cleaner synthesis
assign jump_addr = {PC_incr[31:28],jump_shifted};

// PC Calculation
assign next_PC = Jump ? jump_addr : branch_muxed;
//--------------------------------------------------------------------------- //}

assign dMemOut = data_memory_out;
    
endmodule
