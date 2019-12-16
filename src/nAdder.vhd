LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY nadder IS
	GENERIC (n : integer := 16);
	PORT(A, B : IN std_logic_vector(n-1 DOWNTO 0);
		 Cin : IN std_logic;
		 SUM : OUT std_logic_vector(n-1 DOWNTO 0);
		 Cout : OUT std_logic);
END nadder;

ARCHITECTURE nadder_arch OF nadder IS
	COMPONENT bitAdder IS
		PORT(A, B, Cin : IN std_logic; 
			 SUM,Cout : OUT std_logic);
	END COMPONENT;

	SIGNAL CARRY : std_logic_vector(n-1 DOWNTO 0);
BEGIN
	adder0: bitAdder PORT MAP(A(0),B(0),Cin,SUM(0),CARRY(0));
	l: FOR i IN 1 TO n-1 GENERATE
		adderX: bitAdder PORT MAP (A(i),B(i), CARRY(i-1), SUM(i), CARRY(i));
	END GENERATE;
	Cout <= CARRY(n-1);
END nadder_arch;