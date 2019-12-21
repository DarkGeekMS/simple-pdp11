library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_reg is
    generic (WORD_WIDTH : integer := 16);
    
    port (
        bidir_bus: inout std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_in, enable_out, clk: in std_logic;

        inout_ram: inout std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_in_ram, enable_out_ram: in std_logic
    );
end entity;

architecture rtl of ram_reg is
    signal data: std_logic_vector(WORD_WIDTH-1 downto 0);
begin
    process (enable_in_ram, enable_in, clk) 
    begin
        if enable_in = '1' and rising_edge(clk) then
            data <= bidir_bus;
        end if;

        if enable_in_ram = '1' and rising_edge(clk) then
            data <= inout_ram;
        end if;
    end process;

    process (enable_out_ram, enable_out, clk) 
    begin
        if enable_out = '1' then
            if rising_edge(clk) then
                bidir_bus <= data;
            end if;
        else
            bidir_bus <= (others => 'Z');
        end if;
        
        if enable_out_ram = '1' then
            if rising_edge(clk) then
                inout_ram <= data;
            end if;
        else 
            inout_ram <= (others => 'Z');
        end if;
    end process;
end architecture;
