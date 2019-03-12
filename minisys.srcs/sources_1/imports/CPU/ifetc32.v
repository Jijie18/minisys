`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,clock,reset,opcplus4);
    output[31:0] Instruction;			// ���ָ�����ģ��
    output[31:0] PC_plus_4_out;         // (pc+4)��ִ�е�Ԫ
    input[31:0]  Add_result;            // ����ִ�е�Ԫ,�������ת��ַ
    input[31:0]  Read_data_1;           // �������뵥Ԫ��jrָ���õĵ�ַ
    input        Branch;                // ���Կ��Ƶ�Ԫ
    input        nBranch;               // ���Կ��Ƶ�Ԫ
    input        Jmp;                   // ���Կ��Ƶ�Ԫ
    input        Jal;                   // ���Կ��Ƶ�Ԫ
    input        Jrn;                   // ���Կ��Ƶ�Ԫ
    input        Zero;                  //����ִ�е�Ԫ
    input        clock,reset;           //ʱ���븴λ
    output[31:0] opcplus4;              // JALָ��ר�õ�PC+4
    
    
    wire[31:0]   PC_plus_4;
    reg[31:0]	  PC;
    reg[31:0]    next_PC;               // ����ָ���PC����һ����PC+4)
    reg[31:0]    opcplus4;
    
   //����64KB ROM��������ʵ��ֻ�� 64KB ROM
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // input wire [13 : 0] addra
        .douta(Instruction)         // output wire [31 : 0] douta
    );
    
    assign PC_plus_4_out = PC_plus_4[31:0];  //  PC��4�͵�ִ�е�Ԫ���Ա�ִ�е�Ԫ�ڱ�Ҫ��ʱ�����ADDRESULT
    assign PC_plus_4[31:2] = PC[31:2]+1;     //  �˴���1ʵ�����ǣ�4����Ϊ�����2λʼ��Ϊ00����1����D2λ��
    assign PC_plus_4[1:0] = 2'b00;

    always @* begin                          // beq $n ,$m if $n=$m branch   bne if $n /=$m branch
        if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0)))
            next_PC = Add_result;           //  ���������PC��ַ
        else if(Jrn == 1)
            next_PC = Read_data_1[31:0];
        else  next_PC = {2'b00,PC_plus_4[31:2]};// ����ʱ����PC<-PC+4
    end
    
   always @(negedge clock) begin
     if(reset == 1) begin
         PC <= 32'b00000000000000000000000000000000;
     end else begin
       if((Jmp == 1) || (Jal == 1)) begin   // �������ý��������Ĵ��й�ϵ����JALָ��ִ��ʱ����ǰ����PC+4��$31
            opcplus4 = {2'b00,PC_plus_4[31:2]};
                PC[31:0] <= {4'b0000,Instruction[25:0],2'b00};
       end else PC[31:0] <= {next_PC[29:0],2'b00};
     end
   end
endmodule