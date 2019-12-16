library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY Ri_Decoder IS
--IR_SUB: the IR register from 2 to 0(Destination), or 8 to 6 (Source)
--Ri: which R of them
PORT(
	en:  IN std_logic;
	IR_SUB: IN std_logic_vector(2 DOWNTO 0);
	Ri : OUT std_logic_vector(7 DOWNTO 0)
);
END entity Ri_Decoder;

ARCHITECTURE archRiDec of Ri_Decoder is


BEGIN
PROCESS(IR_SUB)
	BEGIN
	IF (en = "0") THEN
		Ri <= "00000000";
	ELSE
		CASE IR_SUB IS
			WHEN "000" =>
				Ri <= "00000001";
			WHEN "001" =>
				Ri <= "00000010";
			WHEN "010" =>
				Ri <= "00000100";
			WHEN "011" =>
				Ri <= "00001000";
			WHEN "100" =>
				Ri <= "00010000";
			WHEN "101" =>
				Ri <= "00100000";
			WHEN "110" =>
				Ri <= "01000000";
			WHEN "111" =>
				Ri <= "10000000";
			END CASE;
	END IF;
	END PROCESS;
END ARCHITECTURE;
