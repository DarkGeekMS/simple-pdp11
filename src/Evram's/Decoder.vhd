library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY Decoder IS
GENERIC (n : integer := 16);
--IR: the IR register from 15 to 0 inclusive
--MeuInst: the whole 26 bits of the micro-instruction
--controlSignal: How many bits .. ?
--CONTROL SIGNAL design is as follows:
--0 r0 in
--1 r1 in
--2 r2 in
--3 r3 in
--4 r4 in
--5 r5 in
--6 r6 in
--7 pc in
--8 mdr in
--9 temp1 in
--10 temp0 in
--11 MAR in

--12 r0 out
--13 r1 out
--14 r2 out
--15 r3 out
--16 r4 out
--17 r5 out
--18 r6 out
--19 pc out

--20 flag in
--21 flag out
--22 rd
--23 wr
--24 ir out
--25 alu out
--26 ir in
--27 clr temp0
--28 set carry
--29 clr carry
--30 pla out
--31 alu 0
--32 alu 1
--33 alu 2
--34 alu 3
--35 address out
--36 mdr out
--37 temp1 out

PORT(
	decoder_clk : IN std_logic;
	IR: IN std_logic_vector(n-1 DOWNTO 0);
	MeuInst: IN std_logic_vector(25 DOWNTO 0);
	controlSignal : OUT std_logic_vector(37 DOWNTO 0)
);
END entity Decoder;

ARCHITECTURE archDEC of Decoder is



--Added Components
COMPONENT ALU_DECODER IS
PORT(
	IR_SUB: IN std_logic_vector(7 DOWNTO 0);
	ALU_MODE : OUT std_logic_vector(3 DOWNTO 0)
);
END COMPONENT;

COMPONENT Ri_Decoder IS
PORT(
	en:  IN std_logic;
	IR_SUB: IN std_logic_vector(2 DOWNTO 0);
	Ri : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;



--Added Signals, for each control word
SIGNAL Rsrc_out: std_logic;
SIGNAL Rdst_out: std_logic;

SIGNAL Rsrc_in: std_logic;
SIGNAL Rdst_in: std_logic;

--That signal wont be outed from decoder unless AL_OP is selected
SIGNAL ALU_MODE std_logic_vector(3 DOWNTO 0);


SIGNAL EV : std_logic;


BEGIN
aludDEC: ALU_DECODER PORT MAP(IR(15 DOWNTO 8),ALU_MODE);
Rsrc_out: Ri_Decoder PORT MAP(Rsrc_out,IR(8 DOWNTO 6) ,controlSignal(19 DOWNTO 12));
Rdst_out: Ri_Decoder PORT MAP(Rdst_out,IR(2 DOWNTO 0) ,controlSignal(19 DOWNTO 12));
Rsrc_int: Ri_Decoder PORT MAP(Rsrc_in,IR(8 DOWNTO 6) ,controlSignal(7 DOWNTO 0));
Rdst_in: Ri_Decoder PORT MAP(Rdst_in,IR(2 DOWNTO 0) ,controlSignal(7 DOWNTO 0));


PROCESS(IR,MeuInst,decoder_clk)
	BEGIN
	IF (rising_edge(decoder_clk)) THEN
		--NAF 25:20 -- 6 bits
		--Group 1 
		CASE MeuInst(21 DOWNTO 19) IS
			WHEN "001" =>	
				controlSignal(7) <= '1';
			WHEN "010" =>
				controlSignal(24) <= '1';
			WHEN "011" =>
				controlSignal(36) <= '1';
			WHEN "100" =>
				Rsrc_out <= '1';
			WHEN "101" =>
				Rdst_out <= '1';
			WHEN "110" =>
				controlSignal(37) <= '1';
			WHEN "111" =>
				controlSignal(25) <= '1';
			WHEN OTHERS =>
				Ev <= '0'; --Like no operation ^_^
		END CASE;

		--Group 2
		CASE MeuInst(18 DOWNTO 16) IS
			WHEN "001" =>
				controlSignal(7) <= '1';
			WHEN "010" =>
				controlSignal(26) <= '1';
			WHEN "011" =>
				Rsrc_in <= '1';
			WHEN "100" =>
				Rdst_in <= '1';
			WHEN "101" =>
				controlSignal(20) <= '1';
		END CASE;

		--Group 3
		CASE MeuInst(15 DOWNTO 14) IS
			WHEN "01" =>
				controlSignal(11) <= '1';
			WHEN "10" =>
				controlSignal(8) <= '1';
			WHEN "11" =>
				controlSignal(9) <= '1';
		END CASE;

		--Group 4
		CASE MeuInst(13 DOWNTO 12) IS
			WHEN "01" =>
				controlSignal(10) <= '1';
			WHEN "10" =>
				controlSignal(27) <= '1';
		END CASE;

		--Group 5
		CASE MeuInst(11 DOWNTO 9) IS
			WHEN "001" =>
				--FORCE ALU to add
				controlSignal(34 DOWNTO 31) <= "0000";
			WHEN "010" =>
				controlSignal(34 DOWNTO 31) <= "1110";
			WHEN "011" =>
				controlSignal(34 DOWNTO 31) <= "1101";
			WHEN "100" =>
				controlSignal(34 DOWNTO 31) <= ALU_MODE;
			WHEN OTHERS =>
				Ev <= '1';
		END CASE;

		--Group 6
		CASE MeuInst(8 DOWNTO 7) IS
			WHEN "00" =>
				controlSignal(22) <= '1';
			WHEN "01" =>
				controlSignal(23) <= '1';
		END CASE;

		--Group 7
		CASE MeuInst(6 DOWNTO 5) IS
			WHEN "00" =>
				controlSignal(28) <= '1';
			WHEN "01" =>
				controlSignal(29) <= '1';
		END CASE;

		--Group 8
		CASE MeuInst(4 DOWNTO 3) IS
			WHEN "01" =>
				controlSignal(30) <= '1';
		END CASE;

		--Group 9
		CASE MeuInst(2 DOWNTO 0) IS
			WHEN "110" =>
				controlSignal(35) <= '1';
			WHEN "111" =>
				controlSignal(21) <= '1';
		END CASE;

	END IF;
	END PROCESS;
END ARCHITECTURE;