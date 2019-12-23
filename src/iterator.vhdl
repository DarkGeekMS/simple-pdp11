library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.CONTROL_STORE;

entity iterator is
	port (
        clk      : in std_logic;
        ir       : in std_logic_vector(15 downto 0);             -- IR register data
        flag_regs: in std_logic_vector(4 downto 0);
        address  : in std_logic_vector(5 downto 0);              -- address to be fetched from control store
        hltop    : out std_logic;
        out_inst : out std_logic_vector(25 downto 0);            -- output micro instruction
        NAF      : out std_logic_vector(5 downto 0)              --next address field
    );
end entity;

architecture arch_iterator OF iterator is
begin
    process (ir, address)
    variable out1: std_logic_vector(25 DOWNTO 0);
    variable hlt: std_logic;
    begin
        out1 := CONTROL_STORE(to_integer(unsigned(address)));
        hlt := '0';
        if address = "010001" then
            NAF <= "011100";
        elsif address = "000100" then
            NAF <= "001111";
        else
        -- check PLAout = 0 return NAF
        if out1(3) = '0'  then
            NAF <= out1(25 downto 20);
        else
        -- check PLAout = 1
        -- check  group 9 = "000" return the starter output in NAF
            if out1(2) = '0' and out1(1) = '0' and out1(0) = '0' then
                case (ir (15 downto 12)) is
                    when "1111" =>             -- oneOp
                        if (ir( 5 downto 3) = "000") then
                            NAF <= "010000";
                        elsif (ir( 4 downto 3) = "01") then
                            NAF <= "010010";
                        elsif (ir( 4 downto 3) = "10") then
                            NAF <= "010100";
                        elsif (ir( 4 downto 3) = "11") then
                            NAF <= "010110";
                        elsif (ir( 5 downto 3) = "100") then
                            NAF <= "010001";
                        end if;

                    when "0000" =>             -- branching
                        NAF <= "101010";
                    when "1011" =>             -- No Operation
                        NAF <= "000000";
                    when "1100" =>             -- branching
                        NAF <= "101010";
                    when "1101" =>                  --JSR
                        NAF <= "100000";
                    when "1010" =>                  -- HLT
                        NAF <= "000000"; --what should i do here ?
                        hlt := '1';
                        -- add hlt = 1 here
                    when "1110" =>                -- specials
                        if(ir(11 downto 10) = "01" ) then
                            NAF <= "100100";                    --rts
                        elsif (ir(11 downto 10) = "10" ) then
                            NAF <= "011101";                    --int
                        else
                            NAF <= "100100";                    --iret
                        end if;
                    when others =>               -- 2 operands
                        if (ir( 11 downto 9) = "000") then
                            NAF <= "000011";
                        elsif (ir( 10 downto 9) = "01") then
                            NAF <= "000101";
                        elsif (ir( 10 downto 9) = "10") then
                            NAF <= "000111";
                        elsif (ir( 11 downto 9) = "100") then
                            NAF <= "000100";
                        else
                            NAF <= "001001";
                        end if;
                end case;

            -- check if ORdest  ( Bit ORing )
            elsif out1(2) = '0' and out1(1) = '0' and out1(0) = '1' then
                case( ir (4 downto 3) ) is
                    when "00" =>
                        if IR(5)= '0'  then
                            NAF <= "010000";
                        else
                            NAF <= "010001";
                        end if;
                    when "01" =>
                        NAF <= "010010";
                    when "10" =>
                        NAF <= "010100";
                    when OTHERS =>
                        NAF <= "010110";
                end case ;

            -- check if ORdest indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '0'  then                                         -- indirect reg
                if address = "110000" then
                    if IR(5 downto 3) = "000"  then
                        NAF <= "110001";
                    else
                        NAF <= "110010";
                    end if;
                else
                    if IR(5)= '0'  then
                        NAF <= "011100";
                    else
                        NAF <= "011011";
                    end if;
                end if;
            -- check if OR src indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '1'  then
                if (ir(11) = '0')   then    -- direct
                    NAF <= "001111";
                else
                    NAF <= "001110";
                end if;
            -- Check if OR result ( Bit ORing of branching)
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '0' then
                case( ir (11 downto 10) ) is
                    when "00" =>

                        if IR(15 downto 12) = "0000"  then                          -- BR
                            NAF <= out1(25 downto 20);
                        elsif IR(15 downto 12) = "1100" then                        -- BLS
                            if flag_regs(0) = '0' or flag_regs(1) = '1' then
                                NAF <= out1(25 downto 20);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "01" =>

                        if IR(15 downto 12) = "0000"  then                           --BEQ
                            if flag_regs(1) = '1' then
                                NAF <= out1(25 downto 20);
                            else
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                          --BHI
                            if flag_regs(0) = '1' then
                                NAF <= out1(25 downto 20);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "10" =>

                        if IR(15 downto 12) = "0000"  then                            --BNE
                            if flag_regs(1) = '0' then
                                NAF <= out1(25 downto 20);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "11" =>

                        if IR(15 downto 12) = "0000"  then                            --BLO
                            if flag_regs(0) = '0' then
                                NAF <= out1(25 downto 20);
                            else
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                         -- BHS
                                if flag_regs(0) = '1' or flag_regs(1) = '1'  then
                                    NAF <= out1(25 downto 20);
                                else
                                    NAF <= "000000";
                                end if;
                        else
                            NAF <= "000000";
                        end if;

                    when OTHERS =>
                        NAF <= "000000";
                end case ;

            -- check if OR op (Bit Oring operations )
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '1' then

                case( ir (15 downto 12) ) is
                    when "0001" =>                         --MOV case
                        if IR(5 downto 3)= "000"  then
                            NAF <= "101111";
                        else
                            NAF <= "101110";
                        end if;
                    when "1101" =>                         -- JSR
                        NAF <=  out1(25 downto 20);
                    when "1110" =>
                        if ir(11 downto 10) = "01" or ir(11 downto 10) = "10" then    --RTS or INTERRUPT
                            NAF <= "000000";
                        else                               --IRET
                            NAF <= out1(25 downto 20);
                        end if;
                    when OTHERS =>                        -- general case
                        NAF <= "110000";
                end case ;
            elsif out1(2) = '1' and out1(1) = '1'  then
                NAF <= out1(25 downto 20);
            end if;

        end if;
    end if;
        hltop <= hlt;
        if hlt = '1' then
            out_inst <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        else
            out_inst <= CONTROL_STORE(to_integer(unsigned(address)));
        end if;
    end process;

end architecture;