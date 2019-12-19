library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

--IR: the IR register from 15 to 0 inclusive
	--MeuInst: the whole 26 bits of the micro-instruction
	--controlSignal: How many bits .. ?
	--CONTROL signal design is as follows:
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
--
entity decoder is
    generic (n : integer := 16);
    
	port (
		clk : in std_logic;
		IR: in std_logic_vector(n-1 downto 0);
		MeuInst: in std_logic_vector(25 downto 0);
		controlSignal : out std_logic_vector(37 downto 0)
	);
end entity;

architecture archDEC of decoder is
	--Added Signals, for each control word
	signal Rsrc_out: std_logic;
	signal Rdst_out: std_logic;

	signal Rsrc_in: std_logic;
	signal Rdst_in: std_logic;

	--That signal wont be outed from decoder unless AL_OP is selected
	signal ALU_MODE :std_logic_vector(3 downto 0);

	signal EV : std_logic;
begin
	aludDEC: entity work.alu_dec port map(IR(15 downto 8),ALU_MODE);
	Rsrc_out_label: entity work.ri_decoder port map(Rsrc_out,IR(8 downto 6), controlSignal(19 downto 12));
	Rdst_out_label: entity work.ri_decoder port map(Rdst_out,IR(2 downto 0), controlSignal(19 downto 12));
	Rsrc_int_label: entity work.ri_decoder port map(Rsrc_in,IR(8 downto 6), controlSignal(7 downto 0));
	Rdst_in_label : entity work.ri_decoder port map(Rdst_in,IR(2 downto 0), controlSignal(7 downto 0));

	process (IR,MeuInst, clk)
	begin
		if (rising_edge(clk)) then
			--NAF 25:20 -- 6 bits
			--Group 1 
			case MeuInst(21 downto 19) is
				when "001" =>	
					controlSignal(7) <= '1';
				when "010" =>
					controlSignal(24) <= '1';
				when "011" =>
					controlSignal(36) <= '1';
				when "100" =>
					Rsrc_out <= '1';
				when "101" =>
					Rdst_out <= '1';
				when "110" =>
					controlSignal(37) <= '1';
				when "111" =>
					controlSignal(25) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 2
			case MeuInst(18 downto 16) is
				when "001" =>
					controlSignal(7) <= '1';
				when "010" =>
					controlSignal(26) <= '1';
				when "011" =>
					Rsrc_in <= '1';
				when "100" =>
					Rdst_in <= '1';
				when "101" =>
					controlSignal(20) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 3
			case MeuInst(15 downto 14) is
				when "01" =>
					controlSignal(11) <= '1';
				when "10" =>
					controlSignal(8) <= '1';
				when "11" =>
					controlSignal(9) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 4
			case MeuInst(13 downto 12) is
				when "01" =>
					controlSignal(10) <= '1';
				when "10" =>
					controlSignal(27) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 5
			case MeuInst(11 downto 9) is
				when "001" =>
					--FORCE ALU to add
					controlSignal(34 downto 31) <= "0000";
				when "010" =>
					controlSignal(34 downto 31) <= "1110";
				when "011" =>
					controlSignal(34 downto 31) <= "1101";
				when "100" =>
					controlSignal(34 downto 31) <= ALU_MODE;
				when OTHERS =>
					Ev <= '1';
			end case;

			--Group 6
			case MeuInst(8 downto 7) is
				when "00" =>
					controlSignal(22) <= '1';
				when "01" =>
					controlSignal(23) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 7
			case MeuInst(6 downto 5) is
				when "00" =>
					controlSignal(28) <= '1';
				when "01" =>
					controlSignal(29) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 8
			case MeuInst(4 downto 3) is
				when "01" =>
					controlSignal(30) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;

			--Group 9
			case MeuInst(2 downto 0) is
				when "110" =>
					controlSignal(35) <= '1';
				when "111" =>
					controlSignal(21) <= '1';
				when OTHERS =>
					Ev <= '0'; --Like no operation ^_^
			end case;
		end if;
	end process;
end architecture;