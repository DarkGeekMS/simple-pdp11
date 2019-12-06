library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity ir_reg_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of ir_reg_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    signal data_in: std_logic_vector(15 downto 0);
    signal enable_in, enable_out: std_logic;
    signal data_out: std_logic_vector(15 downto 0);
    signal adr_field_out: std_logic_vector(15 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    ir_reg: entity work.ir_reg generic map (ADDR_SIZE => 8) port map (data_in => data_in, data_out => data_out, 
        enable_in => enable_in, enable_out => enable_out, adr_field_out => adr_field_out, clk => clk);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);

        info("reset");
        data_in <= x"0000";
        enable_in <= '1';
        wait for CLK_PERD;
        enable_in <= '0';
        enable_out <= '0';

        if run("reset") then
            enable_out <= '1';
            wait for CLK_PERD;
            check(data_out = x"0000", "data is ok");
            check(adr_field_out = x"0000", "adr field is ok");
        end if;

        if run("check_adr_field") then
            data_in <= x"104A";
            enable_in <= '1';
            wait for CLK_PERD;
            enable_in <= '0';
            enable_out <= '1';
            wait for CLK_PERD;
            check(adr_field_out = x"004A", "adr field is ok");
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
