library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY ALU_DECODER IS
--IR_SUB: the IR register from 15 to 8 inclusive
--ALU_MODE: the alu operation
PORT(
	IR_SUB: IN std_logic_vector(7 DOWNTO 0);
	ALU_MODE : OUT std_logic_vector(3 DOWNTO 0)
);
END entity ALU_DECODER;

ARCHITECTURE archALUDEC of ALU_DECODER is


BEGIN
PROCESS(IR_SUB)
	BEGIN
		CASE IR_SUB(7 DOWNTO 4) IS
			WHEN "0010" =>
				--ADD
				ALU_MODE <= "0000";
			WHEN "0011" =>
				--ADC
				ALU_MODE <= "0000";
			WHEN "0100" =>
				--SUB
				ALU_MODE <= "0001";
			WHEN "0101" =>
				--SBC
				ALU_MODE <= "0001";
			WHEN "0110" =>
				--AND
				ALU_MODE <= "0010";
			WHEN "0111" =>
				--OR
				ALU_MODE <= "0011";
			WHEN "1000" =>
				--XNOR
				ALU_MODE <= "0101";
			WHEN "1001" =>
				--CMP --> SUB
				ALU_MODE <= "0001";	    	
	    	WHEN OTHERS =>
	    		--1111????
	    		CASE IR_SUB(7 DOWNTO 4) IS
					WHEN "0000" =>
						--INC
						ALU_MODE <= "1110";
					WHEN "0001" =>
						--DEC
						ALU_MODE <= "1101";
					WHEN "0010" =>
						--CLR
						ALU_MODE <= "1111";
					WHEN "0011" =>
						--INV (NOT)
						ALU_MODE <= "0100";
					WHEN "0100" =>
						--LSR
						ALU_MODE <= "0110";
					WHEN "0101" =>
						--ROR
						ALU_MODE <= "0111";
					WHEN "0110" =>
						--RRC
						ALU_MODE <= "1000";
					WHEN "0111" =>
						--ASR
						ALU_MODE <= "1001";
					WHEN "1000" =>
						--LSL
						ALU_MODE <= "1010";
					WHEN "1001" =>
						--ROL
						ALU_MODE <= "1011";
					WHEN OTHERS =>
						--RLC
						ALU_MODE <= "1100";
				END CASE;


	    END CASE;
	END PROCESS;
END ARCHITECTURE;