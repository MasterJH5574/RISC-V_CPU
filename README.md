# RISC-V_CPU

## RISCV32I Instruction Set 
0 - unsupported  
1 - waiting for test  
2 - pass simulation  
3 - complete  

### Integer Computational Insturctions
1. **Integer R-I Instructions**   
    [0] ADDI  
    [1] SLTI	(set less than imm)  
    [1] SLTIU  
    [1] XORI  
    [1] ORI  
    [1] ANDI  
    [0] SLLI	(logical left shift)  
    [0] SRLI	(logical right shift)  
    [0] SRAI	(arthmetic right shift)  
    [1] LUI	    (load upper imm)  
    [0] AUIPC	(add  upper imm to PC)

2. **Integer R-R Instructions**  
    [0] ADD  
    [0] SUB  
    [1] SLT  
    [1] SLTU  
    [1] XOR  
    [0] SLL	(logical left shift)  
    [0] SRL      (logical right shift)  
    [0] SRA	(arthmetic right shift)  
    [1] OR  
    [1] AND

3. **Nop Instructions**

### Control Transfer Instructions
1. **Unconditional Jumps**  
    [0] JAL  
  	[0] JALR  

2. **Conditional Branches**  
	[0] BEQ  
	[0] BNE  
	[0] BLT  
	[0] BGE  
	[0] BLTU  
	[0] BGEU  

### Load & Store Instructions
1. **Load**  
	[0] LB  
	[0] LH  
	[0] LW  
	[0] LBU  
	[0] LHU  
	
2. **Save**  
	[0] SB  
	[0] SH  
	[0] SW  

## Testcases
0 - failed  
1 - passed  
2 - unknown  
[0] array_test1  
[0] array_test2  
[0] basicopt1  
[0] bulgarian  
[0] expr  
[0] gcd  
[0] hanoi  
[0] lvalue2  
[0] magic  
[0] manyarguments  
[0] multiarray  
[0] pi  
[0] qsort  
[0] queens  
[0] statement_test  
[0] superloop  
[0] tak