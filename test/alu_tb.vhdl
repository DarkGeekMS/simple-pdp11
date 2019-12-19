library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity alu_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of alu_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;

    signal clk: std_logic := '0';

    -- alu
    signal temp0 ,B: std_logic_vector(16-1 downto 0); --in
    signal en: std_logic; --in
    signal flagIn: std_logic_vector(4 downto 0); --in

    signal F: std_logic_vector(15 downto 0); --out
    signal flagOut: std_logic_vector(4 downto 0); --out

    -- alu_decoder
    signal IR_SUB: std_logic_vector(7 downto 0); --in
    signal ALU_MODE: std_logic_vector(3 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    alu: entity work.alu port map (
        temp0 => temp0, B => B, mode => ALU_MODE, 
        clk => clk, en => en, flagIn => flagIn, F => F, flagOut => flagOut
    );

    alu_decoder: entity work.alu_decoder port map (
        IR_SUB => IR_SUB, ALU_MODE => ALU_MODE
    );

    main: process
    begin
        test_runner_setup(runner, runner_cfg);

        B <= (others => '0');
        temp0 <= (others => '0');
        IR_SUB <= (others => '0');

        flagIn <= (others => '0');
        en <= '1';

        if run("no_enable") then
            en <= '0';
            wait for CLK_PERD;
            check_equal(F, to_vec('Z', 16));
        end if;

        if run("enable") then
            en <= '1';
            wait for CLK_PERD;
            check_equal(F, to_vec('U', 16));
        end if;

        if run("add") then
            IR_SUB(7 downto 4) <= "0010";
            B <= to_vec(5, 16);
            temp0 <= to_vec(10, 16);
            wait for CLK_PERD;
            check_equal(F, to_vec(15, 16));
        end if;

        if run("adc_carry0") then
            IR_SUB(7 downto 4) <= "0011";
            B <= to_vec(5, 16);
            temp0 <= to_vec(10, 16);
            flagIn(CARRY_FLAG) <= '0';
            wait for CLK_PERD;
            check_equal(F, to_vec(15, 16));
        end if;

        if run("adc_carry1") then
            IR_SUB(7 downto 4) <= "0011";
            B <= to_vec(5, 16);
            temp0 <= to_vec(10, 16);
            flagIn(CARRY_FLAG) <= '1';
            wait for CLK_PERD;
            check_equal(F, to_vec(16, 16));
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
