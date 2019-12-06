library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity reg_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of reg_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    signal bidir_bus: std_logic_vector(31 downto 0);
    signal enable_in, enable_out: std_logic;
begin
    clk <= not clk after CLK_PERD / 2;

    reg : entity work.reg generic map (WORD_WIDTH => 32) port map (data_in => bidir_bus, data_out => bidir_bus, enable_in => enable_in, 
        enable_out => enable_out, clk => clk);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);

        if run("basic") then
            enable_in <= '1';
            bidir_bus <= x"00000000";
            wait until rising_edge(clk);
            enable_in <= '0';

            wait until clk = '0';

            enable_in <= '1';
            bidir_bus <= x"FF00FF00";
            wait until rising_edge(clk);

            enable_in <= '0';
            enable_out <= '1';
            bidir_bus <= (others => 'Z');
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check(bidir_bus = x"FF00FF00", "");
        end if;

        if run("no_enable_in") then
            enable_in <= '1';
            bidir_bus <= x"00000000";
            wait until rising_edge(clk);
            enable_in <= '0';

            wait until clk = '0';

            enable_in <= '1';
            bidir_bus <= x"FF00FF00";
            wait until rising_edge(clk);

            enable_in <= '0';
            enable_out <= '1';
            bidir_bus <= (others => 'Z');
            wait until rising_edge(clk);

            enable_in <= '0';
            bidir_bus <= x"00FF00FF";
            wait until rising_edge(clk);

            enable_in <= '0';
            enable_out <= '1';
            bidir_bus <= (others => 'Z');
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check(bidir_bus = x"FF00FF00", "");

        end if;

        if run("no_enalbe_out") then
            enable_in <= '1';
            bidir_bus <= x"00000000";
            wait until rising_edge(clk);
            enable_in <= '0';

            wait until clk = '0';

            enable_in <= '1';
            bidir_bus <= x"FF00FF00";
            wait until rising_edge(clk);

            enable_in <= '0';
            enable_out <= '1';
            bidir_bus <= (others => 'Z');
            wait until rising_edge(clk);
            
            enable_out <= '0';
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check(bidir_bus = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ", "");
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
