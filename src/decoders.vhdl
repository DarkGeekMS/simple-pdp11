library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

package decoders is
	function ir_to_alu_mode(IR_SUB: std_logic_vector(7 downto 0)) return std_logic_vector;

	--
		-- Given IR and compressed micro-instructions from control signals, 
			--return their corresponding control signals
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
		--24 alu enable
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
	function decompress_control_signals(IR: std_logic_vector(15 downto 0); 
		MeuInst: std_logic_vector(25 downto 0)) return std_logic_vector;

	-- helper function for `decompress_control_signals`
	function ri_decoder(IR_SUB_RI: std_logic_vector(2 downto 0)) return std_logic_vector;
end package;

package body decoders is
	function ir_to_alu_mode(IR_SUB: std_logic_vector(7 downto 0)) return std_logic_vector is
		variable ALU_MODE : std_logic_vector(3 downto 0);
	begin
		case IR_SUB(7 downto 4) is
			when "0010" =>
				--ADD
				ALU_MODE := "0000";
			when "0011" =>
				--ADC
				ALU_MODE := "0000";
			when "0100" =>
				--SUB
				ALU_MODE := "0001";
			when "0101" =>
				--SBC
				ALU_MODE := "0001";
			when "0110" =>
				--AND
				ALU_MODE := "0010";
			when "0111" =>
				--OR
				ALU_MODE := "0011";
			when "1000" =>
				--XNOR
				ALU_MODE := "0101";
			when "1001" =>
				--CMP --> SUB
				ALU_MODE := "0001";	    	
			when OTHERS =>
				--1111????
				case IR_SUB(3 downto 0) is
					when "0000" =>
						--INC
						ALU_MODE := "1110";
					when "0001" =>
						--DEC
						ALU_MODE := "1101";
					when "0010" =>
						--CLR
						ALU_MODE := "1111";
					when "0011" =>
						--INV (NOT)
						ALU_MODE := "0100";
					when "0100" =>
						--LSR
						ALU_MODE := "0110";
					when "0101" =>
						--ROR
						ALU_MODE := "0111";
					when "0110" =>
						--RRC
						ALU_MODE := "1000";
					when "0111" =>
						--ASR
						ALU_MODE := "1001";
					when "1000" =>
						--LSL
						ALU_MODE := "1010";
					when "1001" =>
						--ROL
						ALU_MODE := "1011";
					when OTHERS =>
						--RLC
						ALU_MODE := "1100";
				end case;
		end case;
		return ALU_MODE;
	end function;
	
	function decompress_control_signals(IR: std_logic_vector(15 downto 0); MeuInst: std_logic_vector(25 downto 0)) return std_logic_vector is
		variable controlSignal : std_logic_vector(37 downto 0);
	begin
		--Group 1 
		case MeuInst(19 downto 17) is
			when "001" =>	
				controlSignal(7) := '1';
			when "011" =>
				controlSignal(36) := '1';
			when "100" =>
				controlSignal(19 downto 12) := ri_decoder (IR(8 downto 6));
			when "101" =>
				controlSignal(19 downto 12) := ri_decoder (IR(2 downto 0));
			when "110" =>
				controlSignal(37) := '1';
			when "111" =>
				controlSignal(25) := '1';
			when OTHERS =>
				null;
		end case;
	
		--Group 2
		case MeuInst(16 downto 14) is
			when "001" =>
				controlSignal(7) := '1';
			when "010" =>
				controlSignal(26) := '1';
			when "011" =>
				controlSignal(7 downto  0) := ri_decoder (IR(8 downto 6));
			when "100" =>
				controlSignal(7 downto  0) := ri_decoder (IR(2 downto 0));
			when "101" =>
				controlSignal(20) := '1';
			when OTHERS =>
				null;
		end case;
	
		--Group 3
		case MeuInst(13 downto 12) is
			when "01" =>
				controlSignal(11) := '1';
			when "10" =>
				controlSignal(8) := '1';
			when "11" =>
				controlSignal(9) := '1';
			when OTHERS =>
				null;
		end case;
		
		--Group 5
		case MeuInst(9 downto 7) is
			when "001" =>
				--FORCE ALU to add
				controlSignal(34 downto 31) := "0000";
				controlSignal(24) := '1';
			when "010" =>
				controlSignal(34 downto 31) := "1110";
				controlSignal(24) := '1';
			when "011" =>
				controlSignal(34 downto 31) := "1101";
				controlSignal(24) := '1';
			when "100" =>
				controlSignal(34 downto 31) := ir_to_alu_mode(IR(15 downto 8));
				controlSignal(24) := '1';
			when OTHERS =>
				null;
		end case;
	
		controlSignal(10) := not MeuInst(11) and MeuInst(10);
		controlSignal(27) := MeuInst(11) and not MeuInst(10);
		
		controlSignal(22) :=  MeuInst(6) nand MeuInst(5);
		controlSignal(23) := not MeuInst(6) and MeuInst(5);
		controlSignal(28) := MeuInst(4);
		controlSignal(29) := not MeuInst(4);
		controlSignal(30) := MeuInst(3);
		controlSignal(35) := MeuInst(2) and MeuInst(1) and not MeuInst(0);
		controlSignal(21) := MeuInst(2) and MeuInst(1) and not MeuInst(0);
		
		return controlSignal;
	end function;
	
	function ri_decoder(IR_SUB_RI: std_logic_vector(2 downto 0)) return std_logic_vector is
	begin
		case IR_SUB_RI is
				when "000" =>
					return "00000001";
				when "001" =>
					return "00000010";
				when "010" =>
					return "00000100";
				when "011" =>
					return "00001000";
				when "100" =>
					return "00010000";
				when "101" =>
					return "00100000";
				when "110" =>
					return "01000000";
				when OTHERS =>
					return "10000000";
		end case;
	end function;
end package body;