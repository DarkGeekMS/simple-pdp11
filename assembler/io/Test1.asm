MOV #19, R0
label3:
XOR R1, R1
MOV #20, R3
MOV (R3)+, #18
label1:
DEC R0
CMP #18, @R3
BGE label1
label2:
MOV @R3, #18
DEC R0
BEQ label2
INC R3
BR label3
HLT