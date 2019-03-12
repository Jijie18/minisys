`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset, opcplus4);
    output[31:0] read_data_1;               // ????????
    output[31:0] read_data_2;               // ????????
    input[31:0]  Instruction;               // ????????
    input[31:0]  read_data;   				//  ?DATA RAM or I/O port?????
    input[31:0]  ALU_result;   				// ?????????????????????32?
    input        Jal;                               //  ??????????JAL?? 
    input        RegWrite;                  // ??????
    input        MemtoReg;              // ??????
    input        RegDst;                    //  ??????
    output[31:0] Sign_extend;               // ???????????32????
    input		 clock,reset;                // ?????
    input[31:0]  opcplus4;                 // ???????JAL??
        reg [31:0] register[0:31];
    wire[31:0] read_data_1;
    wire[31:0] read_data_2;
    	   	  
    reg[4:0] write_register_address;        // ????????
    reg[31:0] write_data;                   // ???????????

    wire[4:0] read_register_1_address;    // ????????????rs?
    wire[4:0] read_register_2_address;     // ????????????rt?
    wire[4:0] write_register_address_1;   // r-form???????????rd?
    wire[4:0] write_register_address_0;    // i-form??????????(rt)
    wire[15:0] Instruction_immediate_value;  // ???????
    wire[5:0] opcode;                       // ???
    
    assign opcode = Instruction[31:26];	//OP
    assign read_register_1_address = Instruction[25:21];//rs 
    assign read_register_2_address = Instruction[20:16];//rt 
    assign write_register_address_1 = Instruction[15:11];// rd(r-form)
    assign write_register_address_0 = Instruction[20:16];//rt(i-form)
    assign Instruction_immediate_value = Instruction[15:0];//data,rladr(i-form)


   wire sign;                                            // ??????

    assign sign = Instruction[15];
    assign Sign_extend[31:0] = ((opcode==6'b001100)     // andi
                          ||(opcode==6'b001101)             // ori
                          ||(opcode==6'b001110)             // xori
                          ||(opcode==6'b001011))            // sltiu
                          ? {16'h0000,Instruction_immediate_value[15:0]}  // 立即数0扩展
                          :{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,Instruction_immediate_value[15:0]};  //立即数符号扩展
    
    assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];
    
    always @* begin                                            //这个进程指定不同指令下的目标寄存器
            if((RegDst==1) && (Jal==0)) //r-form jal (pc+1 > sp[$Rlast])
                write_register_address = write_register_address_1; //RD(15-11)  R-form指令
            else if((RegDst==0) && (Jal==1))
                write_register_address = 5'b11111;                 //JAL 指令需要将下个指令的地址给最后一个寄存器
            else  write_register_address  = write_register_address_0;//i-form rt(20-16)
        end
        
        always @* begin  //这个进程基本上是实现结构图中右下的多路选择器 ,lw $5,$3(100)
            if((MemtoReg==0) && (Jal== 0)) begin               //不是LW and IO, 也不是JAL指令
                write_data = ALU_result[31:0];
            end else if((MemtoReg==0) && (Jal== 1)) begin      //不是LW，但是是jal,下个地址存$15
                write_data = opcplus4;
            end else begin
                write_data = read_data;                            //是LW指令
            end
        end
    
    integer i;
    always @(posedge clock) begin       // ?????????
        if(reset==1) begin              // ???????
            for(i=0;i<32;i=i+1) register[i]<= i;
        end else if(RegWrite==1) begin  // ?????0???0
         register[write_register_address]<=write_data;
         register[0]<=0;

        end
    end
endmodule