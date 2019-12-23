library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.decoders.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity main_tb is
    generic (runner_cfg: string);
end entity; 

architecture tb of main_tb is
    constant CLK_FREQ: integer := 100e6; -- 100 MHz
    constant CLK_PERD: time    := 1000 ms / CLK_FREQ;
    constant RAM_SIZE: integer := 4*1024;-- 4k Words

    signal clk: std_logic := '0';
    signal timeout: boolean:= false;
    
    signal bbus : std_logic_vector(15 downto 0);
    
    --externals
        -- registers
        signal mar_enable_in, mdr_enable_in, mdr_enable_out : std_logic;
        signal ir_enable_in, ir_reset : std_logic;
        signal flags_enable_in, flags_enable_out, flags_clr_carry, flags_set_carry, flags_enable_from_alu: std_logic;
        signal r_enable_in, r_enable_out : std_logic_vector(7 downto 0);
        signal tmp0_enable_in, tmp0_clr, tmp1_enable_in, tmp1_enable_out : std_logic;

        -- ram
        signal rd, wr : std_logic;

        -- alu
        signal alu_mode : std_logic_vector(3 downto 0);
        signal alu_enable : std_logic;
        signal alubuffer_enable_out : std_logic;

        -- iterator
        signal hlt : std_logic;
        signal itr_current_adr : std_logic_vector(5 downto 0);
        signal itr_next_adr : std_logic_vector(5 downto 0);
    --
        
    -- internals
        signal alu_out : std_logic_vector(15 downto 0);
        signal mar_to_ram, mdr_to_ram : std_logic_vector(15 downto 0);
        signal tmp0_to_alu : std_logic_vector(15 downto 0);
        signal ir_data_out : std_logic_vector(15 downto 0);
        signal flags_always_out : std_logic_vector(5-1 downto 0);
        signal alu_to_flags : std_logic_vector(5-1 downto 0);
        signal itr_out_inst : std_logic_vector(25 downto 0);
    --

    type RamDataType is array(natural range <>) of std_logic_vector(15 downto 0);
    signal ctrl_sigs : std_logic_vector(37 downto 0);

    signal num_iteration : unsigned(15 downto 0) := (others => 'Z');
