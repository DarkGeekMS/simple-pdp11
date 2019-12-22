library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
    -- indices of flags in FLAGS register
    -- [IFR = Index in Flags Register]
    constant IFR_CARRY     : integer := 0;
    constant IFR_ZERO      : integer := 1;
    constant IFR_NEG       : integer := 2;
    constant IFR_PARITY    : integer := 3;
    constant IFR_OVERFLOW  : integer := 4;

    -- indices of control signals
    -- [ICS = Index in Control Signal]
    constant ICS_R0_IN     : integer := 0;
	constant ICS_R1_IN     : integer := 1;
	constant ICS_R2_IN     : integer := 2;
	constant ICS_R3_IN     : integer := 3;
	constant ICS_R4_IN     : integer := 4;
	constant ICS_R5_IN     : integer := 5;
	constant ICS_R6_IN     : integer := 6;
	constant ICS_PC_IN     : integer := 7;
	constant ICS_MDR_IN    : integer := 8;
	constant ICS_TEMP1_IN  : integer := 9;
	constant ICS_TEMP0_IN  : integer := 10;
	constant ICS_MAR_IN    : integer := 11;
	constant ICS_R0_OUT    : integer := 12;
	constant ICS_R1_OUT    : integer := 13;
	constant ICS_R2_OUT    : integer := 14;
	constant ICS_R3_OUT    : integer := 15;
	constant ICS_R4_OUT    : integer := 16;
	constant ICS_R5_OUT    : integer := 17;
	constant ICS_R6_OUT    : integer := 18;
	constant ICS_PC_OUT    : integer := 19;
	constant ICS_FLAG_IN   : integer := 20;
	constant ICS_FLAG_OUT  : integer := 21;
	constant ICS_RD        : integer := 22;
	constant ICS_WR        : integer := 23;
	constant ICS_IR_OUT    : integer := 24;
	constant ICS_ALU_OUT   : integer := 25;
	constant ICS_IR_IN     : integer := 26;
	constant ICS_CLR_TEMP0 : integer := 27;
	constant ICS_FLAGS_IGNORE_ALU
						   : integer := 28;   -- if 1 ignore alu flag output
	constant ICS_CLR_CARRY : integer := 29;
	constant ICS_ALU_ENBL  : integer := 30;
	constant ICS_ALU_0     : integer := 31;
	constant ICS_ALU_1     : integer := 32;
	constant ICS_ALU_2     : integer := 33;
	constant ICS_ALU_3     : integer := 34;
	constant ICS_ADRS_OUT  : integer := 35;
	constant ICS_MDR_OUT   : integer := 36;
    constant ICS_TEMP1_OUT : integer := 37;
    
    type DataType is array(0 to 51-1) of std_logic_vector(26-1 downto 0);
	constant CONTROL_STORE : DataType := (
		"00000100100001000100100000",
		"00001011100100000000000000",
		"00001101101000000000001000",
		"01000010000011000000001001",
		"00111010000001000000101011",
		"00011010000001000100100000",
		"00111011101100000000001011",
		"00100010000000000110000000",
		"00111011101101000000101011",
		"00101000100001000100100000",
		"00101111100100000000000000",
		"00110001100000010000000000",
		"00110110000000000010000000",
		"00111011100001000000101011",
		"00111101100001000000100000",
		"01000001100011000000001001",
		"10111010100000010000001101",
		"01101110100001000000101010",
		"01001110100001000100100000",
		"01101111110000000000001010",
		"01010110100000000110000000",
		"01101111110001000000101010",
		"01011100100001000100100000",
		"01100011100100000000000000",
		"01100101100000010000000000",
		"01101010100000000010000000",
		"01101111100001000000101010",
		"01110001100001000000100000",
		"10111001100000010000001101",
		"01111010000000000110000000",
		"01111111101101000000000000",
		"10000000000010000001001111",
		"10000110000000000110000000",
		"10001011101101000000000000",
		"10001100100010000001001101",
		"00000000000100000000001110",
		"10010110000001000100100000",
		"10011011101100000000000000",
		"10011101100100000000001101",
		"10100010000001000100100000",
		"10100111101100000000000000",
		"00000001110100000000000000",
		"10101100000000000000001100",
		"10110000100000010000000000",
		"10110100000000000010001110",
		"00000011100100000000000000",
		"00000011000010000001000000",
		"00000011010000000000000000",
		"11000111000000001000001010",
		"00000011110000000000000000",
		"00000011100010000001000000"
	);

    function to_vec(i: integer; size: integer := 16) return std_logic_vector;
    function to_vec(i: std_logic; size: integer := 16) return std_logic_vector;
	function to_vec(i: std_logic_vector; size: integer := 16) return std_logic_vector;
	function to_string(a: std_logic_vector) return string;
end package;

package body common is
    function to_vec(i: integer; size: integer := 16) return std_logic_vector is 
        variable tmp: unsigned(size-1 downto 0);
    begin
        if i < 0 then 
            tmp := to_unsigned(-i, size);
            tmp := not tmp;
            tmp := tmp + 1;
        else 
            tmp := to_unsigned(i, size);
        end if;

        return std_logic_vector(tmp);
    end function;

    function to_vec(i: std_logic; size: integer := 16) return std_logic_vector is
        variable v: std_logic_vector(size-1 downto 0);
    begin
        v := (others => i);
        return v;
    end function;

    function to_vec(i: std_logic_vector; size: integer := 16) return std_logic_vector is
        variable v: std_logic_vector(size-1 downto 0) := i;
    begin
        return v;
	end function;
	
	function to_string(a: std_logic_vector) return string is
		variable b : string (1 to a'length) := (others => NUL);
		variable stri : integer := 1; 
	begin
		for i in a'range loop
			b(stri) := std_logic'image(a((i)))(2);
			stri := stri+1;
		end loop;

		return b;
	end function;
end package body;