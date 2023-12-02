`timescale 1ns / 1ps

`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110
module ALU(BusW, Zero, BusA, BusB, ALUCtrl
    );
input wire [31:0] BusA, BusB;
output reg [31:0] BusW;
input wire [3:0] ALUCtrl ;
output wire Zero ;

wire less;
wire [63:0] Bus64;
assign Zero = (BusW == 0) ? 1'b1 : 1'b0;
assign less = ({~BusA[31],BusA[31:0]} < {~BusB[31],BusB[31:0]}  ? 1'b1 : 1'b0);
assign Bus64 = 64'b0; 
always@(*)begin

        case (ALUCtrl)
        `AND:   BusW = BusA & BusB;
        `OR:    BusW = BusA | BusB;
        `ADD:   BusW = BusA + BusB;
        `ADDU:  BusW = BusA + BusB;
        `SLL:   BusW = BusB << BusA; // Updated this : BusB shifts by BusA
        `SRL:   BusW = BusB >> BusA; // Updated this: Bus B shifts by BusA
        `SUB:   BusW = BusA - BusB;
        `SUBU:  BusW = BusA - BusB;
        `XOR:   BusW = BusA ^ BusB;
        `NOR:   BusW = ~(BusA | BusB);
        `SLTU:  BusW = (BusA < BusB) ? 32'b1 : 32'b0;
        `SLT:   BusW = (less);
        `SRA:   BusW = ($signed(BusB) >>> BusA); // Updated this: Bus B shifts by Bus A now
        `LUI:   BusW = {BusB[15:0] , 16'b0};
        default: BusW = 32'bx;
        endcase
end
endmodule
