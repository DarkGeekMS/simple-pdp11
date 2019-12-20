library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

--addresses:
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
--
--entity starter is
--	generic (n : integer := 16);

--	--IR: the IR register
--	--MeuAR_ADD:(Micro AR) the addres to where the iterator must start from
--	port (
--		IR: in std_logic_vector(n-1 downto 0);
--		MeuAR_ADD : out std_logic_vector(5 downto 0);
--		clk : in std_logic
--	);
--end entity;

--architecture archStarter of starter is
--begin



function starter(IR: std_logic_vector(15 downto 0)) return std_logic_vector is
	--Variables Declarations
	MeuAR_ADD : std_logic_vector(37 downto 0);
begin
	case IR(15 downto 12) is
				when "0000" =>
					--BRANCH A
					MeuAR_ADD := "101010";
				when "1010" =>
					--HLT
					MeuAR_ADD := "000000";
				when "1011" =>
					--NOP
					MeuAR_ADD := "000000";
				when "1100" =>
					--BRANCH B
					MeuAR_ADD := "101010";
				when "1101" =>
					--JSR
					MeuAR_ADD := "100000";
				when "1110" =>
					--four choises
					if (IR(11)= '0' and IR(10) = '0') then
						--IGNORE IR
						MeuAR_ADD := "000000";
					ELSIF (IR(11)= '0' and IR(10) = '1') then
						--RTS
						MeuAR_ADD := "100100";
					ELSIF (IR(11)= '1' and IR(10) = '0') then
						--itr
						MeuAR_ADD := "011101";
					else
						--iret
						MeuAR_ADD := "100100";
					end if;
				when "1111" =>
					--ONE OPERAND
					--Check on IR to know the type of Source 11 10 9
					case IR(11 downto 9) is
						when "000" => --Register direct
							MeuAR_ADD := "000011";
						when "001" => --Auto-increment
							MeuAR_ADD := "000101";
						when "010" => --Auto-decrement
							MeuAR_ADD := "000111";
						when "011" => --Indexed
							MeuAR_ADD := "001001";
						--when "100" => --Register indirect
						when OTHERS =>
							MeuAR_ADD := "000100";
					end case;
				when OTHERS =>
					--TWO OPERANDS
					--Check on IR to know the type of Destination 5 4 3
					case IR(5 downto 3) is
						when "000" => --Register direct
							MeuAR_ADD := "010000";
						when "001" => --Auto-increment
							MeuAR_ADD := "010010";
						when "010" => --Auto-decrement
							MeuAR_ADD := "010100";
						when "011" => --Indexed
							MeuAR_ADD := "010110";
						--when "100" => --Register indirect
						when OTHERS =>
							MeuAR_ADD := "010001";
					end case;
	end case;
end function;