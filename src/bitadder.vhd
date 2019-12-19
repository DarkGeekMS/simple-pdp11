library ieee;
use ieee.std_logic_1164.all;

entity bitadder is
	port (
		A, B, Cin : in std_logic; 
		SUM,Cout : out std_logic
	);
end entity;

architecture archBitAdder OF bitadder is
begin
	process (a, b, cin)
	begin
		SUM <= A XOR B XOR Cin;
		Cout <= (A AND B) or (Cin AND (A XOR B));
	end process;
end architecture;