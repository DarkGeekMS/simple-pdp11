library ieee;
use ieee.std_logic_1164.all;

entity nadder is
	generic (n : integer := 16);

	port (
		A, B : in std_logic_vector(n-1 downto 0);
		Cin : in std_logic;
		SUM : out std_logic_vector(n-1 downto 0);
		Cout : out std_logic
	);
end nadder;

architecture nadder_arch OF nadder is
	signal CARRY : std_logic_vector(n-1 downto 0);
begin
	adder0: entity work.bitadder port map(A(0),B(0),Cin,SUM(0),CARRY(0));
	l: FOR i in 1 TO n-1 generate
		adderX: entity work.bitadder port map (A(i),B(i), CARRY(i-1), SUM(i), CARRY(i));
	end generate;

	Cout <= CARRY(n-1);
end nadder_arch;