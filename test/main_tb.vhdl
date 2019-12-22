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

    signal clk: std_logic := '0';
    
    signal bbus : std_logic_vector(15 downto 0);
    
    --externals
        -- registers
        signal mar_enable_in, mdr_enable_in, mdr_enable_out : std_logic;
        signal ir_enable_in : std_logic;
        signal flags_enable_in, flags_enable_out, flags_clr_carry, flags_set_carry : std_logic;
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
        signal controlsignals : std_logic_vector(37 downto 0);
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
begin
    clk <= not clk after CLK_PERD / 2;

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

    ir : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => ir_enable_in, enable_out => '1',
        clk => clk, data_out => ir_data_out, clr => '0'
    );

    flags : entity work.flags_reg port map (
        data_in => bbus, enable_in => flags_enable_in, enable_out => flags_enable_out,
        clk => clk, data_out => bbus,

        from_alu => alu_to_flags,
        enable_from_alu => alu_enable,
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

    ram : entity work.ram generic map (RAM_SIZE => 4*1024) port map (
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

    controlsignals <= decompress_control_signals(ir_data_out, itr_out_inst);

    main: process
        procedure resetbus is
        begin
            bbus <= (others => 'Z');
        end procedure;

        procedure resetsignals is
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
    
            -- ram
            rd <= '0';
            wr  <= '0';
    
            -- alu
            alu_enable  <= '0';
            alu_mode <= (others => '0');
            alubuffer_enable_out <= '0';
    
            -- iterator
            itr_current_adr <= (others => '0');

            resetbus;
        end procedure;

        procedure hookupsignals is
        begin
            resetbus;
            
            info("hookup signals from iterator");

            mar_enable_in        <= controlsignals(ICS_MAR_IN);
            mdr_enable_in        <= controlsignals(ICS_MDR_IN); 
            mdr_enable_out       <= controlsignals(ICS_MDR_OUT); 

            ir_enable_in         <= controlsignals(ICS_IR_IN); 

            flags_enable_in      <= controlsignals(ICS_FLAG_IN); 
            flags_enable_out     <= controlsignals(ICS_FLAG_OUT); 

            r_enable_in          <= controlsignals(ICS_PC_IN) & controlsignals(ICS_R6_IN downto ICS_R0_IN); 
            r_enable_out         <= controlsignals(ICS_PC_OUT) & controlsignals(ICS_R6_OUT downto ICS_R0_OUT); 

            tmp0_enable_in       <= controlsignals(ICS_TEMP0_IN); 
            tmp0_clr             <= controlsignals(ICS_CLR_TEMP0);
            tmp1_enable_in       <= controlsignals(ICS_TEMP1_IN); 
            tmp1_enable_out      <= controlsignals(ICS_TEMP1_OUT); 
    
            -- ram
            rd                   <= controlsignals(ICS_RD);
            wr                   <= controlsignals(ICS_WR);
    
            -- alu
            alu_enable           <= controlsignals(ICS_ALU_ENBL);
            alu_mode             <= controlsignals(ICS_ALU_3 downto ICS_ALU_0);
            alubuffer_enable_out <= controlsignals(ICS_ALU_OUT);

            if controlsignals(ICS_SET_CARRY) = '1' then
                flags_set_carry  <= '1';
            else
                flags_set_carry  <= '0';
            end if;

            if controlsignals(ICS_CLR_CARRY) = '1' then
                flags_clr_carry  <= '1';
            else
                flags_clr_carry  <= '0';
            end if;

            if controlsignals(ICS_ADRS_OUT) = '1' then
                if ir_data_out(15 downto 12) = "1101" then -- JSR
                    bbus <= to_vec(0, 4) & ir_data_out(12 downto 0);
                else -- BR
                    bbus <= to_vec(0, 6) & ir_data_out(10 downto 0);
                end if;
            end if;
            
            -- ignore ICS_PLA_OUT

        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        resetsignals;

        if run("ram") then
            mdr_enable_in <= '1';
            bbus <= (others => '1');
            wait for CLK_PERD;
            resetsignals;

            mar_enable_in <= '1';
            bbus <= to_vec(1);
            wr <= '1';
            wait for CLK_PERD;
            resetsignals;

            mdr_enable_out <= '1';
            rd <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec('1'));
            resetsignals;
        end if;

        if run("fill_reg") then
            for i in 0 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait for CLK_PERD;
                resetsignals;
            end loop;

            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait for CLK_PERD;
                check_equal(bbus, to_vec(i));
                resetsignals;
            end loop;
        end if;

        if run("exch_reg") then
            r_enable_in(0) <= '1';
            bbus <= to_vec(512);
            wait for CLK_PERD;
            resetsignals;

            for i in 1 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait for CLK_PERD;
                resetsignals;
            end loop;

            for i in 1 to 7 loop
                r_enable_out(i-1) <= '1';
                r_enable_in(i) <= '1';
                wait for CLK_PERD;
                resetsignals;
            end loop;
            
            info("checking registers");
            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait for CLK_PERD;
                check_equal(bbus, to_vec(512));
                resetsignals;
            end loop;
        end if;

        if run("alu_inc") then
            bbus <= to_vec(214);
            alu_mode <= "1110";
            alu_enable <= '1';
            wait for CLK_PERD;
            resetsignals;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(215));
            resetsignals;
        end if;

        if run("alu_add") then
            bbus <= to_vec(50);
            tmp0_enable_in <= '1';
            wait for CLK_PERD;
            resetsignals;

            bbus <= to_vec(214);
            alu_mode <= "0000";
            alu_enable <= '1';
            wait for CLK_PERD;
            resetsignals;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(50+214));
            resetsignals;
        end if;

        if run("alu_clears") then
            alu_mode <= "1111";
            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(0));
            resetsignals;
        end if;

        if run("alu_lsl") then
            bbus <= to_vec('1');
            alu_mode <= "1010";
            alu_enable <= '1';
            wait for CLK_PERD;
            resetsignals;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec('1', 15) & '0');
            resetsignals;
        end if;

        if run("iterator_fetches") then
            info("put instruction in ram");
            bbus <= (others => '0');
            mar_enable_in <= '1';
            wait for CLK_PERD;
            resetsignals;

            bbus <= "0001" & "000000" & "000001";
            mdr_enable_in <= '1';
            wr <= '1';
            wait for CLK_PERD;
            resetsignals;

            itr_current_adr <= (others => '0');
            check_equal(itr_next_adr, to_vec(1, 6));
            wait for CLK_PERD;

            itr_current_adr <= itr_next_adr;
            wait for CLK_PERD;

            itr_current_adr <= itr_next_adr;
            wait for CLK_PERD;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
