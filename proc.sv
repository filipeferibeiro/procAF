module proc(Clock, DIN, Run, Resetn, Bus, Done);
	input logic Clock, Run, Resetn;
	input logic [8:0] DIN;
	output logic Done;
	output logic [8:0] Bus;
	
	//logic [8:0] R [10:0]; Ra = 8 Rg = 9 iR = 10 
	/* Os R sao registradores e os regn tambem sao outros registradores, estamos criando dois conjuntos diferentes de registradores
		Henrique explicou que precisariamos escolher entre um e outro, aconselhou usar o regn devido a logica do modulo, caso
		a gente fosse usar o R teriamos que fazer as instruçoes do modulo regn dentro da maquina de estados.
	*/
	
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

/*module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	input [8:0] DIN;
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;
	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
	reg [8:0] RA, RG, IR, R0, R1, R2, R3, R4, R5, R6, R7;
	reg [7:0] Rin, Xreg, Yreg;
	reg Ain, Gin, AddSub, IRin;
	reg [9:0] muxC;
	reg [2:0] I; 
	reg [2:0] Tstep_D, Tstep_Q;
 //. . . declaração de variáveis

 assign I = IR[8:6];
 dec3to8 decX (IR[5:3], 1'b1, Xreg);
 dec3to8 decY (IR[2:0], 1'b1, Yreg);
 

 // Controle de estados do FSM
 always @(Tstep_Q, Run, Done) begin
	 case (Tstep_Q)
	 T0: // Os dados são carregados no IR nesse passo
		if (!Run) Tstep_Q = T0;
		else Tstep_Q = T1;
	 T1: 
		if(!Run) Tstep_Q = T0;
		else Tstep_Q = T2;
	 T2:
		if(!Run) Tstep_Q = T0;
		else Tstep_Q = T3;
	 T3:
		if(!Run) Tstep_Q = T0;
		else Tstep_Q = T1;
	 default: ;
	 endcase
 end


 // Controle das saídas da FSM
 always @(Tstep_Q or I or Xreg or Yreg) begin
 //. . . especifique os valores iniciais
	 case (Tstep_Q)
		 T0: // Armazene DIN no registrador IR no passo 0
		 begin
			IRin = 1'b1;
		 end

		 T1: // Defina os sinais do passo 1
		 case (I)
			3'b000: begin
				Rin = Xreg;
				Done = 1'b1;
			end
			3'b001: begin
				Rin = Xreg;
				Done = 1'b1;
			end
			3'b010: begin
				Ain = 1'b1;
				Ain = 1'b0;
			end
			3'b011: begin
				Ain = 1'b1;
				Ain = 1'b0;
			end
			default: ;
		 endcase
		 T2: // Defina os sinais do passo 2
		 case (I)
			3'b010: begin
				Gin = 1'b1;
			end
			3'b011: begin
				Ain = 1'b1;
				
			end
			default: ;
		 endcase

		 T3: // Defina os sinais do passo 3
		 case (I)
			3'b010: begin
				Rin = Xreg;
				Done = 1'b1;
			end
			3'b011: begin
				Rin = Xreg;
				Done = 1'b1;
			end
			default: ;
		 endcase
		 default: ;
	 endcase
 end


 // Controle os flip-flops do FSM
 always @(posedge Clock)
	 //if (!Resetn)
	 //. . .
	 //else 
	 begin
		 regn reg_0 (BusWires, Rin[0], Clock, R0);
		 regn reg_1 (BusWires, Rin[1], Clock, R1);
		 regn reg_2 (BusWires, Rin[2], Clock, R2);
		 regn reg_3 (BusWires, Rin[3], Clock, R3);
		 regn reg_4 (BusWires, Rin[4], Clock, R4);
		 regn reg_5 (BusWires, Rin[5], Clock, R5);
		 regn reg_6 (BusWires, Rin[6], Clock, R6);
		 regn reg_7 (BusWires, Rin[7], Clock, R7);
		 regn reg_A (BusWires, Ain, Clock, RA);
		 regn reg_G (BusWires, Gin, Clock, RG);
		 regn reg_IR (DIN, IRin, Clock, IR);
		 
		 ula ula_0 (RA, BusWires, RG, AddSub);
		 
		 
	 end
	 //. . . Instancie outros registradores e o somador/subtrator
	// . . . definição do barramento

endmodule

module dec3to8(W, En, Y);
 input [2:0] W;
 input En;
 output [0:7] Y;
 
 reg [0:7] Y;

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

module regn(R, Rin, Clock, Q);
 parameter n = 9;
 input [n-1:0] R;
 input Rin, Clock;
 output [n-1:0] Q;
 reg [n-1:0] Q;
 
 always @(posedge Clock)
 if (Rin) Q <= R;
endmodule

module ula (a, b, out, sel);
	input [8:0] a;
	input [8:0] b;
	input sel;
	output [8:0] out;
	reg [8:0] out;
	
	always @(sel)begin
		if(sel) out = a + b;
		else if(!sel) out = a - b;
	end
endmodule
*/












