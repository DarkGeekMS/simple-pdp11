library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity ir_reg is
    generic (WORD_WIDTH: integer := 16);

    port (
        data_in: in std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_in, clk, rst: in std_logic;

        data_out: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end entity; 

architecture rtl of ir_reg is
    signal data: std_logic_vector(WORD_WIDTH-1 downto 0) := "110010" & to_vec(0, 10);
begin
    process (enable_in, clk, data_in, rst) 
    begin
        if enable_in = '1' and clk = '1' then
            data <= data_in;
        end if;

        if rst = '1' and clk = '1' then
            data <= "110010" & to_vec(0, 10);
        end if;
    end process;

    data_out <= data;
end architecture;
