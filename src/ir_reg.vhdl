library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity ir_reg is
    generic (WORD_WIDTH: integer := 16);

    port (
        data_in: in std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_in, clk, rst, int: in std_logic;
        int_address: in std_logic_vector(9 downto 0);

        data_out: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end entity; 

architecture rtl of ir_reg is
    signal data: std_logic_vector(WORD_WIDTH-1 downto 0) := "110010" & to_vec(0, 10);
begin
    process (enable_in, clk, data_in, rst, int, int_address) 
    begin
        if enable_in = '1' and clk = '1' then
            data <= data_in;
        end if;

        if rst = '1' and clk = '1' then
            data <= "110010" & to_vec(0, 10);
        end if;

        if int = '1' then
            data <= "111010" & int_address;
        end if;
    end process;

    data_out <= data;
end architecture;
