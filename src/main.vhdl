library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.decoders.all;
use work.vunit_alternative.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity main is
    generic (
        INPUT_FILE_PATH : string := "input.txt";
        OUTPUT_FILE_PATH: string := "output.txt"
    );

    port (
        clk: in std_logic;
        rst: in std_logic;
        int: in std_logic;
        int_address: in std_logic_vector(9 downto 0);
        bbus: inout std_logic_vector(15 downto 0);
        hlt: out std_logic
    );
end entity; 

architecture tb of main is
    constant RAM_SIZE: integer := 4*1024;-- 4k Words
    
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
        signal hlt_iterator : std_logic;
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

    signal tmp1_clr : std_logic;
    signal r_clr : std_logic_vector(7 downto 0);

    signal ir_data_to_itr : std_logic_vector(15 downto 0);
begin
    r : for i in 0 to 7 generate
        ri : entity work.reg generic map (WORD_WIDTH => 16) port map (
            data_in => bbus, enable_in => r_enable_in(i), enable_out => r_enable_out(i),
            clk => clk, data_out => bbus, clr => r_clr(i)
        );
    end generate;

    tmp0 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp0_enable_in, enable_out => '1',
        clk => clk, data_out => tmp0_to_alu, clr => tmp0_clr
    );

    tmp1 : entity work.reg generic map (WORD_WIDTH => 16) port map (
        data_in => bbus, enable_in => tmp1_enable_in, enable_out => tmp1_enable_out,
        clk => clk, data_out => bbus, clr => tmp1_clr
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
        ir        => ir_data_to_itr,        
        flag_regs => flags_always_out, 
        address   => itr_current_adr,   
        hltop     => hlt_iterator,     
        out_inst  => itr_out_inst,  
        NAF       => itr_next_adr 
    );

    hlt <= hlt_iterator;

    ctrl_sigs <= decompress_control_signals(ir_data_to_itr, itr_out_inst);

    main: process (clk, rst, int, bbus, int_address)
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

            tmp1_clr <= '0';
            r_clr <= (others => '0');
        end procedure;

        procedure hookup_signals is
        begin
            if hlt_iterator = '1' then return; end if;
            reset_bus;

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
                if ir_data_to_itr(15 downto 12) = "1101" then -- JSR
                    bbus <= to_vec(0, 4) & ir_data_to_itr(11 downto 0);
                else -- BR
                    bbus <= to_vec(0, 6) & ir_data_to_itr(9 downto 0);
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

        impure function read_input return RamDataType is
            file input_file: text;

            variable tmp_in_line: line;
            variable tmp_word : std_logic_vector(15 downto 0);
            variable i: integer := 0;
            variable data: RamDataType(0 to 4*1024);
        begin
            file_open(input_file, "../" & INPUT_FILE_PATH,  read_mode);

            while not endfile(input_file) loop
                readline(input_file, tmp_in_line);
                read(tmp_in_line, tmp_word);

                data(i) := tmp_word;
            end loop;

            file_close(input_file);
        end function;
    begin
        if rst = '1' then
            itr_current_adr <= (others => '0');

            reset_signals;
            ir_reset <= '1';
            tmp1_clr <= '1';
            tmp0_clr <= '1';
            r_clr <= (others => '1');

            num_iteration <= to_unsigned(0, 16);
        elsif int = '1' and falling_edge(clk) then
            ir_data_to_itr <= "111010" & int_address;
            itr_current_adr <= "000010";
            hookup_signals;

            num_iteration <= num_iteration + to_unsigned(1, 16);
        elsif falling_edge(clk) then
            ir_data_to_itr <= ir_data_out;
            itr_current_adr <= itr_next_adr; 
            hookup_signals;

            num_iteration <= num_iteration + to_unsigned(1, 16);
        end if;
    end process;
end architecture;
