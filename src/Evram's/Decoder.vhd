library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY Decoder IS
GENERIC (n : integer := 16);
--IR: the IR register from 15 to 0 inclusive
--MeuInst: the whole 26 bits of the micro-instruction
--controlSignal: How many bits .. ?
PORT(
	IR: IN std_logic_vector(n-1 DOWNTO 0);
	MeuInst: IN std_logic_vector(25 DOWNTO 0);
	controlSignal : OUT std_logic_vector(3 DOWNTO 0);
	decoder_clk : IN std_logic
);
END entity Decoder;

ARCHITECTURE archDEC of Decoder is



--Added Components


--Added Signals, for each control word
SIGNAL PC_in: std_logic;
SIGNAL PC_out: std_logic;

SIGNAL MDR_in: std_logic;
SIGNAL MDR_out: std_logic;

SIGNAL IR_out: std_logic;
SIGNAL IR_in: std_logic;

SIGNAL MAR_in: std_logic;

SIGNAL Rsrc_out: std_logic;
SIGNAL Rdst_out: std_logic;
SIGNAL temp1_out: std_logic;
SIGNAL ALU_out: std_logic;

SIGNAL Rsrc_in: std_logic;
SIGNAL Rdst_in: std_logic;
SIGNAL Flags_in: std_logic;
SIGNAL temp1_in: std_logic;

SIGNAL temp0_in: std_logic;
--WTF !!
SIGNAL clear_temp0: std_logic;

SIGNAL ALU_add: std_logic;
SIGNAL ALU_bus_1: std_logic;
SIGNAL ALU_bus_m_1: std_logic;
SIGNAL ALU_OP: std_logic;

SIGNAL write_sig: std_logic;
SIGNAL read_sig: std_logic;

SIGNAL set_carry: std_logic;
SIGNAL clr_carry: std_logic;

SIGNAL PLA_out: std_logic;

SIGNAL OR_dst: std_logic;
SIGNAL OR_dst_ind: std_logic;
SIGNAL OR_SRC_ind: std_logic;
SIGNAL OR_result: std_logic;
SIGNAL OR_OP: std_logic;
SIGNAL ADDRES_Field: std_logic;
SIGNAL Flags_out: std_logic;

BEGIN



PROCESS(IR,MeuInst,decoder_clk)
	BEGIN
	IF (rising_edge(decoder_clk)) THEN
		--NAF 25:20 -- 6 bits
		--Group 1
		CASE MeuInst(21 DOWNTO 19) IS
			WHEN "001" =>
				PC_out <= '1';
			WHEN "010" =>
				IR_out <= '1';
			WHEN "011" =>
				MDR_out <= '1';
			WHEN "100" =>
				Rsrc_out <= '1';
			WHEN "101" =>
				Rdst_out <= '1';
			WHEN "110" =>
				temp1_out <= '1';
			WHEN "111" =>
				ALU_out <= '1';
		END CASE;

		--Group 2
		CASE MeuInst(18 DOWNTO 16) IS
			WHEN "001" =>
				PC_in <= '1';
			WHEN "010" =>
				IR_in <= '1';
			WHEN "011" =>
				Rsrc_in <= '1';
			WHEN "100" =>
				Rdst_in <= '1';
			WHEN "101" =>
				Flags_in <= '1';
		END CASE;

		--Group 3
		CASE MeuInst(15 DOWNTO 14) IS
			WHEN "01" =>
				MAR_in <= '1';
			WHEN "10" =>
				MDR_in <= '1';
			WHEN "11" =>
				temp1_in <= '1';
		END CASE;

		--Group 4
		CASE MeuInst(13 DOWNTO 12) IS
			WHEN "01" =>
				temp0_in <= '1';
			WHEN "10" =>
				clear_temp0 <= '1';
		END CASE;

		--Group 5
		CASE MeuInst(11 DOWNTO 9) IS
			WHEN "001" =>
				ALU_add <= '1';
			WHEN "010" =>
				ALU_bus_1 <= '1';
			WHEN "011" =>
				ALU_bus_m_1 <= '1';
			WHEN "100" =>
				ALU_OP <= '1';
		END CASE;

		--Group 6
		CASE MeuInst(8 DOWNTO 7) IS
			WHEN "00" =>
				read_sig <= '1';
			WHEN "01" =>
				write_sig <= '1';
		END CASE;

		--Group 7
		CASE MeuInst(6 DOWNTO 5) IS
			WHEN "00" =>
				set_carry <= '1';
			WHEN "01" =>
				clr_carry <= '1';
		END CASE;

		--Group 8
		CASE MeuInst(4 DOWNTO 3) IS
			WHEN "01" =>
				PLA_out <= '1';
		END CASE;

		--Group 9
		CASE MeuInst(2 DOWNTO 0) IS
			WHEN "001" =>
				OR_dst <= '1';
			WHEN "010" =>
				OR_dst_ind <= '1';
			WHEN "011" =>
				OR_SRC_ind <= '1';
			WHEN "100" =>
				OR_result <= '1';
			WHEN "101" =>
				OR_OP <= '1';
			WHEN "110" =>
				ADDRES_Field <= '1';
			WHEN "111" =>
				Flags_out <= '1';
		END CASE;
	END IF;
	END PROCESS;
END ARCHITECTURE;