begin
    clk <= not clk after CLK_PERD / 2;
    timeout <= true after 0.5 ms;

    r : for i in 0 to 7 generate
        ri : entity work.reg generic map (WORD_WIDTH => 16) port map (
            data_in => bbus, enable_in => r_enable_in(i), enable_out => r_enable_out(i),
            clk => clk, data_out => bbus, clr => '0'
        );
    end generate;

    tmp0 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp0_enable_in, enable_out => '1',
        clk => clk, data_out => tmp0_to_alu, clr => tmp0_clr
    );

    tmp1 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp1_enable_in, enable_out => tmp1_enable_out,
        clk => clk, data_out => bbus, clr => '0'
    );

    ir : entity work.ir_reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => ir_enable_in,
        clk => clk, data_out => ir_data_out, rst => ir_reset
    );

    flags : entity work.flags_reg port map (
        data_in => bbus, enable_in => flags_enable_in, enable_out => flags_enable_out,
        clk => clk, data_out => bbus,

        from_alu => alu_to_flags,
        enable_from_alu => flags_enable_from_alu,
        always_out => flags_always_out,
        clr_carry => flags_clr_carry,
        set_carry => flags_set_carry
    );

    alu : entity work.alu generic map (N =>16) port map (
        clk => clk,
        temp0 => tmp0_to_alu,
        B => bbus,
        mode => alu_mode,
        en => alu_enable,
        flagIn => flags_always_out,
        IR_Check => ir_data_out(12),
        F => alu_out,
        flagOut => alu_to_flags
    );

    alu_buffer : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => alu_out, enable_in => alu_enable, enable_out => alubuffer_enable_out,
        clk => clk, data_out => bbus, clr => '0'
    );

    mar : entity work.ram_reg generic map (WORD_WIDTH => 16) port map (
        clk => clk,
        bidir_bus => bbus,
        enable_in => mar_enable_in,
        enable_out => '0',
        inout_ram => mar_to_ram,
        enable_in_ram => '0',
        enable_out_ram => '1'
    );

    mdr : entity work.ram_reg generic map (WORD_WIDTH => 16) port map (
        clk => clk,
        bidir_bus => bbus,
        enable_in => mdr_enable_in,
        enable_out => mdr_enable_out,
        inout_ram => mdr_to_ram,
        enable_in_ram => rd,
        enable_out_ram => wr
    );

    ram : entity work.ram generic map (RAM_SIZE => RAM_SIZE) port map (
        clk => clk,
        rd => rd,
        wr => wr,
        address => mar_to_ram,
        data_in => mdr_to_ram,
		data_out => mdr_to_ram
    );

    iterator : entity work.iterator port map (
        clk       => clk,       
        ir        => ir_data_out,        
        flag_regs => flags_always_out, 
        address   => itr_current_adr,   
        hltop     => hlt,     
        out_inst  => itr_out_inst,  
        NAF       => itr_next_adr 
    );

    ctrl_sigs <= decompress_control_signals(ir_data_out, itr_out_inst);

    main: process
        procedure reset_bus is
        begin
            info("reset bus");
            bbus <= (others => 'Z');
        end procedure;

        procedure reset_signals is
        begin
            info("reset signals");
            mar_enable_in <= '0';
            mdr_enable_in <= '0';
            mdr_enable_out  <= '0';
            ir_enable_in  <= '0';
            flags_enable_in <= '0';
            flags_enable_out  <= '0';
            r_enable_in <= (others => '0');
            r_enable_out <= (others => '0');
            tmp0_enable_in <= '0';
            tmp1_enable_in <= '0';
            tmp1_enable_out <= '0';
            tmp0_clr <= '0';
            flags_set_carry  <= '0';
            flags_clr_carry  <= '0';
            flags_enable_from_alu <= '0';
            ir_reset <= '0';
    
            -- ram
            rd <= '0';
            wr  <= '0';
    
            -- alu
            alu_enable  <= '0';
            alu_mode <= (others => '0');
            alubuffer_enable_out <= '0';
    
            -- iterator
            itr_current_adr <= (others => '0');

            reset_bus;
        end procedure;

        procedure hookup_signals is
        begin
            if hlt = '1' then return; end if;

            check(not (ctrl_sigs(22) = '1' and ctrl_sigs(23) = '1'), "RD and WR cant be 1 at the same time", failure);

            info("hookup signals from iterator");

            mar_enable_in        <= ctrl_sigs(ICS_MAR_IN);
            mdr_enable_in        <= ctrl_sigs(ICS_MDR_IN); 
            mdr_enable_out       <= ctrl_sigs(ICS_MDR_OUT); 

            ir_enable_in         <= ctrl_sigs(ICS_IR_IN); 

            flags_enable_in      <= ctrl_sigs(ICS_FLAG_IN); 
            flags_enable_out     <= ctrl_sigs(ICS_FLAG_OUT); 
            flags_enable_from_alu<= not ctrl_sigs(ICS_FLAGS_IGNORE_ALU);

            r_enable_in          <= ctrl_sigs(ICS_PC_IN) & ctrl_sigs(ICS_R6_IN downto ICS_R0_IN); 
            r_enable_out         <= ctrl_sigs(ICS_PC_OUT) & ctrl_sigs(ICS_R6_OUT downto ICS_R0_OUT); 

            tmp0_enable_in       <= ctrl_sigs(ICS_TEMP0_IN); 
            tmp0_clr             <= ctrl_sigs(ICS_CLR_TEMP0);
            tmp1_enable_in       <= ctrl_sigs(ICS_TEMP1_IN); 
            tmp1_enable_out      <= ctrl_sigs(ICS_TEMP1_OUT); 
    
            -- ram
            rd                   <= ctrl_sigs(ICS_RD);
            wr                   <= ctrl_sigs(ICS_WR);
    
            -- alu
            alu_enable           <= ctrl_sigs(ICS_ALU_ENBL);
            alu_mode             <= ctrl_sigs(ICS_ALU_3 downto ICS_ALU_0);
            alubuffer_enable_out <= ctrl_sigs(ICS_ALU_OUT);

            -- ignore
            flags_set_carry  <= '0';

            -- ignore
            flags_clr_carry  <= '0';

            if ctrl_sigs(ICS_ADRS_OUT) = '1' then
                if ir_data_out(15 downto 12) = "1101" then -- JSR
                    bbus <= to_vec(0, 4) & ir_data_out(12 downto 0);
                else -- BR
                    bbus <= to_vec(0, 6) & ir_data_out(10 downto 0);
                end if;
            end if;
            
            -- ignore ICS_PLA_OUT

        end procedure;

        procedure reset_ir is 
        begin
            info("reset ir");
            ir_reset <= '1';
            wait until falling_edge(clk);
            reset_signals;
        end procedure;

        procedure fill_ram(ramdata: RamDataType) is
        begin
            info("start filling ram");
            for i in ramdata'range loop
                bbus <= to_vec(i);
                mar_enable_in <= '1';
                wait until falling_edge(clk);
                reset_signals;

                bbus <= ramdata(i);
                mdr_enable_in <= '1';
                wr <= '1';
                wait until falling_edge(clk);
                reset_signals;
            end loop;
            info("done filling ram");
        end procedure;

        procedure one_iteration is
        begin
            if num_iteration(0) = 'Z' then
                num_iteration <= to_unsigned(0, 16);
            end if;

            wait for 1 fs; 
            hookup_signals;
            wait until falling_edge(clk);
            itr_current_adr <= itr_next_adr; 

            num_iteration <= num_iteration + to_unsigned(1, 16);
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        reset_signals;

        if run("ram") then
            mdr_enable_in <= '1';
            bbus <= (others => '1');
            wait until falling_edge(clk);
            reset_signals;

            mar_enable_in <= '1';
            bbus <= to_vec(1);
            wr <= '1';
            wait until falling_edge(clk);
            reset_signals;

            mdr_enable_out <= '1';
            rd <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec('1'));
            reset_signals;
        end if;

        if run("fill_reg") then
            for i in 0 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait until falling_edge(clk);
                reset_signals;
            end loop;

            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait until falling_edge(clk);
                check_equal(bbus, to_vec(i));
                reset_signals;
            end loop;
        end if;

        if run("exch_reg") then
            r_enable_in(0) <= '1';
            bbus <= to_vec(512);
            wait until falling_edge(clk);
            reset_signals;

            for i in 1 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait until falling_edge(clk);
                reset_signals;
            end loop;

            for i in 1 to 7 loop
                r_enable_out(i-1) <= '1';
                r_enable_in(i) <= '1';
                wait until falling_edge(clk);
                reset_signals;
            end loop;
            
            info("checking registers");
            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait until falling_edge(clk);
                check_equal(bbus, to_vec(512));
                reset_signals;
            end loop;
        end if;

        if run("alu_inc") then
            bbus <= to_vec(214);
            alu_mode <= "1110";
            alu_enable <= '1';
            wait until falling_edge(clk);
            reset_signals;

            alubuffer_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(215));
            reset_signals;
        end if;

        if run("alu_add") then
            bbus <= to_vec(50);
            tmp0_enable_in <= '1';
            wait until falling_edge(clk);
            reset_signals;

            bbus <= to_vec(214);
            alu_mode <= "0000";
            alu_enable <= '1';
            wait until falling_edge(clk);
            reset_signals;

            alubuffer_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(50+214));
            reset_signals;
        end if;

        if run("alu_clears") then
            alu_mode <= "1111";
            alubuffer_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(0));
            reset_signals;
        end if;

        if run("alu_lsl") then
            bbus <= to_vec('1');
            alu_mode <= "1010";
            alu_enable <= '1';
            wait until falling_edge(clk);
            reset_signals;

            alubuffer_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec('1', 15) & '0');
            reset_signals;
        end if;

        if run("iterator_fetches") then
            fill_ram((
                to_vec("0001" & "000000" & "000001"), -- MOV R0 R1
                to_vec("1010" & "000000000000")       -- HLT
            ));

            info("start fetching");
            for i in 0 to 2 loop
                one_iteration;
            end loop;
            reset_signals;

            wait until falling_edge(clk);
            check_equal(ir_data_out, to_vec("0001" & "000000" & "000001"));
        end if;

        if run("mov_r0_r1") then
            fill_ram((
                to_vec("0001" & "000000" & "000001"), -- MOV R0 R1
                to_vec("1010" & "000000000000")       -- HLT
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(121);
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            for i in 1 to 3+4 loop
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(121));
            reset_signals;
        end if;

        if run("hlt") then
            fill_ram((
                to_vec("1010" & "000000000000"),       -- HLT
                to_vec(0)
            ));

            info("start fetching");
            for i in 1 to 3 loop
                one_iteration;
            end loop;

            check_equal(hlt, '1');
            reset_signals;
        end if;

        if run("mov_r0_r1_halts") then
            fill_ram((
                to_vec("0001" & "000000" & "000001"), -- MOV R0 R1
                to_vec("1010" & "000000000000")       -- HLT
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(121);
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(121));
            reset_signals;
        end if;

        if run("add_r0_plus_r1") then
            fill_ram((
                to_vec("0010" & "001000" & "000001"),  -- ADD (R0)+ R1
                to_vec("1010" & "000000000000"),       -- HLT
                to_vec(100)                            -- data
            ));

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= to_vec(121);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(2);
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r0");
            reset_signals;
            r_enable_out(0) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(3));
            reset_signals;

            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(221));
            reset_signals;
        end if;

        if run("adc_minus_r0_r1") then
            fill_ram((
                to_vec( "0011" & "010000" & "000001"), -- ADC -(R0) R1
                to_vec("1010" & "000000000000"),       -- HLT
                to_vec(100)                            -- data
            ));

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= to_vec(121);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(3);
            wait until falling_edge(clk);
            reset_signals;

            info("set carry");
            flags_set_carry <= '1';
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r0");
            reset_signals;
            r_enable_out(0) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(2));
            reset_signals;

            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(121+100+1));
            reset_signals;

            info("check carry");
            flags_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus(IFR_CARRY), '0');
            reset_signals;
        end if;

        if run("sub_xr0_r1") then
            fill_ram((
                to_vec("0100" & "011000" & "000001"), -- SUB X(R0) R1
                to_vec(1),                            -- X
                to_vec("1010" & "000000000000"),      -- HLT
                to_vec(50)                            -- data
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(2);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= to_vec(60);
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(50-60));
            reset_signals;
        end if;

        if run("and_atr0_r1") then
            fill_ram((
                to_vec("0110" & "100000" & "000001"), -- AND @R0 R1
                to_vec("1010" & "000000000000"),      -- HLT
                to_vec(x"0F0F")
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(2);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= x"0FFF";
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(x"0F0F"));
            reset_signals;
        end if;

        if run("or_atr0_plus_r1") then
            fill_ram((
                to_vec("0111" & "101000" & "000001"), -- OR @(R0)+ R1
                to_vec("1010" & "000000000000"),      -- HLT
                to_vec(3),
                to_vec(x"0F0F")
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(2);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= x"F0FF";
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;

            info("check r0");
            r_enable_out(0) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(3));
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(x"0F0F") or to_vec(x"F0FF"));
            reset_signals;
        end if;

        if run("xnor_at_minus_r0_r1") then
            fill_ram((
                to_vec("1000" & "110000" & "000001"), -- XNOR @-(R0) R1
                to_vec("1010" & "000000000000"),      -- HLT
                to_vec(3),
                to_vec(x"0F0F")
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(3);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= x"F0FF";
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;

            info("check r0");
            r_enable_out(0) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(2));
            reset_signals;
            
            info("check r1");
            r_enable_out(1) <= '1';
            wait until falling_edge(clk);
            check_equal(bbus, to_vec(x"0F0F") xnor to_vec(x"F0FF"));
            reset_signals;
        end if;

        if run("cmp_atxr0_r1") then
            fill_ram((
                to_vec("1001" & "111000" & "000001"), -- CMP @X(R0) R1
                to_vec(50),
                to_vec("1010" & "000000000000"),      -- HLT
                to_vec(4),
                to_vec(1000)
            ));

            info("fill r0");
            reset_signals;
            r_enable_in(0) <= '1';
            bbus <= to_vec(-47);
            wait until falling_edge(clk);
            reset_signals;

            info("fill r1");
            reset_signals;
            r_enable_in(1) <= '1';
            bbus <= to_vec(329);
            wait until falling_edge(clk);
            reset_signals;

            info("start fetching");
            while hlt = '0' loop
                check(timeout = false, "timeouted!", failure);
                one_iteration;
            end loop;
            reset_signals;
            
            info("check flags");
            flags_enable_out <= '1';
            wait until falling_edge(clk);
            check_equal(bbus(IFR_CARRY), '0', "carry");
            check_equal(bbus(IFR_ZERO), '0', "zero");
            check_equal(bbus(IFR_NEG), '1', "negative");
            check_equal(bbus(IFR_OVERFLOW), '0', "overflow");
            reset_signals;
        end if;

        -- if run("fullrun") then
        --     fill_ram((
        --         to_vec("0001" & "000000" & "000001"), -- mov r0 r1
        --         to_vec("1010" & "000000000000")       -- hlt
        --     ));

        --     info("start");
        --     while not hlt = '1' loop
        --         check(timeout = false, "timeouted!", failure);
        --         one_iteration;
        --     end loop;
        --     info("ended");
        -- end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
