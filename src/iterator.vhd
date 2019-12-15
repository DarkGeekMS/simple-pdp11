library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY iterator IS
	GENERIC (
		PATH: string := "rom.txt";  -- path to rom file relative to project dir
		WORD_WIDTH: natural := 26;  -- number of bits in word
		ROM_SIZE: natural := 64 -- ROM size
	);
	PORT (
		clk: IN std_logic;  -- system clock
		ir: IN std_logic_vector(15 DOWNTO 0);  -- IR register data
		out_inst: OUT std_logic_vector(WORD_WIDTH-1 downto 0)  -- output micro instruction
    );
    
END ENTITY iterator;

ARCHITECTURE arch_iterator OF iterator IS

-- definition of ROM component for control store handling
COMPONENT rom IS
    generic (
        PATH: string;
        WORD_WIDTH: natural; 
        ROM_SIZE: natural
    );
    port (
        clk, rd, reset: in std_logic;
        address: in std_logic_vector(15 downto 0);
        data_out: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
END COMPONENT;

-- definition of starter component for starting address navigation
COMPONENT STARTER IS
    GENERIC (n: integer);
    PORT(
        IR: IN std_logic_vector(n-1 DOWNTO 0);
        MeuAR_ADD : OUT std_logic_vector(5 DOWNTO 0)
    );
END COMPONENT;

BEGIN
-- TODO
END ARCHITECTURE;