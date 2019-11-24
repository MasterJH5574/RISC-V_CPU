# RISC-V_CPU

## RISCV32I Instruction Set 
0 - unsupported  
1 - waiting for test  
2 - pass simulation  
3 - complete  

### Integer Computational Insturctions
1. **Integer R-I Instructions**   
    [1] ADDI  
    [1] SLTI	(set less than imm)  
    [1] SLTIU  
    [1] XORI  
    [1] ORI  
    [1] ANDI  
    [1] SLLI	(logical left shift)  
    [1] SRLI	(logical right shift)  
    [1] SRAI	(arthmetic right shift)  
    [1] LUI	    (load upper imm)  
    [1] AUIPC	(add  upper imm to PC)

2. **Integer R-R Instructions**  
    [1] ADD  
    [1] SUB  
    [1] SLT  
    [1] SLTU  
    [1] XOR  
    [1] SLL	(logical left shift)  
    [1] SRL (logical right shift)  
    [1] SRA	(arthmetic right shift)  
    [1] OR  
    [1] AND

3. **Nop Instructions**

### Control Transfer Instructions
1. **Unconditional Jumps**  
    [1] JAL  
  	[1] JALR  

2. **Conditional Branches**  
	[1] BEQ  
	[1] BNE  
	[1] BLT  
	[1] BGE  
	[1] BLTU  
	[1] BGEU  

### Load & Store Instructions
1. **Load**  
	[1] LB  
	[1] LH  
	[1] LW  
	[1] LBU  
	[1] LHU  
	
2. **Save**  
	[1] SB  
	[1] SH  
	[1] SW  

## Testcases(Simulation)
 - All the "sleep"s in code are deleted.
 - If there is an input file, use assignment instead of input.
 
0 - failed  
1 - passed  
2 - unknown  
[1] array_test1
[1] array_test2
[1] basicopt1  
[1] bulgarian
[1] expr  
[1] gcd  
[1] hanoi  
[1] lvalue2  
[1] magic  
[1] manyarguments  
[1] multiarray  
[0] pi  
[1] qsort
[1] queens
[1] statement_test  
[1] superloop
[1] tak