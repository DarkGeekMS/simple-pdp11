library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity ram_reg_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of ram_reg_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    signal bidir_bus: std_logic_vector(31 downto 0);
    signal enable_in, enable_out: std_logic;
    signal inout_ram: std_logic_vector(31 downto 0);
    signal enable_in_ram, enable_out_ram: std_logic;
begin
    clk <= not clk after CLK_PERD / 2;

    ram_reg : entity work.ram_reg generic map (WORD_WIDTH => 32) port map (bidir_bus => bidir_bus, enable_in => enable_in, 
        enable_out => enable_out, clk => clk, inout_ram => inout_ram, 
        enable_in_ram => enable_in_ram, enable_out_ram => enable_out_ram);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        if run("enableout_enablein_set") then
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
            check_equal(bidir_bus, to_vec(x"FF00FF00", 32));
        end if;

        if run("enableout_enablein_unset") then
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
            check_equal(bidir_bus, to_vec(x"FF00FF00", 32));
        end if;

        if run("enableout_unset") then
            enable_out <= '0';
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check_equal(bidir_bus, to_vec('Z', 32));
        end if;

        if run("enable_out_ram_enable_in_ram_set") then
            enable_in_ram <= '1';
            inout_ram <= x"00000000";
            wait until rising_edge(clk);
            enable_in_ram <= '0';

            wait until clk = '0';

            enable_in_ram <= '1';
            inout_ram <= x"FF00FF00";
            wait until rising_edge(clk);

            enable_in_ram <= '0';
            enable_out_ram <= '1';
            inout_ram <= (others => 'Z');
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check_equal(inout_ram, to_vec(x"FF00FF00", 32));
        end if;
        
        if run("enable_out_ram_enable_in_ram_unset") then
            enable_in_ram <= '1';
            inout_ram <= x"00000000";
            wait until rising_edge(clk);
            enable_in_ram <= '0';

            wait until clk = '0';

            enable_in_ram <= '1';
            inout_ram <= x"FF00FF00";
            wait until rising_edge(clk);

            enable_in_ram <= '0';
            enable_out_ram <= '1';
            inout_ram <= (others => 'Z');
            wait until rising_edge(clk);

            enable_in_ram <= '0';
            inout_ram <= x"00FF00FF";
            wait until rising_edge(clk);

            enable_in_ram <= '0';
            enable_out_ram <= '1';
            inout_ram <= (others => 'Z');
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check_equal(inout_ram, to_vec(x"FF00FF00", 32));
        end if;

        if run("enable_out_ram") then 
            enable_out_ram <= '0';
            wait until rising_edge(clk);

            wait for 0.25*CLK_PERD;
            check_equal(inout_ram, to_vec('Z', 32));
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
