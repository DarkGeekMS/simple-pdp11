library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity starter_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of starter_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';
begin
    clk <= not clk after CLK_PERD / 2;

    -- starter: entity work.starter port map ( );

    main: process
    begin
        test_runner_setup(runner, runner_cfg);

        if run("test_case_name") then

        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
