library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY STARTER IS
GENERIC (n : integer := 16);
--IR: the IR register
--MeuAR_ADD:(Micro AR) the addres to where the iterator must start from
PORT(
	IR: IN std_logic_vector(n-1 DOWNTO 0);
	MeuAR_ADD : OUT std_logic_vector(5 DOWNTO 0)
);
END entity STARTER;

ARCHITECTURE archStarter of STARTER is

--Any added components

--Any added signals
BEGIN
PROCESS(IR)
BEGIN
	CASE IR(15 DOWNTO 12) IS
		WHEN "0000" =>
			--BRANCH A
			--four choises
			IF (IR(11)= '0' and IR(10) = '0') THEN
				--BR
			ELSIF (IR(11)= '0' and IR(10) = '1') THEN
				--BEQ
			ELSIF (IR(11)= '1' and IR(10) = '0') THEN
				--BNE
			ELSE
				--BLO
			END IF;
		WHEN "1010" =>
			--HLT
		WHEN "1011" =>
			--NOP
		WHEN "1100" =>
			--BRANCH B
			--three choises
			IF (IR(11)= '0' and IR(10) = '0') THEN
				--BLS
			ELSIF (IR(11)= '0' and IR(10) = '1') THEN
				--BHI
			ELSE
				--BHS
			END IF;
		WHEN "1101" =>
			--JSR
		WHEN "1110" =>
			--four choises
			IF (IR(11)= '0' and IR(10) = '0') THEN
				--IGNORE IR
				MeuAR_ADD <= "000000";
			ELSIF (IR(11)= '0' and IR(10) = '1') THEN
				--RTS
			ELSIF (IR(11)= '1' and IR(10) = '0') THEN
				--itr
			ELSE
				--iret
			END IF;
		WHEN "1111" =>
			--ONE OPERAND
		WHEN OTHERS =>
			--TWO OPERANDS

	END CASE;
END PROCESS;
END ARCHITECTURE;