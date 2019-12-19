library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

--IR_SUB: the IR register from 15 to 8 inclusive
--ALU_MODE: the alu operation
entity alu_decoder is
	port (
		IR_SUB: in std_logic_vector(7 downto 0);
		ALU_MODE : out std_logic_vector(3 downto 0)
	);
end entity;

architecture archALUDEC of alu_decoder is
begin
	process (IR_SUB)
	begin
		case IR_SUB(7 downto 4) is
			when "0010" =>
				--ADD
				ALU_MODE <= "0000";
			when "0011" =>
				--ADC
				ALU_MODE <= "0000";
			when "0100" =>
				--SUB
				ALU_MODE <= "0001";
			when "0101" =>
				--SBC
				ALU_MODE <= "0001";
			when "0110" =>
				--AND
				ALU_MODE <= "0010";
			when "0111" =>
				--OR
				ALU_MODE <= "0011";
			when "1000" =>
				--XNOR
				ALU_MODE <= "0101";
			when "1001" =>
				--CMP --> SUB
				ALU_MODE <= "0001";	    	
	    	when OTHERS =>
	    		--1111????
	    		case IR_SUB(7 downto 4) is
					when "0000" =>
						--INC
						ALU_MODE <= "1110";
					when "0001" =>
						--DEC
						ALU_MODE <= "1101";
					when "0010" =>
						--CLR
						ALU_MODE <= "1111";
					when "0011" =>
						--INV (NOT)
						ALU_MODE <= "0100";
					when "0100" =>
						--LSR
						ALU_MODE <= "0110";
					when "0101" =>
						--ROR
						ALU_MODE <= "0111";
					when "0110" =>
						--RRC
						ALU_MODE <= "1000";
					when "0111" =>
						--ASR
						ALU_MODE <= "1001";
					when "1000" =>
						--LSL
						ALU_MODE <= "1010";
					when "1001" =>
						--ROL
						ALU_MODE <= "1011";
					when OTHERS =>
						--RLC
						ALU_MODE <= "1100";
				end case;
	    end case;
	end process;
end architecture;