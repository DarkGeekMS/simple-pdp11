MOV #19, R0
MOV #20, R1
label2:
MOV #0, R3
CMP @R1, R3
BGE label1
ADD (R1)+, #18
DEC R0
BNE label2
BR label3
label1:
SUB (R1)+, #18
DEC R0
BNE label2
label3:
HLT