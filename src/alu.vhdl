library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity alu is
    generic (WORD_WIDTH: integer := 16);

    port (
        r, l: in std_logic_vector(WORD_WIDTH-1 downto 0);  
        sel: in std_logic_vector(3 downto 0);
        cin : in std_logic;

        f: out std_logic_vector(WORD_WIDTH-1 downto 0);
        cout: out std_logic
    );
end entity;

architecture rtl of alu is
begin
    f <= (others => '0');
    cout <= cin;
end architecture;
