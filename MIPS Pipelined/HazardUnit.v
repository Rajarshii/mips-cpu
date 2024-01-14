`timescale 1ns / 1ps

module HazardUnit(PCWrite, IFWrite, Bubble, addrSel, Branch, ALUZero, Jump, currRs, currRt, prevRt, UseShamt, UseImmed, memReadX ,Reset_L, CLK);
 //                   );
    // Inputs
	input			Branch;
	input			ALUZero;
	input			Jump;
	input	[4:0]	currRt;
	input	[4:0]	currRs;
	input	[4:0]	prevRt;
	input			Reset_L;
	input			CLK;
	input           UseShamt;
	input           UseImmed;
	input           memReadX;
	// Outputs
	output reg		PCWrite;
	output reg		IFWrite;
	output reg		Bubble;
	output reg   [1:0]   addrSel;
	
	/*state definition for FSM*/
	parameter NOHAZARD  = 3'b000;
    parameter JUMP      = 3'b001;
    parameter BRANCH0   = 3'b010;
    parameter BRANCH1   = 3'b011;				 
	
	/*internal signals*/
	wire cmp1;
	
	/*internal state*/
	reg [2:0] PS, NS; // PS = Present State, NS = Next State
	reg [4:0] rw1; //rw history registers
	
	reg LdHazard;
	
	// Generate load hazard
	always @(*) begin
        LdHazard = 1'b0;
        if(prevRt!=0 & memReadX) begin // Rt is non zero and a memory read - load is happening
           if(~UseShamt & (currRs == prevRt))
               LdHazard = 1'b1;
           else if(~UseImmed & (currRt == prevRt)) 
               LdHazard = 1'b1;
           else LdHazard = 1'b0; // All other cases - no load hazard
        end
        else begin
           LdHazard = 1'b0;
        end
	end
	
	//assign LdHazard = ((((currRs == prevRt) && (UseShamt == 0)) || ((currRt == prevRt) && (UseImmed == 0))) && memReadX && (prevRt!=0)) ? 1 : 0;

	
	always @(negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			PS <= NOHAZARD; // Default state
		end
		else begin
			PS <= NS; // Update the present state
		end
	end

	/*FSM next state and output logic*/
	always @(*) begin //combinatory logic
		case(PS)
			NOHAZARD: begin 
				if(Jump== 1'b1) begin //prioritize jump
                    NS = JUMP;
                    IFWrite = 1'b0;
                    PCWrite = 1'b1;
                    Bubble = 1'b0;
                    addrSel = 2'b01; // RD : Check this once... 
				end
				else if(Branch) begin
				    NS = BRANCH0;
                    IFWrite = 1'b0;
                    PCWrite = 1'b0;
                    Bubble = 1'b0;
                    addrSel = 2'b00; // RD : Check this once...				    
				end
				else if(LdHazard) begin
				    NS = NOHAZARD;
				    IFWrite = 1'b0;
				    PCWrite = 1'b0;
				    Bubble  = 1'b1;
				    addrSel = 2'b00;
				end
				else begin
				    NS = NOHAZARD;
				    IFWrite = 1'b1;
				    PCWrite = 1'b1;
				    Bubble  = 1'b0;
				    addrSel = 2'b00; // RD : Revisit this
				end
			end
			JUMP : begin
			    NS = NOHAZARD;
                IFWrite = 1'b1;
                PCWrite = 1'b1;
                Bubble  = 1'b1;
                addrSel = 2'b00; // RD : Revisit this			 
			end
			BRANCH0: begin
			// Not taken branch
			if(~ALUZero) begin
			    NS = NOHAZARD;
                IFWrite = 1'b1;
                PCWrite = 1'b1;
                Bubble  = 1'b0;
                addrSel = 2'b00; // RD : Revisit this
            end
            else begin
                NS = BRANCH1;
                IFWrite = 1'b0;
                PCWrite = 1'b1;
                Bubble  = 1'b1;
                addrSel = 2'b10; // RD : Revisit this                
            end				 
			end			
			BRANCH1 : begin
			    NS = NOHAZARD;
                IFWrite = 1'b1;
                PCWrite = 1'b1;
                Bubble  = 1'b1;
                addrSel = 2'b00; // RD : Revisit this			     
			end
			default: begin
				NS = NOHAZARD;
				PCWrite = 1'bx; // Do we need these # delays?
				IFWrite = 1'bx;
				Bubble  = 1'bx;
				addrSel = 2'bxx;
			end
		endcase
	end
endmodule

