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
end package;
