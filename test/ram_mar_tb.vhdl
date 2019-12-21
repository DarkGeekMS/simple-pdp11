library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity ram_mar_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of ram_mar_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    -- mar
    signal bidir_bus: std_logic_vector(15 downto 0); --in
    signal enable_in: std_logic; --in

    -- ram
    signal rd, wr: std_logic; --in
    signal data_in: std_logic_vector(15 downto 0); --in
    signal data_out: std_logic_vector(15 downto 0); --out
    signal address: std_logic_vector(15 downto 0);

    constant RAM_SIZE : integer := 100;
begin
    clk <= not clk after CLK_PERD / 2;

    ram : entity work.ram generic map (RAM_SIZE => RAM_SIZE) port map (rd => rd, wr => wr, address => address, clk => clk, 
        data_in => data_in, data_out => data_out);

    mar : entity work.ram_reg generic map (WORD_WIDTH => 16) port map (bidir_bus => bidir_bus, enable_in => enable_in, 
        enable_out => '0', clk => clk, inout_ram => address, 
        enable_in_ram => '0', enable_out_ram => '1');

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        rd <= '0';
        wr <= '0';
        data_in <= (others => 'Z');
        enable_in <= '0';
        bidir_bus <= (others => 'Z');

        if run("read_write_multiple") then
            for i in 0 to RAM_SIZE loop
                info("clk 0");
                    info("load mar");
                    bidir_bus <= to_vec(i);
                    enable_in <= '1';

                    info("write to ram");
                    wr <= '1';
                    data_in <= to_vec(i*100);

                    wait for CLK_PERD;
                    enable_in <= '0';
                    wr <= '0';
                    data_in <= (others => 'Z');
                    bidir_bus <= (others => 'Z');
                ---

                info("clk 1");
                    info("read ram");
                    rd <= '1';

                    wait for CLK_PERD;
                    rd <= '0';

                    check_equal(data_out, to_vec(i*100));
                ---
            end loop;
        end if;
        
        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
