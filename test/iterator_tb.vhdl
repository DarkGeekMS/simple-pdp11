library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity iterator_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of iterator_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    -- iterator
    signal ir       : std_logic_vector(15 downto 0);     -- in
    signal flag_regs: std_logic_vector(4 downto 0);      -- in
    signal address  : std_logic_vector(5 downto 0);      -- in

    signal out_inst : std_logic_vector(26-1 downto 0);   -- out
    signal NAF      : std_logic_vector(5 downto 0);      -- out

    function cs(adr: std_logic_vector(5 downto 0)) return std_logic_vector is
        variable i:integer := to_integer(unsigned(adr));
    begin
        return CONTROL_STORE(i);
    end function;
begin
    clk <= not clk after CLK_PERD / 2;

    iterator: entity work.iterator port map (
        ir => ir, flag_regs => flag_regs, clk => clk,
        address => address, out_inst => out_inst, NAF => NAF
    );

    main: process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        ir <= (others => '0');
        flag_regs <= (others => '0');
        address <= (others => '0');

        if run("fetch") then
            address <= (others => '0');
            wait for CLK_PERD;
            check_equal(NAF, to_vec("000001", 6), "check first next address field");
            check_equal(out_inst, cs("000000"), "check first output instructions");

            address <= NAF;
            wait for CLK_PERD;
            check_equal(NAF, to_vec("000010", 6), "check second next address field");
            check_equal(out_inst, cs("000001"), "check second output instructions");

            address <= NAF;
            wait for CLK_PERD;
            check_equal(NAF, to_vec("000011", 6), "check last and third next address field");
            check_equal(out_inst, cs("000010"), "check last and third output instructions");
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
