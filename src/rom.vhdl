library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rom is
	generic (
		PATH: string := "rom.txt";  -- path to rom file relative to project dir
		WORD_LENGTH: natural := 8;  -- number of bits in word
		ROM_SIZE: natural := 4*1024 -- ROM size
	);

	port (
		clk, rd, reset: in std_logic;
		address: in std_logic_vector(15 downto 0);

		dataout: out std_logic_vector(WORD_LENGTH-1 downto 0)
	);
end entity;

architecture rtl of rom is
	type DataType is array(0 to ROM_SIZE) of std_logic_vector(WORD_LENGTH-1 downto 0);
	signal data : DataType := (others => (others => '0'));
begin
	process (clk, rd, address, reset)
	begin
		if reset = '0' and rising_edge(clk) and rd = '1' then  
			dataout <= data(to_integer(unsigned(address)));
		else 
			dataout <= (others => 'Z');
		end if;
	end process;

	process (reset)
		file input_file: text;

		variable tmp_in_line: line;
		variable tmp_word : std_logic_vector(WORD_LENGTH-1 downto 0);
		variable i: integer := 0;
	begin
		if reset = '1' then 
			file_open(input_file, "../" & PATH,  read_mode);

			while i < ROM_SIZE and not endfile(input_file) loop
				readline(input_file, tmp_in_line);
				read(tmp_in_line, tmp_word);

				data(i) <= tmp_word;
				i := i + 1;
			end loop;

			assert i = ROM_SIZE 
				report "ROM is not fully loaded from " & PATH & ", loaded " 
					& integer'image(i) & " words out of " 
					& integer'image(ROM_SIZE) & " words" 
					severity warning;

			file_close(input_file);
		end if;
	end process;
end architecture;
