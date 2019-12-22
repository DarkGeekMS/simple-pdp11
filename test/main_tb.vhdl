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
        signal mar_enable_in, mar_enable_out, mdr_enable_in, mdr_enable_out : std_logic;
        signal ir_enable_in : std_logic;
        signal pc_enable_in, pc_enable_out : std_logic;
        signal flags_enable_in, flags_enable_out : std_logic;
        signal r_enable_in, r_enable_out : std_logic_vector(7 downto 0);
        signal tmp_enable_in, tmp_enable_out : std_logic_vector(1 downto 0);

        -- ram
        signal rd, wr : std_logic;

        -- alu
        signal alu_enable : std_logic;
        signal alubuffer_enable_out : std_logic;

        -- iterator
        signal hlt : std_logic;
        signal controlsignals : std_logic_vector(37 downto 0);
        signal itr_current_adr : std_logic_vector(5 downto 0);
        signal itr_next_adr : std_logic_vector(5 downto 0);
        signal alu_out : std_logic_vector(15 downto 0);
    --

    -- internals
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
            clk => clk, data_out => bbus
        );
    end generate;

    pc : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => pc_enable_in, enable_out => pc_enable_out,
        clk => clk, data_out => bbus
    );

    tmp0 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp_enable_in(0), enable_out => '1',
        clk => clk, data_out => tmp0_to_alu
    );

    tmp1 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp_enable_in(1), enable_out => tmp_enable_out(1),
        clk => clk, data_out => bbus
    );

    ir : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => ir_enable_in, enable_out => '1',
        clk => clk, data_out => ir_data_out
    );

    flags : entity work.flags_reg port map (
        data_in => bbus, enable_in => flags_enable_in, enable_out => flags_enable_out,
        clk => clk, data_out => bbus,

        from_alu => alu_to_flags,
        enable_from_alu => alu_enable,
        always_out => flags_always_out
    );

    alu : entity work.alu generic map (N =>16) port map (
        clk => clk,
        temp0 => tmp0_to_alu,
        B => bbus,
        mode => ir_to_alu_mode(ir_data_out(15 downto 8)),
        en => alu_enable,
        flagIn => flags_always_out,
        IR_Check => ir_data_out(12),
        F => alu_out,
        flagOut => alu_to_flags
    );

    alu_buffer : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => alu_out, enable_in => alu_enable, enable_out => alubuffer_enable_out,
        clk => clk, data_out => bbus
    );

    mar : entity work.ram_reg generic map (WORD_WIDTH => 16) port map (
        clk => clk,
        bidir_bus => bbus,
        enable_in => mar_enable_in,
        enable_out => mar_enable_out,
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
        procedure reset is
        begin
            info("reset");
            mar_enable_in <= '0';
            mar_enable_out <= '0';
            mdr_enable_in <= '0';
            mdr_enable_out  <= '0';
            ir_enable_in  <= '0';
            pc_enable_in <= '0';
            pc_enable_out  <= '0';
            flags_enable_in <= '0';
            flags_enable_out  <= '0';
            r_enable_in <= (others => '0');
            r_enable_out <= (others => '0') ;
            tmp_enable_in <= (others => '0');
            tmp_enable_out <= (others => '0') ;
    
            -- ram
            rd <= '0';
            wr  <= '0';
    
            -- alu
            alu_enable  <= '0';
    
            -- iterator
            itr_current_adr <= (others => '0');

            bbus <= (others => 'Z');
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        reset;

        if run("ram") then
            mdr_enable_in <= '1';
            bbus <= (others => '1');
            wait for CLK_PERD;
            reset;

            mar_enable_in <= '1';
            bbus <= to_vec(1);
            wr <= '1';
            wait for CLK_PERD;
            reset;

            mdr_enable_out <= '1';
            rd <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec('1'));
            reset;
        end if;

        if run("fill_reg") then
            for i in 0 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait for CLK_PERD;
                reset;
            end loop;

            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait for CLK_PERD;
                check_equal(bbus, to_vec(i));
                reset;
            end loop;
        end if;

        if run("exch_reg") then
            r_enable_in(0) <= '1';
            bbus <= to_vec(512);
            wait for CLK_PERD;
            reset;

            for i in 1 to 7 loop
                r_enable_in(i) <= '1';
                bbus <= to_vec(i);
                wait for CLK_PERD;
                reset;
            end loop;

            for i in 1 to 7 loop
                r_enable_out(i-1) <= '1';
                r_enable_in(i) <= '1';
                wait for CLK_PERD;
                reset;
            end loop;
            
            info("checking registers");
            for i in 0 to 7 loop
                r_enable_out(i) <= '1';
                wait for CLK_PERD;
                check_equal(bbus, to_vec(512));
                reset;
            end loop;
        end if;

        if run("alu_inc") then
            bbus <= "1111" & "0000" & "00000000";
            ir_enable_in <= '1';
            wait for CLK_PERD;
            reset;

            bbus <= to_vec(214);
            alu_enable <= '1';
            wait for CLK_PERD;
            reset;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(215));
            reset;
        end if;

        if run("alu_add") then
            bbus <= "0010" & "0000" & "00000000";
            ir_enable_in <= '1';
            wait for CLK_PERD;
            reset;

            bbus <= to_vec(50);
            tmp_enable_in(0) <= '1';
            wait for CLK_PERD;
            reset;

            bbus <= to_vec(214);
            alu_enable <= '1';
            wait for CLK_PERD;
            reset;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(50+214));
            reset;
        end if;

        if run("alu_clears") then
            bbus <= "1111" & "0010" & "00000000";
            ir_enable_in <= '1';
            wait for CLK_PERD;
            reset;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec(0));
            reset;
        end if;

        if run("alu_lsl") then
            bbus <= "1111" & "1000" & "00000000";
            ir_enable_in <= '1';
            wait for CLK_PERD;
            reset;

            bbus <= to_vec('1');
            alu_enable <= '1';
            wait for CLK_PERD;
            reset;

            alubuffer_enable_out <= '1';
            wait for CLK_PERD;
            check_equal(bbus, to_vec('1', 15) & '0');
            reset;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
