library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ir_reg is
    generic (ADDR_SIZE: integer);

    port (
        data_in: in std_logic_vector(15 downto 0);
        enable_in, enable_out, clk: in std_logic;

        data_out: out std_logic_vector(15 downto 0);
        adr_field_out: out std_logic_vector(15 downto 0)
    );
end entity; 

architecture rtl of ir_reg is
    signal data_from_reg: std_logic_vector(15 downto 0);
begin
    reg: entity work.reg port map (data_in => data_in, enable_in => enable_in, 
        enable_out => enable_out, clk => clk, data_out => data_from_reg);

    adr_field_out <= std_logic_vector(to_unsigned(0, 16-ADDR_SIZE)) & data_from_reg(ADDR_SIZE-1 downto 0);
    data_out <= data_from_reg;
end architecture;
