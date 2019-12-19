library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
    -- indices of flags in FLAGS register
    constant CARRY_FLAG: integer := 0;
    constant ZERO_FLAG: integer := 1;
    constant NEG_FLAG: integer := 2;
    constant PARITY_FLAG: integer := 3;
    constant OVERFL_FLAG: integer := 4;

    function to_vec(i: integer; size: integer) return std_logic_vector;
    function to_vec(i: std_logic; size: integer) return std_logic_vector;
end package;

package body common is
    function to_vec(i: integer; size: integer) return std_logic_vector is 
    begin
        return std_logic_vector(to_unsigned(i, size));
    end function;

    function to_vec(i: std_logic; size: integer) return std_logic_vector is
        variable v: std_logic_vector(size-1 downto 0);
    begin
        v := (others => i);
        return v;
    end function;
end package body;