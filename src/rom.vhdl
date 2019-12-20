library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.common.CONTROL_STORE;

entity rom is
	port (
		clk, rd: in std_logic;
		address: in std_logic_vector(5 downto 0);

		data_out: out std_logic_vector(26-1 downto 0)
	);
end entity;

architecture rtl of rom is
begin
	process (clk, rd, address)
	begin
		if rising_edge(clk) and rd = '1' then  
			data_out <= CONTROL_STORE(to_integer(unsigned(address)));
		else 
			data_out <= (others => 'Z');
		end if;
	end process;
end architecture;
