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
    signal hltop    : std_logic;                         -- out
    function cs(adr: std_logic_vector(5 downto 0)) return std_logic_vector is
    begin
        return CONTROL_STORE(to_integer(unsigned(adr)));
    end function;

    type address_fields_type is array(natural range <>) of std_logic_vector(5 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    iterator: entity work.iterator port map (
        ir => ir, flag_regs => flag_regs, clk => clk,
        address => address, out_inst => out_inst, NAF => NAF , hltop => hltop
    );

    main: process
        procedure test_iterator(fields: address_fields_type) is
        begin
            for i in 0 to fields'length-2 loop
                address <= fields(i);
                wait for CLK_PERD;
                check_equal(NAF, fields(i+1), "check next address field #" & integer'image(i));
                check_equal(out_inst, cs(fields(i)), "check output instructions #" & integer'image(i));
            end loop;

            address <= fields(fields'length-1);
            wait for CLK_PERD;
            check_equal(NAF, to_vec(0, 6), "check next address field #" & integer'image(fields'length-1));
            check_equal(out_inst, cs(fields(fields'length-1)), "check output instructions #" & integer'image(fields'length-1));
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        ir <= (others => '0');
        flag_regs <= (others => '0');
        address <= (others => '0');

        if run("fetch") then
            ir <= (others => '-');

            address <= (others => '0');
            wait for CLK_PERD;
            check_equal(NAF, to_vec("000001", 6), "check first next address field");
            check_equal(out_inst, cs("000000"), "check first output instructions");

            address <= NAF;
            wait for CLK_PERD;
            check_equal(NAF, to_vec("000010", 6), "check second next address field");
            check_equal(out_inst, cs("000001"), "check second output instructions");

        end if;

        if run("mov_r0_r1") then
            ir <= "0001" & "000000" & "000001";

            test_iterator((
                "000010",
                "000011",
                "010000",
                "101111"
            ));
        end if;

        if run("add_r0_plus_r1") then
            ir <= "0010" & "001000" & "000001";

            test_iterator((
                "000010",
                "000101",
                "000110",
                "001111",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("adc__minus_r0_r1") then
            ir <= "0011" & "010000" & "000001";

            test_iterator((
                "000010",
                "000111",
                "001000",
                "001111",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("sub_xr0_r1") then
            ir <= "0100" & "011000" & "000001";

            test_iterator((
                "000010",
                "001001",
                "001010",
                "001011",
                "001100",
                "001101",
                "001111",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("and_atr0_r1") then
            ir <= "0110" & "100000" & "000001";

            test_iterator((
                "000010",
                "000100",
                "001110",
                "001111",
                "010000",
                "110000",
                "110001"

            ));
        end if;

        if run("or_atr0_plus_r1") then
            ir <= "0111" & "101000" & "000001";

            test_iterator((
                "000010",
                "000101",
                "000110",
                "001110",
                "001111",
                "010000",
                "110000",
                "110001"

            ));
        end if;

        if run("xnor_at_minus_r0_r1") then
            ir <= "1000" & "110000" & "000001";

            test_iterator((
                "000010",
                "000111",
                "001000",
                "001110",
                "001111",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("cmp_atxr0_r1") then
            ir <= "1001" & "111000" & "000001";

            test_iterator((
                "000010",
                "001001",
                "001010",
                "001011",
                "001100",
                "001101",
                "001110",
                "001111",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("add_r3_r5_plus") then
            ir <= "0010" & "000011" & "001101";

            test_iterator((
                "000010",
                "000011",
                "010010",
                "010011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("adc_r3__minus_r5") then
            ir <= "0011" & "000011" & "010101";

            test_iterator((
                "000010",
                "000011",
                "010100",
                "010101",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("sub_r3_xr5") then
            ir <= "0100" & "000011" & "011101";

            test_iterator((
                "000010",
                "000011",
                "010110",
                "010111",
                "011000",
                "011001",
                "011010",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("and_r3_atr5") then
            ir <= "0110" & "000011" & "100101";
            test_iterator((
                "000010",
                "000011",
                "010001",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("or_r3_atr5_plus") then
            ir <= "0111" & "000011" & "101101";

            test_iterator((
                "000010",
                "000011",
                "010010",
                "010011",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("xnor_r3_at_minus_r5") then
            ir <= "1000" & "000011" & "110101";

            test_iterator((
                "000010",
                "000011",
                "010100",
                "010101",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("cmp_r3_atxr5") then
            ir <= "1001" & "000011" & "111101";

            test_iterator((
                "000010",
                "000011",
                "010110",
                "010111",
                "011000",
                "011001",
                "011010",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        ir <= "000001" & "0000000010";
        if run("beq_2_true") then
            flag_regs <= "00010";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("beq_2_false") then
            ir <= "000001" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;

        if run("br") then
            ir <= "000000" & "0000000010";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;


        if run("bne_2_true") then
            ir <= "000010" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("bne_2_false") then
            ir <= "000010" & "0000000010";
            flag_regs <= "00010";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;


        if run("blo_2_false") then
            ir <= "000011" & "0000000010";
            flag_regs <= "00001";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;

        if run("blo_2_true") then
            ir <= "000011" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;


        if run("bls_2_false") then
            ir <= "110000" & "0000000010";
            flag_regs <= "00001";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;

        if run("bls_2_true1") then
            ir <= "110000" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("bls_2_true2") then
            ir <= "110000" & "0000000010";
            flag_regs <= "00011";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;


        if run("bhi_2_false") then
            ir <= "110001" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;

        if run("bhi_2_true") then
            ir <= "110001" & "0000000010";
            flag_regs <= "00001";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("bhs_2_false") then
            ir <= "110011" & "0000000010";
            flag_regs <= "00000";

            test_iterator((
                "000010",
                "101010"
            ));
        end if;

        if run("bhs_2_true1") then
            ir <= "110011" & "0000000010";
            flag_regs <= "00001";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("bhs_2_true2") then
            ir <= "110011" & "0000000010";
            flag_regs <= "00010";

            test_iterator((
                "000010",
                "101010",
                "101011",
                "101100",
                "101101"
            ));
        end if;

        if run("inc_r0") then
            ir <= "11110000" & "00000000";

            test_iterator((
                "000010",
                "010000",
                "110000",
                "110001"
            ));
        end if;

        if run("inc_atr0") then
            ir <= "11110000" & "00100000";

            test_iterator((
                "000010",
                "010001",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_r0plus") then
            ir <= "11110000" & "00001000";

            test_iterator((
                "000010",
                "010010",
                "010011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_minusr0") then
            ir <= "11110000" & "00010000";

            test_iterator((
                "000010",
                "010100",
                "010101",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_xr0") then
            ir <= "11110000" & "00011000";

            test_iterator((
                "000010",
                "010110",
                "010111",
                "011000",
                "011001",
                "011010",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_atr0plus") then
            ir <= "11110000" & "00101000";

            test_iterator((
                "000010",
                "010010",
                "010011",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_atminusr0") then
            ir <= "11110000" & "00110000";

            test_iterator((
                "000010",
                "010100",
                "010101",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;

        if run("inc_atxr0") then
            ir <= "11110000" & "00111000";

            test_iterator((
                "000010",
                "010110",
                "010111",
                "011000",
                "011001",
                "011010",
                "011011",
                "011100",
                "110000",
                "110010"
            ));
        end if;



        if run("hlt") then
            ir <= "1010" & "000000000000";
            address <= "000010";
            wait for CLK_PERD;
            check_equal(hltop, '1');
            check_equal(out_inst, to_vec('Z', 26));
        end if;

        if run("nop") then
            ir <= "1011" & "000000000000";
            address <= "000010";
            wait for CLK_PERD;
            check_equal(NAF, to_vec(0, 6), "nop is redirected to fetch");
        end if;

        if run("jsr_100") then
            ir <= "1101" & "100000000000";

            test_iterator((
                "000010",
                "100000",
                "100001",
                "100010",
                "100011"
            ));
        end if;

        if run("rts") then
            ir <= "111001" & "0000000000";

            test_iterator((
                "000010",
                "100100",
                "100101",
                "100110"
            ));
        end if;

        if run("int") then
            ir <= "111010" & "0000000000";

            test_iterator((
                "000010",
                "011101",
                "011110",
                "011111",
                "100000",
                "100001",
                "100010"
            ));
        end if;

        if run("iret") then
            ir <= "111011" & "0000000000";

            test_iterator((
                "000010",
                "100100",
                "100101",
                "100110",
                "100111",
                "101000",
                "101001"
            ));
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
