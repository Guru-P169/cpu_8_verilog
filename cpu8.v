module alu(input [7:0]A,input[7:0]B,input[1:0]ALUOp,output reg [7:0]Result);

always@(*)begin
	case(ALUOp)
	2'b00:Result =A+B;
	2'b01:Result =A-B;
	default:Result =8'b0; 
	endcase
end

endmodule

module reg_file(input clk,input we,input [1:0]rs1,rs2,rd,input [7:0]wd,output [7:0] rd1,rd2);

reg [7:0]R[3:0];

assign rd1=R[rs1];
assign rd2=R[rs2];

always@(posedge clk)
	begin
	if(we)
	R[rd]<=wd;
	end
	
endmodule


module pc(input reset,input clk ,input [7:0]pc_next,output reg [7:0]pc);

always@(posedge clk)
begin
   if(reset)
		pc<=0;
	else
		pc<=pc_next;
end

endmodule


module instr_mem(input [7:0]addr,output [15:0]instr);

reg [15:0]memory[255:0];

initial
	begin
	memory[0]=16'b0010_01_00_00100000;  //load r1  [20]
	memory[1]=16'b0010_10_00_00100001;//load r2  [21]
	memory[2]=16'b0000_01_10_00000000;//add r1,r2
	memory[3]=16'b0011_01_00_00100010;//store r1  [22]
	memory[4]=16'b0100_00_00_00000000;//jump 0
	
	end
 
assign instr =memory[addr];
endmodule


module data_mem(input clk ,input we,input [7:0]addr,input [7:0]wd,output [7:0]rd);

reg [7:0]memory[255:0];

initial begin
    memory[8'h20] = 8'd5;   //  r1 value
    memory[8'h21] = 8'd3;   //  r2 value
end
assign rd=memory[addr];

always@(posedge clk)
	begin
	if(we)
		memory[addr]<=wd;
	
	end
	

endmodule
	

module control_unit(input [3:0]opcode, output reg RegWrite,output reg MemWrite, output reg MemRead,output reg [1:0]ALUOp,output reg ResultSrc,output reg PCSrc);

always@(*)
	begin
		case(opcode)
		4'b0000:begin//add
					RegWrite=1;
					MemWrite=0;
					MemRead=0;
					ALUOp=2'b00;
					ResultSrc=0;
					PCSrc=0;
					end
		4'b0001:begin//sub
					RegWrite=1;
					MemWrite=0;
					MemRead=0;
					ALUOp=2'b01;
					ResultSrc=0;
					PCSrc=0;
					end
		4'b0010:begin//load
					RegWrite=1;
					MemWrite=0;
					MemRead=1;
					ALUOp=2'b00;
					ResultSrc=1;
					PCSrc=0;
					end
		4'b0011:begin//store
					RegWrite=0;
					MemWrite=1;
					MemRead=0;
					ALUOp=2'b00;
					ResultSrc=0;
					PCSrc=0;
					end
		4'b0100:begin//jump
					RegWrite=0;
					MemWrite=0;
					MemRead=0;
					ALUOp=2'b00;
					ResultSrc=0;
					PCSrc=1;
					end
		 default: begin
            RegWrite = 0;
            MemRead  = 0;
            MemWrite = 0;
            ALUOp    = 0;
            ResultSrc = 0;
            PCSrc = 0;
				end
		endcase
	end

endmodule



module cpu8(input clk,input reset);

wire [7:0] pc,pc_next,pc_plus1;
wire [15:0]instr;

wire [3:0] opcode;
wire [1:0] rs,rd;
wire [7:0] addr;

wire[7:0] regA,regB;
wire [7:0] alu_result;
wire [7:0] mem_data;
wire [7:0] write_data;

wire RegWrite,MemRead,MemWrite;
wire [1:0] ALUOp;
wire ResultSrc,PCSrc;

assign opcode=instr[15:12];
assign rd=instr[11:10];
assign rs=instr[9:8];
assign addr=instr[7:0];

assign pc_plus1=pc+1;
assign pc_next=(PCSrc)?addr:pc_plus1;

pc PC(.clk(clk),.reset(reset),.pc_next(pc_next),.pc(pc));

instr_mem IM(.addr(pc),.instr(instr));

control_unit CU(.opcode(opcode),.RegWrite(RegWrite),.MemWrite(MemWrite),.MemRead(MemRead),.ALUOp(ALUOp),.ResultSrc(ResultSrc),.PCSrc(PCSrc));

reg_file RF(.clk(clk),.we(RegWrite),.rs1(rd),.rs2(rs),.rd(rd),.wd(write_data),.rd1(regA),.rd2(regB));

alu ALU(.A(regA),.B(regB),.ALUOp(ALUOp),.Result(alu_result));

data_mem DM(.clk(clk) ,.we(MemWrite),.addr(addr),.wd(regA),.rd(mem_data));

assign write_data =(ResultSrc)?mem_data:alu_result;

endmodule

