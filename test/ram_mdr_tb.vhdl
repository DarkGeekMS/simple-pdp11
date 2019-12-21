library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity ram_mdr_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of ram_mdr_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    -- mdr
    signal bidir_bus: std_logic_vector(15 downto 0); --in
    signal enable_in, enable_out: std_logic; --in

    -- ram
    signal rd, wr: std_logic; --in
    signal address: std_logic_vector(15 downto 0); --in
    signal ram_data: std_logic_vector(15 downto 0); 

    constant RAM_SIZE : integer := 100;
begin
    clk <= not clk after CLK_PERD / 2;

    ram : entity work.ram generic map (RAM_SIZE => RAM_SIZE) port map (rd => rd, wr => wr, address => address, clk => clk, 
        data_in => ram_data, data_out => ram_data);

    mdr : entity work.ram_reg generic map (WORD_WIDTH => 16) port map (bidir_bus => bidir_bus, enable_in => enable_in, 
        enable_out => enable_out, clk => clk, inout_ram => ram_data, 
        enable_in_ram => rd, enable_out_ram => wr);

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        rd <= '0';
        wr <= '0';
        ram_data <= (others => 'Z');
        enable_in <= '0';
        enable_out <= '0';
        bidir_bus <= (others => 'Z');

        if run("read_write_multiple") then
            for i in 0 to RAM_SIZE loop
                info("clk 0");
                    info("load mdr");
                    bidir_bus <= to_vec(i*100);
                    enable_in <= '1';

                    info("address to ram");
                    wr <= '1';
                    address <= to_vec(i);

                    wait for CLK_PERD;
                    enable_in <= '0';
                    wr <= '0';
                    address <= (others => 'Z');
                    bidir_bus <= (others => 'Z');
                ---

                info("clk 1");
                    info("address to ram");
                    rd <= '1';
                    address <= to_vec(i);

                    info("read mdr");
                    enable_out <= '1';

                    wait for CLK_PERD;
                    rd <= '0';
                    enable_out <= '0';
                    address <= (others => 'Z');

                    check_equal(bidir_bus, to_vec(i*100));
                ---
            end loop;
        end if;
        
        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
