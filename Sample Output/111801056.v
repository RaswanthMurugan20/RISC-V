`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 21.01.2020 04:42:05
// Design Name:
// Module Name: lab2
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ALU32(input clk);

wire [2:0] funct3;
wire [6:0] funct7,opcode;
wire [4:0]  rs1,rs2,rd;
wire [63:0]op1,op2;
wire [63:0] alu,ans;
wire [31:0] data;
wire [63:0] pc;
wire [63:0]bt;
wire [63:0]finalimm;
wire Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite;
wire [1:0]ALUop;
wire stop;
integer s = 3'b000;




always@(posedge clk)
begin
s = s+1;
if (s == 3'b101)
begin
s = 3'b000;
end

end

wire [2:0] g = s;


Reader a1(clk,pc,g,data,stop);
Decoder b1(clk,g,data,funct3,funct7,opcode,rs1,rs2,rd);
Control h1(clk,g,data,Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite,ALUop);
Register c1(clk,RegWrite,g,rs1,rs2,rd,ans,op1,op2);
Instruction d1(clk,op1,op2,funct7,opcode,funct3,rs2,rd,ALUSrc,pc,alu);
Datamemory e1(clk,g,alu,opcode,op2,MemToReg,MemWrite,MemRead,rd,ans);
PC f1(g,clk,stop,bt,alu,Branch,opcode,funct3,finalimm,op1,pc);
Immediate g1(clk,g,pc,funct3,funct7,opcode,rs1,rs2,rd,data,finalimm,bt);


endmodule

//incomplete mux input not added



module Reader(input clk,input[63:0] pc,input[2:0] s,output reg [31:0] data,output reg stop);
  integer file,scan;
  integer i,j;
  reg [31:0] instruction [31:0];
  
  initial begin
 
       file = $fopen("input.txt","r");
       for (i = 0;i<15;i = i+1)//depending on number of instruction lines
       begin
        scan = $fscanf(file,"%b\n",instruction[i]);  
       end
       j = i;
       stop = 1'b0;
       $fclose(file);
 end
 
 
  always@(posedge clk)
  begin
 
  if (s == 3'b000)
  begin
    if(pc/4 >= j)
        stop = 1'b1;
    else
        data = instruction[pc>>2];
  end

 
  end
  
   
 
 endmodule
 
module Control(
 input clk,
 input [2:0]s,
 input [31:0] data,
 output reg Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite,
 output reg [1:0] ALUop

);


always @(data)
begin
    if (data[6:0] == 7'b1100011)
    begin
      Branch = 1; 
      MemRead = 0;
      MemToReg = 0;
      MemWrite = 0;
      ALUSrc = 0;
      RegWrite = 0;
      ALUop = 2'b01;
      
    end
    else if (data[6:0] == 7'b0000011)
    begin
      Branch = 0;
      MemRead = 1;
      MemToReg = 1;
      MemWrite = 0;
      ALUSrc = 1;
      RegWrite = 1;
      ALUop = 2'b00;
    
    end
    else if (data[6:0] == 7'b0110011)
    begin
      Branch = 0;
      MemRead = 0;
      MemToReg = 0;
      MemWrite = 0;
      ALUSrc = 0;
      RegWrite = 1;
      ALUop = 2'b10;
    end
    else if (data[6:0] == 7'b0100011)
    begin
      Branch = 0;
      MemRead = 0;
      MemToReg = 0;
      MemWrite = 1;
      ALUSrc = 1;
      RegWrite = 0;
      ALUop = 2'b00;
    end
    
    else if(data[6:0] == 7'b0010011)
    begin
      Branch = 0;
      MemRead = 0;
      MemToReg = 0;
      MemWrite = 1;
      ALUSrc = 1;
      RegWrite = 1;
      ALUop = 2'b00;
    end
    
end 





endmodule

 
 
module Decoder(input clk,input[2:0] s,input[31:0] data,output reg[2:0] funct3,output reg[6:0] funct7,opcode,output reg[4:0]  rs1,rs2,rd);
 
  always @(posedge clk)
  begin
 
  if (s == 3'b001)
  begin
    
    funct7 = data[31:25];
    rs2 = data[24:20];
    rs1 = data[19:15];
    funct3 = data[14:12];
    rd = data[11:7];
    opcode = data[6:0];
   
    
  end
  end
 
endmodule
 
module Immediate(

 input clk,
 input [2:0]s,
 input [63:0] pc,
 input [2:0] funct3,
 input [6:0] funct7,opcode,
 input [4:0]  rs1,rs2,rd,
 input [31:0] data,
 output reg[63:0] finalimm,
 output reg [63:0] bt 

);

reg [11:0] imm1;
reg [19:0] imm2;

always @(posedge clk)
begin
  if (s == 3'b010)
  begin
    if(opcode == 7'b1100011)
        begin
      
            imm1 = {funct7[6],rd[0],funct7[5:0],rd[4:1],1'b0};
            finalimm = $signed(imm1);
        end
    else if(opcode == 7'b0010011)
        begin
    
            imm1 = {funct7,rs2};
            finalimm = $signed(imm1);
        end
     else if(opcode == 7'b1101111)
         begin
             
             imm2  = {data[31],data[19:12],data[20],data[30:21],1'b0};
             finalimm = $signed(imm2);
         end
     else if(opcode == 7'b1100111)
         begin
            
            imm1  = {funct7,rs2};
            finalimm = $signed(imm1);

         end       
      //bt = pc+({52'b0000000000000000000000000000000000000000000000000000,imm}<
      bt = finalimm+pc;
    
  end
end



endmodule


 
module Register(input clk,input RegWrite,input[2:0] s,input [4:0] rs1,rs2,rd,input[63:0]ans,output reg[63:0]op1,op2);

  reg [63:0] registers [31:0];
  integer file,scan;
  integer i;
 
 
 initial begin
 
       file = $fopen("registers.txt","r");
       for (i = 0;i<32;i = i+1)
       begin
        scan = $fscanf(file,"%b\n",registers[i]);  
       end
       $fclose(file);
 end
 
 
 
 
  always @(posedge clk)
  begin
       
   
      if(s == 3'b010)
      begin
        op1 = registers[rs1];
        op2 = registers[rs2];
        
      end
      
       
       
       
       if(RegWrite == 1'b1 && s== 3'b100 && rd !=0)
        registers[rd] = ans;
        begin
            file = $fopen("C:\\Users\\student\\Desktop\\registers.txt","w");
        for (i = 0;i<32;i = i+1)
        begin
            $fwrite(file,"%b\n",registers[i]);
        end
        $fclose(file);
       end
       
     
  end
 
 
 
   
endmodule


module Instruction(
     
     input clk,
     input [63:0] a,b,
     input [6:0] f7,opcode,
     input [2:0] f3,
     input [4:0] rs2,
     input [4:0] rd,
     input ALUsrc,
     input [63:0]pc,
     output reg [63:0] o
     
    );
   
   
    reg[63:0] b1;
    reg[9:0] f71;
    
    
  always @ (*)
 
  begin
  
    if(opcode == 7'b0010011)
    begin
        b1 = $signed({f7,rs2});
        f71 = f3;
        if(f71 == 3'b000) assign o = a+b1;
        else if(f71 == 3'b110) assign o = a|b1;
        else if(f71 == 3'b111) assign o = a&b1;
        else if(f71 == 3'b100) assign o = a^b1;
        else if(f7 == 7'b0000000 && f71 == 3'b001) assign o = a<<rs2;
        else if(f7 == 7'b0000000 && f71 == 3'b101) assign o = a>>rs2;
        else if(f7 == 7'b0100000 && f71 == 3'b101) assign o = a>>>rs2;
        
    end
    else if(opcode == 7'b0110011)
    begin
        b1 = b;
        f71 = {f7,f3};
        if(f71 == 10'b0000000000) assign o = a+b1;
        else if(f71 == 10'b0000001000) assign o = a*b1;
        else if(f71 == 10'b0100000000) assign o = a-b1;
        else if(f71 == 10'b0000000110) assign o = a|b1;
        else if(f71 == 10'b0000000111) assign o = a&b1;
        else if(f71 == 10'b0000000100) assign o = a^b1;
        else if(f71 == 10'b0000000001) assign o = a<<b1;
        else if(f71 == 10'b0000000101) assign o = a>>b1;
        else if(f71 == 10'b0100000101) assign o = a>>>b1;
    end
    else if(opcode == 7'b0000011)
    begin
        b1 = $signed({f7,rs2});
        f71 = 7'b0000000;
        assign o = a+b1; 
    end
    else if(opcode == 7'b0100011)
    begin
        b1 = $signed({f7,rd});
        f71 = 7'b0000000;
        assign o = a+b1; 
    end
    else if(opcode == 7'b1100011)
    begin
      assign o = a-b;
    end
    
    else if(opcode == 7'b1101111 || opcode == 7'b1100111)
    begin
      assign o = pc + 4;
    end  

end    
endmodule
 
module PC(
input [2:0] s,
input clk,stop,
input [63:0] bt,
input [63:0]alu,
input Branch,
input [6:0]opcode,
input [2:0]funct3,
input [63:0] finalimm,
input [63:0] a,
output reg [63:0] pc

);



initial begin
    pc = 64'b0;
end

always @(posedge clk)
begin
    if (s == 3'b011 && stop != 1'b1)
    begin
        if (opcode == 7'b1100011)
        begin
            if(funct3 == 3'b000 && alu == 1'b0 && Branch == 1'b1)
            begin
              $display("equality"); 
              pc = bt;   
            end
            else if(funct3 == 3'b001 && !alu == 1'b0 && Branch == 1'b1)
            begin
               pc = bt; 
            end
            else
                pc = pc + 4;
        end
        else if(opcode == 7'b1101111)
        begin
           pc = bt;
        end
        
        else if(opcode == 7'b1100111)
        begin
          pc = a + finalimm;
        end     
        else
        begin
            pc = pc + 4; 
        end
    end
end
endmodule



module Datamemory(
 
 input clk,
 input [2:0] s, 
 input[63:0] aluop,
 input[6:0] opcode,
 input[63:0] op2,
 input MemToReg,
 input MemWrite,
 input MemRead,
 input [4:0] rd,
 output reg [63:0] ans
 
);

integer file,scan,i;
reg [63:0] memory [63:0];

initial begin
 
       
       file = $fopen("C:\\Users\\student\\Desktop\\memory.txt","r");
       for (i = 0;i<64;i = i+1)
       begin
        scan = $fscanf(file,"%b\n",memory[i]);  
       end
       $fclose(file);
     
end
 
always @ (posedge clk)
begin
   
        if(s == 3'b011)
        begin
            if (opcode == 7'b0000011 && MemToReg == 1 && MemRead == 1)
            begin
            $display("%d %d",memory[aluop],aluop);
            ans = memory[aluop];
            end
            else if ( (opcode == 7'b0010011 || opcode == 7'b0110011) && MemToReg == 0 )
        begin
          ans = aluop;
        end
        
        else if (opcode == 7'b0100011 && MemWrite == 1)
        begin
          memory[aluop] = op2;
 
          file = $fopen("C:\\Users\\student\\Desktop\\memory.txt","w");
          for (i = 0;i<64;i = i+1)
          begin
          $fwrite(file,"%b\n",memory[i]);
          end
          $fclose(file);
        end
        else if (opcode == 7'b1101111 || opcode == 7'b1100111)
        begin
          ans = aluop;
        end
        end
   
end
 
endmodule


