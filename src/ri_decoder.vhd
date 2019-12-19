library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

--IR_SUB_RI: the IR register from 2 to 0(Destination), or 8 to 6 (Source)
--Ri: which R of them
entity ri_decoder is
	port (
		en:  in std_logic;
		IR_SUB_RI: in std_logic_vector(2 downto 0);
		Ri : out std_logic_vector(7 downto 0)
	);
end entity;

architecture archRiDec of ri_decoder is
begin
	process(IR_SUB_RI,en)
	begin
		if (en = '0') then
			Ri <= "00000000";
		ELSE
			case IR_SUB_RI is
				when "000" =>
					Ri <= "00000001";
				when "001" =>
					Ri <= "00000010";
				when "010" =>
					Ri <= "00000100";
				when "011" =>
					Ri <= "00001000";
				when "100" =>
					Ri <= "00010000";
				when "101" =>
					Ri <= "00100000";
				when "110" =>
					Ri <= "01000000";
				when OTHERS =>
					Ri <= "10000000";
			end case;
		end if;
	end process;
end architecture;
