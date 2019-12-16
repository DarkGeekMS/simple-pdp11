library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY STARTER IS
GENERIC (n : integer := 16);
--IR: the IR register
--MeuAR_ADD:(Micro AR) the addres to where the iterator must start from
PORT(
	IR: IN std_logic_vector(n-1 DOWNTO 0);
	MeuAR_ADD : OUT std_logic_vector(5 DOWNTO 0);
	starter_clk : IN std_logic
);
END entity STARTER;

ARCHITECTURE archStarter of STARTER is

--Any added components

--Any added signals
BEGIN
PROCESS(IR,starter_clk)
BEGIN
	IF (rising_edge(starter_clk)) THEN
		CASE IR(15 DOWNTO 12) IS
			WHEN "0000" =>
				--BRANCH A
				MeuAR_ADD <= "101010";
			WHEN "1010" =>
				--HLT
				--What should I do?
			WHEN "1011" =>
				--NOP
				--What should I do?
			WHEN "1100" =>
				--BRANCH B
				MeuAR_ADD <= "101010";
			WHEN "1101" =>
				--JSR
				MeuAR_ADD <= "100000";
			WHEN "1110" =>
				--four choises
				IF (IR(11)= '0' and IR(10) = '0') THEN
					--IGNORE IR
					MeuAR_ADD <= "000000";
				ELSIF (IR(11)= '0' and IR(10) = '1') THEN
					--RTS
					MeuAR_ADD <= "100100";
				ELSIF (IR(11)= '1' and IR(10) = '0') THEN
					--itr
					MeuAR_ADD <= "011101";
				ELSE
					--iret
					MeuAR_ADD <= "100100";
				END IF;
			WHEN "1111" =>
				--ONE OPERAND
				--Check on IR to know the type of Source 11 10 9
				CASE IR(11 DOWNTO 9) IS
					WHEN "000" => --Register direct
						MeuAR_ADD <= "000011";
					WHEN "001" => --Auto-increment
						MeuAR_ADD <= "000101";
					WHEN "010" => --Auto-decrement
						MeuAR_ADD <= "000111";
					WHEN "011" => --Indexed
						MeuAR_ADD <= "001001";
					--WHEN "100" => --Register indirect
					WHEN OTHERS =>
						MeuAR_ADD <= "000100";
				END CASE;
			WHEN OTHERS =>
				--TWO OPERANDS
				--Check on IR to know the type of Destination 5 4 3
				CASE IR(5 DOWNTO 3) IS
					WHEN "000" => --Register direct
						MeuAR_ADD <= "010000";
					WHEN "001" => --Auto-increment
						MeuAR_ADD <= "010010";
					WHEN "010" => --Auto-decrement
						MeuAR_ADD <= "010100";
					WHEN "011" => --Indexed
						MeuAR_ADD <= "010110";
					--WHEN "100" => --Register indirect
					WHEN OTHERS =>
						MeuAR_ADD <= "010001";
				END CASE;
		END CASE;
	END IF;
END PROCESS;
END ARCHITECTURE;
--Control store start...... 000 000
--2op src R..... 000011
--2op src @R...... 000100
--2op src (R) +..... 000101
--2op src -(R)..... 000111
--2op src x(R)..... 001001

--1op dest R..... 010000
--1op dest @R.....010001
--1op dest (R) +.... 010010
--1op dest - (R)..... 010100
--1op dest x(R)..... 010110

--Br.....101010

--Flags stack push.... 011101
--PC stack push.... 100000
--PC stack pop..... 100100
--Flags stack pop.... 100111