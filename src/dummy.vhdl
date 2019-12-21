library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy is
    port (
        a: out std_logic
    );
end entity; 

architecture rtl of dummy is
begin
    a <= 'Z';
end architecture;
