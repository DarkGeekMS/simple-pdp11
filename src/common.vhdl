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
    function to_vec(i: std_logic_vector; size: integer) return std_logic_vector;
end package;

package body common is
    function to_vec(i: integer; size: integer) return std_logic_vector is 
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

    function to_vec(i: std_logic; size: integer) return std_logic_vector is
        variable v: std_logic_vector(size-1 downto 0);
    begin
        v := (others => i);
        return v;
    end function;

    function to_vec(i: std_logic_vector; size: integer) return std_logic_vector is
        variable v: std_logic_vector(size-1 downto 0);
    begin
        for j in 0 to size-1 loop
            v(j) := i(j);
        end loop;
        return v;
    end function;
end package body;