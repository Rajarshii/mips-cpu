`timescale 1ns / 1ps

module DataMemory
    #(parameter DATA_WIDTH = 32, parameter DEPTH = 64, parameter ADDRESS_WIDTH = 6)
    (
    ReadData,
    Address,
    WriteData,
    MemoryRead,
    MemoryWrite,
    Clock
    );
    input [ADDRESS_WIDTH-1:0] Address;
    input [DATA_WIDTH-1:0] WriteData;
    input MemoryRead;
    input MemoryWrite;
    input Clock;
    output reg [DATA_WIDTH-1:0] ReadData;
    
    // Create the memory array
    reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
    
    always @(posedge Clock) begin
      if(MemoryRead == 1'b1) begin
        ReadData <= mem[Address];
      end
    end
    always @(negedge Clock) begin
      if(MemoryWrite == 1'b1) begin
        mem[Address] <= WriteData;
       end
    end
    
    
endmodule
