module proc(Clock, DIN, Run, Resetn, Bus, Done);
	input logic Clock, Run, Resetn;
	input logic [8:0] DIN;
	output logic Done;
	output logic [8:0] Bus;
	
	logic [8:0] RA, RG, IR, R0, R1, R2, R3, R4, R5, R6, R7;
	logic [10:0] Rin; //Rain = 8 //Rgin = 9 //iRin = 10 
	logic [9:0] Rout;
	logic [2:0] I = reg_IR[8:6];
	logic [2:0] mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011;
	logic selULA;
	
	regn reg_0 (Bus, Rin[0], Clock, R0);//R[0]);
	regn reg_1 (Bus, Rin[1], Clock, R1);//R[1]);
	regn reg_2 (Bus, Rin[2], Clock, R2);//R[2]);
	regn reg_3 (Bus, Rin[3], Clock, R3);//R[3]);
	regn reg_4 (Bus, Rin[4], Clock, R4);//R[4]);
	regn reg_5 (Bus, Rin[5], Clock, R5);//R[5]);
	regn reg_6 (Bus, Rin[6], Clock, R6);//R[6]);
	regn reg_7 (Bus, Rin[7], Clock, R7);//R[7]);
	regn reg_A (Bus, Rin[8], Clock, RA);//R[8]);
	regn reg_G (Bus, Rin[9], Clock, RG);//R[9]);
	regn reg_IR (DIN,Rin[10], Clock, IR);//R[10]);
	
	ula AddSub (reg_A, Bus, reg_G, selULA);
	
	dec3to8 decX (reg_IR[5:3], 1'b1, Rin[7:0]);
	dec3to8 decY (reg_IR[2:0], 1'b1, Rout[7:0]);
	
	enum logic [1:0] {T0, T1, T2, T3} state;
	
	
	
	always_ff @(posedge Clock) begin
		if (Resetn && Run) begin 
			unique case (state)
				T0: begin
					Rin[10] <= 1'b1;
					state <= T1;
					Done <= 1'b0;
				end
				
				T1: begin
					unique case(I)
						I == mv: begin
							Bus <= IR[2:0];
							Done <= 1'b1;
						end
						
						I == mvi: begin
							Bus <= IR[2:0];
							Done <= 1'b1;
						end
						
						I == add: begin
							Rin[8] <= 1'b1;
							Bus <= IR[5:3];
							Done <= 1'b0;
						end
						
						I == sub: begin
							Rin[8] <= 1'b1;
							Bus <= IR[5:3];
							Done <= 1'b0;
						end
						default: state <= T0;
					endcase
					
					if (Done) state <= T0;
					else state <= T2;
				end
				T2: begin
					unique case (I)
						I == add: begin
							Rin[9] <= 1'b1;
							Bus <= IR[2:0];
							selULA <= 1'b1;
							Done <= 1'b0;
						end
						
						I == sub: begin
							Rin[9] <= 1'b1;
							Bus <= IR[2:0];
							selULA <= 1'b1;
							Done <= 1'b0;
						end
						default: state <= T0;
					endcase
					//state <= T3;
				end
				
				T3: begin
					unique case(I)
						I == add: begin
						   Rin[9] <= 1'b0;
							Bus <= RG;
							Done <= 1'b1;
						end
						
						I == sub: begin
							Rin[9] <= 1'b0;
							Bus <= RG;
							Done <= 1'b1;
						end
						default: state <= T0;
					endcase
					//state <= T0;
				end
				default: state <= T0;
			endcase	
		end
	end
	
endmodule

module regn(R, Rin, Clock, Q);
	 parameter n = 9;
	 input logic [n-1:0] R;
	 input logic Rin, Clock;
	 output logic [n-1:0] Q;
	 
	 always @(posedge Clock)
	 if (Rin) Q <= R;
endmodule

module dec3to8(W, En, Y);
 input logic [2:0] W;
 input logic En;
 output logic [0:7] Y;

 always @(W or En) begin
	 if (En == 1)
		 case (W)
			 3'b000: Y = 8'b10000000;
			 3'b001: Y = 8'b01000000;
			 3'b010: Y = 8'b00100000;
			 3'b011: Y = 8'b00010000;
			 3'b100: Y = 8'b00001000;
			 3'b101: Y = 8'b00000100;
			 3'b110: Y = 8'b00000010;
			 3'b111: Y = 8'b00000001;
			 default: ;
		 endcase
	 else
		Y = 8'b00000000;
 end
endmodule

module ula (a, b, out, sel);
	input logic [8:0] a;
	input logic [8:0] b;
	input logic sel;
	output logic [8:0] out;
	
	always @(sel)begin
		if(sel) out = a + b;
		else if(!sel) out = a - b;
	end
endmodule
