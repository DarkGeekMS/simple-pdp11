library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (RAM_SIZE: integer := 4*1024);

	port (
		clk, rd, wr: in std_logic;
		address, data_in: in std_logic_vector(15 downto 0);

		data_out: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of ram is
	type DataType is array(0 to RAM_SIZE) of std_logic_vector(15 downto 0);
	signal data: DataType;

	signal last_data: std_logic_vector(15 downto 0); -- for debugging
begin
	process (clk, data_in, wr, address)
	begin	
		if clk = '1' and wr = '1' then  
			data(to_integer(unsigned(address))) <= data_in;
			last_data <= data_in;
		end if;
	end process;

	process (clk, data_in, rd, address)
	begin
		if rising_edge(clk) and rd = '1' then  
			data_out <= data(to_integer(unsigned(address)));
			last_data <= data_in;
		else 
			data_out <= (others => 'Z');
		end if;
	end process;
end architecture;
