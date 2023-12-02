module RegisterFile
 #(parameter DATA_WIDTH = 32, parameter DEPTH = 32, parameter ADDRESS_WIDTH = 5)
  (
    BusA, BusB, BusW, RA, RB, RW, RegWr, Clk
  );
  input [DATA_WIDTH-1:0] BusW;       // Write data bus
  output [DATA_WIDTH-1:0] BusA;       // Read data bus A
  output [DATA_WIDTH-1:0] BusB;       // Read data bus B
  input RegWr;                          // Reg write enable
  input Clk;                            // clock
  input [ADDRESS_WIDTH-1:0] RW;            // Write data addr
  input [ADDRESS_WIDTH-1:0] RA;       // Async read data A addr
  input [ADDRESS_WIDTH-1:0] RB;       // Async Read data B addr
  
  //wire tie_reg0 = 0;
  
  // Declare the register file
  reg [DATA_WIDTH-1:0] reg_file [DEPTH-1:0];
  
  // Drive the read outputs
  assign BusA = (RA == 5'b0) ? {DATA_WIDTH{1'b0}} : reg_file[RA];
  assign BusB = (RB == 5'b0) ? {DATA_WIDTH{1'b0}} : reg_file[RB];
  
  // tie the 0the register to 0
  //always @(*) begin
  //  reg_file[0] <= tie_reg0;
  //end

  // Logic for writing the register file
  always @(negedge Clk) begin
    if(RegWr && RW!=0) begin
      reg_file[RW] <= BusW; 
    end
  end
  
  endmodule