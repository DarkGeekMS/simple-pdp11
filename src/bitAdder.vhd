LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY bitAdder IS
	PORT(A, B, Cin : IN std_logic; 
		 SUM,Cout : OUT std_logic);
END bitAdder;

ARCHITECTURE archBitAdder OF bitAdder IS
BEGIN
	PROCESS (a,b,cin)
	BEGIN
		SUM <= A XOR B XOR Cin;
		Cout <= (A AND B) or (Cin AND (A XOR B));
	END PROCESS;
END archBitAdder;