/*


module proc (DIN, Resetn, Clock, Run, Done, BusWires);
  input [15:0] DIN;
  input Resetn, Clock, Run;
  output reg Done;
  output reg [15:0] BusWires;

  //declare variables
  reg IRin, DINout, Ain, Gout, Gin, AddSub;
  reg [7:0] Rout, Rin;
  wire [7:0] Xreg, Yreg;
  wire [1:9] IR;
  wire [1:3] I;
  reg [9:0] MUXsel;
  wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, result;
  wire [15:0] A, G;
  wire [1:0] Tstep_Q;

  wire Clear = Done || ~Resetn;
  upcount Tstep (Clear, Clock, Tstep_Q);
  assign I = IR[1:3];
  dec3to8 decX (IR[4:6], 1'b1, Xreg);
  dec3to8 decY (IR[7:9], 1'b1, Yreg);
  
  always @(Tstep_Q or I or Xreg or Yreg)
  begin
    //specify initial values
    IRin = 1'b0;
    Rout[7:0] = 8'b00000000;
    Rin[7:0] = 8'b00000000;
    DINout = 1'b0;
    Ain = 1'b0;
    Gout = 1'b0;
    Gin = 1'b0;
    AddSub = 1'b0;

    Done = 1'b0;

    case (Tstep_Q)
      2'b00: // store DIN in IR in time step 0
      begin
        IRin = 1'b1; // should this be ANDed with Run?
      end
      2'b01: //define signals in time step 1
        case (I)
          3'b000:
          begin
            Rout = Yreg;
            Rin = Xreg;
            Done = 1'b1;
          end
          3'b001:
          begin
            DINout = 1'b1;
            Rin = Xreg;
            Done = 1'b1;
          end
          3'b010:
          begin
            Rout = Xreg;
            Ain = 1'b1;
          end
          3'b011:
          begin
            Rout = Xreg;
            Ain = 1'b1;
          end
			 default: ;
        endcase
      2'b10: //define signals in time step 2
        case (I)
          3'b010:
          begin
            Rout = Yreg;
            Gin = 1'b1;
          end
          3'b011:
          begin
            Rout = Yreg;
            Gin = 1'b1;
            AddSub = 1'b1;
          end
			 default: ;
        endcase
      2'b11: //define signals in time step 3
        case (I)
          3'b010:
          begin
            Gout = 1'b1;
            Rin = Xreg;
            Done = 1'b1;
          end
          3'b011:
          begin
            Gout = 1'b1;
            Rin = Xreg;
            Done = 1'b1;
          end
			 default: ;
        endcase
		default: ;
    endcase
  end

  //instantiate registers and the adder/subtracter unit
  regn reg_0 (BusWires, Rin[0], Clock, R0);
  regn reg_1 (BusWires, Rin[1], Clock, R1);
  regn reg_2 (BusWires, Rin[2], Clock, R2);
  regn reg_3 (BusWires, Rin[3], Clock, R3);
  regn reg_4 (BusWires, Rin[4], Clock, R4);
  regn reg_5 (BusWires, Rin[5], Clock, R5);
  regn reg_6 (BusWires, Rin[6], Clock, R6);
  regn reg_7 (BusWires, Rin[7], Clock, R7);

  regn reg_IR (DIN, IRin, Clock, IR);
  defparam reg_IR.n = 9;
  regn reg_A (BusWires, Ain, Clock, A);
  regn reg_G (result, Gin, Clock, G);

  addsub AS (~AddSub, A, BusWires, result);

  //define the bus
  always @ (MUXsel or Rout or Gout or DINout)
  begin
    MUXsel[9:2] = Rout;
    MUXsel[1] = Gout;
    MUXsel[0] = DINout;
    
    case (MUXsel)
      10'b0000000001: BusWires = DIN;
      10'b0000000010: BusWires = G;
      10'b0000000100: BusWires = R0;
      10'b0000001000: BusWires = R1;
      10'b0000010000: BusWires = R2;
      10'b0000100000: BusWires = R3;
      10'b0001000000: BusWires = R4;
      10'b0010000000: BusWires = R5;
      10'b0100000000: BusWires = R6;
      10'b1000000000: BusWires = R7;
		default: ;
    endcase
  end

endmodule



module addsub (
	add_sub,
	dataa,
	datab,
	result);

	input	  add_sub;
	input	[15:0]  dataa;
	input	[15:0]  datab;
	output	[15:0]  result;

	wire [15:0] sub_wire0;
	wire [15:0] result = sub_wire0[15:0];

	lpm_add_sub	lpm_add_sub_component (
				.dataa (dataa),
				.add_sub (add_sub),
				.datab (datab),
				.result (sub_wire0)
				// synopsys translate_off
				,
				.aclr (),
				.cin (),
				.clken (),
				.clock (),
				.cout (),
				.overflow ()
				// synopsys translate_on
				);
	defparam
		lpm_add_sub_component.lpm_direction = "UNUSED",
		lpm_add_sub_component.lpm_hint = "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_add_sub_component.lpm_representation = "UNSIGNED",
		lpm_add_sub_component.lpm_type = "LPM_ADD_SUB",
		lpm_add_sub_component.lpm_width = 16;


endmodule

module upcount(Clear, Clock, Q);
  input Clear, Clock;
  output [1:0] Q;
  reg [1:0] Q;

  always @(posedge Clock)
    if (Clear)
      Q <= 2'b0;
    else
      Q <= Q + 1'b1;
endmodule




module dec3to8(W, En, Y);
  input [2:0] W;
  input En;
  output [0:7] Y;
  reg [0:7] Y;

  always @(W or En)
  begin
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
		  default: Y = 8'b00000000;
      endcase
    else
      Y = 8'b00000000;
  end
endmodule




module regn(R, Rin, Clock, Q);
  parameter n = 9;
  input [n-1:0] R;
  input Rin, Clock;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge Clock)
    if (Rin)
      Q <= R;
endmodule
*/































