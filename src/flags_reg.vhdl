library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flags_reg is
    generic (WORD_WIDTH: integer := 16);

    port (
        -- ordinary reg
        data_in: in std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_in, enable_out, clk: in std_logic;

        data_out: out std_logic_vector(WORD_WIDTH-1 downto 0);

        -- flags additional ports
        from_alu: in std_logic_vector(WORD_WIDTH-1 downto 0);
        enable_from_alu: in std_logic;

        always_out: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end entity; 

architecture rtl of flags_reg is
    signal data: std_logic_vector(WORD_WIDTH-1 downto 0);
begin
    process (enable_in, clk, enable_from_alu, from_alu) 
    begin
        if enable_from_alu = '1' then
            data <= from_alu;
        end if;

        if enable_in = '1' and rising_edge(clk) then
            data <= data_in;
        end if;
    end process;

    process (enable_out, clk) 
    begin
        if enable_out = '1' then
            if rising_edge(clk) then
                data_out <= data;
            end if;
        else 
            data_out <= (others => 'Z');
        end if;
    end process;

    always_out <= data;
end architecture;
