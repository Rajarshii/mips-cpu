`timescale 1ns / 1ps

// OPCODES and functionalities

`define RTYPEOPCODE 6'b000000
`define LWOPCODE    6'b100011
`define SWOPCODE    6'b101011
`define BEQOPCODE   6'b000100
`define JOPCODE     6'b000010
`define ORIOPCODE   6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE   6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110

`define AND     4'b0000
`define OR      4'b0001
`define ADD     4'b0010
`define SLL     4'b0011
`define SRL     4'b0100
`define SUB     4'b0110
`define SLT     4'b0111
`define ADDU    4'b1000
`define SUBU    4'b1001
`define XOR     4'b1010
`define SLTU    4'b1011
`define NOR     4'b1100
`define SRA     4'b1101
`define LUI     4'b1110
`define FUNC    4'b1111

// The design is intended to be entirely combinational. 
// All control signal assignments are done combinationally, based on the input Opcode
// Note: Sign extension has been added based on the requirements
// Note 2: Only the instructions provided in the Lab Manual are implemented (Fig. 3)

module SingleCycleControl(
    input wire [5:0] Opcode, 
    output reg RegDst, ALUSrc, MemToReg,RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend,
    output reg [3:0] ALUOp
    );
     
    always @ (Opcode) begin
        case(Opcode)
        // R-Type Instruction
            `RTYPEOPCODE: begin
                RegDst      = 1'b1; // Destination is register
                ALUSrc      = 1'b0; // Source is a register
                MemToReg    = 1'b0; // Register operations only
                RegWrite    = 1'b1; // Register needs write
                MemRead     = 1'b0; // No mem read
                MemWrite    = 1'b0; // no mem write
                Branch      = 1'b0; // no branching
                Jump        = 1'b0; // no jumps
                SignExtend  = 1'b0; // Register only, no-immediate here
                ALUOp       = `FUNC; // To indicate to generate the operation from Function code (instr 5:0)
            end
            
            // I - type Instruction
            
            `LWOPCODE: begin
                RegDst      = 1'b0;    // again, to write the load value
                ALUSrc      = 1'b1;    // Use the register imm
                MemToReg    = 1'b1;
                RegWrite    = 1'b1;    // Writing to register - to store the result
                MemRead     = 1'b1;    // We are reading from mem
                MemWrite    = 1'b0;
                Branch      = 1'b0;
                Jump        = 1'b0;
                SignExtend  = 1'b1;   // Sign extend
                ALUOp       = `ADD;   // ALU Operation to calculate effective address                                
             end
             
             `SWOPCODE: begin
                 RegDst     = 1'b0;
                 ALUSrc     = 1'b1;
                 MemToReg   = 1'b1;
                 RegWrite   = 1'b0;
                 MemRead    = 1'b0;
                 MemWrite   = 1'b1;
                 Branch     = 1'b0; 
                 Jump       = 1'b0;
                 SignExtend = 1'b1;                          
                 ALUOp      =  `ADD;                             
               end
               
             `BEQOPCODE: begin
                   RegDst   =  1'b0;
                   ALUSrc   =  1'b0;
                   MemToReg =  1'b0;
                   RegWrite =  1'b0;
                   MemRead  =  1'b0;
                   MemWrite =  1'b0;
                   Branch   =  1'b1;  
                   Jump     =  1'b0;
                   ALUOp    =  `SUB;                              
                   SignExtend =  1'b1;                             
              end    
                        
             `ORIOPCODE: begin
                   RegDst   =  1'b0;
                   ALUSrc   =  1'b1;
                   MemToReg =  1'b0;
                   RegWrite =  1'b1;
                   MemRead  =  1'b0;
                   MemWrite =  1'b0;
                   Branch   =  1'b0;
                   Jump     =  1'b0;
                   SignExtend =  1'b0; // Zero-extend, done in H/W
                   ALUOp = `OR;
              end
                              
             `ADDIOPCODE: begin
                   RegDst   =  1'b0;
                   ALUSrc   =  1'b1;
                   MemToReg =  1'b0;
                   RegWrite =  1'b1;
                   MemRead  =  1'b0;
                   MemWrite =  1'b0;
                   Branch   =  1'b0;
                   Jump     =  1'b0;
                   SignExtend   =  1'b1; // Sign-extend to 32 bits
                   ALUOp        =  `ADD;
             end             
                                     
             `ADDIUOPCODE: begin
                   RegDst       =  1'b0;
                   ALUSrc       =  1'b1;
                   MemToReg     =  1'b0;
                   RegWrite     =  1'b1;
                   MemRead      =  1'b0;
                   MemWrite     =  1'b0;
                   Branch       =  1'b0;
                   Jump         =  1'b0;
                   SignExtend   =  1'b0; // no hardware exceptions, zero extended - issue with test?
                   ALUOp        = `ADDU;
              end   
                           
             `ANDIOPCODE: begin
                 RegDst     =  1'b0;
                 ALUSrc     =  1'b1;
                 MemToReg   =  1'b0;
                 RegWrite   =  1'b1;
                 MemRead    =  1'b0;
                 MemWrite   =  1'b0;
                 Branch     =  1'b0;
                 Jump       =  1'b0;
                 SignExtend =  1'b0; // Zero extend, done in H/W automatically
                 ALUOp      =  `AND;
             end  
                                         
             `LUIOPCODE: begin
                   RegDst       =  1'b0;
                   ALUSrc       =  1'b1;
                   MemToReg     =  1'b0;
                   RegWrite     =  1'b1;
                   MemRead      =  1'b0;
                   MemWrite     =  1'b0;
                   Branch       =  1'b0;
                   Jump         =  1'b0;
                   SignExtend   = 1'b0; // Does not matter for LUI, we load only on the upper bits. keeping zero to avoid ambinguity
                   ALUOp =  `LUI;
              end  
                                                       
             `SLTIOPCODE: begin
                     RegDst     =  1'b0;
                     ALUSrc     =  1'b1;
                     MemToReg   =  1'b0;
                     RegWrite   =  1'b1;
                     MemRead    =  1'b0;
                     MemWrite   =  1'b0;
                     Branch     =  1'b0;
                     Jump       =  1'b0;
                     SignExtend = 1'b1; // Immediate, sign-extend it
                     ALUOp      = `SLT;
              end  
             `SLTIUOPCODE: begin
                   RegDst   = 1'b0;
                   ALUSrc   =  1'b1;
                   MemToReg =  1'b0;
                   RegWrite =  1'b1;
                   MemRead  =  1'b0;
                   MemWrite =  1'b0;
                   Branch   =  1'b0;
                   Jump     =  1'b0;
                   SignExtend =  1'b1; // Immediate, sign-extend it - comparison is unsigned
                   ALUOp =  `SLTU;
             end
             `XORIOPCODE: begin
                 RegDst     =  1'b0;
                 ALUSrc     =  1'b1;
                 MemToReg   =  1'b0;
                 RegWrite   =  1'b1;
                 MemRead    =  1'b0;
                 MemWrite   =  1'b0;
                 Branch     =  1'b0;
                 Jump       =  1'b0;
                 SignExtend =  1'b0; // Zero extended(done in H/W automatically), no sign ext., do not sign-extend
                 ALUOp      = `XOR;
              end          
               // J- Type Instr                       
             `JOPCODE: begin
                   RegDst   =  1'b0;
                   ALUSrc   =  1'b0;
                   MemToReg =  1'b0;
                   RegWrite =  1'b0;
                   MemRead  =  1'b0;
                   MemWrite =  1'b0;
                   Branch   =  1'b0;
                   Jump     =  1'b1;
                   SignExtend =  1'b1; // Does not matter really
                   ALUOp    =  `AND;
              end                                                                                                                                                                                                                                                                                                                                                                              
// Deafault case: all signals are driven x   

            default: begin
                RegDst      =  1'bx;
                ALUSrc      =  1'bx;
                MemToReg    =  1'bx;
                RegWrite    =  1'bx;
                MemRead     =  1'bx;
                MemWrite    =  1'bx;
                Branch      =  1'bx;
                Jump        =  1'bx;
                SignExtend  = 1'bx;
                ALUOp       =  4'bxxxx;
            end
        endcase
    end
endmodule