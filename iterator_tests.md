# src
## MOV  R0     R1
## 0001 000000 000001
addresses:

## ADD  (R0)+  R1
## 0010 001000 000001
addresses:

## ADC  -(R0)  R1
## 0011 010000 000001
addresses:

## SUB  X(R0)  R1
## 0100 011000 000001
addresses:

## AND  @R0    R1
## 0110 100000 000001
addresses:

## OR   @(R0)+ R1
## 0111 101000 000001
addresses:

## XNOR @-(R0) R1
## 1000 110000 000001
addresses:

## CMP  @X(R0) R1
## 1001 111000 000001
addresses:

# dst
## ADD  R3     (R5)+
## 0010 000011 001101
addresses:

## ADC  R3     -(R5)
## 0011 000011 010101
addresses:

## SUB  R3     X(R5)
## 0100 000011 011101
addresses:

## AND  R3     @R5
## 0110 000011 100101
addresses:

## OR   R3     @(R5)+
## 0111 000011 101101
addresses:

## XNOR R3     @-(R5)
## 1000 000011 110101
addresses:

## CMP  R3     @X(R5)
## 1001 000011 111101
addresses:

# operation
## BEQ    2 
## 000001 0000000010
addresses:

## HLT
## 1010 000000000000
addresses:

## NOP
## 1011 000000000000
addresses:

## JSR    100
## 110100 1100100
addresses:

## RTS
## 111001 0000000000
addresses:

## INT
## 111010 0000000000
addresses:

## IRET
## 111011 0000000000
addresses:
