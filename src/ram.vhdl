library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (RAM_SIZE: integer := 4*1024);

	port (
		clk, rd, wr: in std_logic;
		address, datain: in std_logic_vector(15 downto 0);

		dataout: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of ram is
	type DataType is array(0 to RAM_SIZE) of std_logic_vector(15 downto 0);
	signal data: DataType;
begin
	process (clk, datain, wr, address)
	begin	
		if rising_edge(clk) and wr = '1' then  
			data(to_integer(unsigned(address))) <= datain;
		end if;
	end process;

	process (clk, datain, rd, address)
	begin
		if rising_edge(clk) and rd = '1' then  
			dataout <= data(to_integer(unsigned(address)));
		else 
			dataout <= (others => 'Z');
		end if;
	end process;
end architecture;
