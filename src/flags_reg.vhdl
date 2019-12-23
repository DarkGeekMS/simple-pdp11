library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity flags_reg is
    port (
        -- ordinary reg
        data_in: in std_logic_vector(16-1 downto 0);
        enable_in, enable_out, clk: in std_logic;

        data_out: out std_logic_vector(16-1 downto 0);

        -- flags additional ports
        from_alu: in std_logic_vector(5-1 downto 0);
        enable_from_alu: in std_logic;
        clr_carry: in std_logic;
        set_carry: in std_logic;

        always_out: out std_logic_vector(5-1 downto 0)
    );
end entity; 

architecture rtl of flags_reg is
    signal data: std_logic_vector(5-1 downto 0) := (others => '0');
begin
    process (enable_in, clk, enable_from_alu, from_alu, data_in, clr_carry, set_carry) 
    begin
        if clr_carry = '1' then
            data(IFR_CARRY) <= '0';
        end if;

        if set_carry = '1' then
            data(IFR_CARRY) <= '1';
        end if;

        if enable_from_alu = '1' and from_alu /= "ZZZZZ" and falling_edge(clk) then
            data <= from_alu;
        end if;

        if enable_in = '1' and clk = '1' then
            data <= data_in(5-1 downto 0);
        end if;
    end process;

    process (enable_out, clk) 
    begin
        if enable_out = '1' then
            if rising_edge(clk) then
                data_out <= to_vec(0, 16-5) & data;
            end if;
        else 
            data_out <= (others => 'Z');
        end if;
    end process;

    always_out <= data;
end architecture;
