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
        out_inst : out std_logic_vector(25 downto 0);            -- output micro instruction
        NAF      : out std_logic_vector(5 downto 0)              --next address field
    );
end entity;

architecture arch_iterator OF iterator is
begin
    process (ir, address)
    variable out1: std_logic_vector(25 DOWNTO 0);
    begin
        out1 := CONTROL_STORE(to_integer(unsigned(address)));
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
                        elsif (ir( 5 downto 3) = "001") then
                            NAF <= "010010";
                        elsif (ir( 5 downto 3) = "010") then
                            NAF <= "010100";
                        elsif (ir( 5 downto 3) = "011") then
                            NAF <= "010110";
                        else
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
                        -- add hlt = 1 here
                    when "1110" =>                -- specials
                        if(ir(11 downto 12) = "01" ) then
                            NAF <= "100100";
                        elsif (ir(11 downto 12) = "10" ) then
                            NAF <= "011101";
                        else
                            NAF <= "100100";
                        end if;
                    when others =>               -- 2 operands
                        if (ir( 11 downto 9) = "000") then
                            NAF <= "000011";
                        elsif (ir( 11 downto 9) = "001") then
                            NAF <= "000101";
                        elsif (ir( 11 downto 9) = "010") then
                            NAF <= "000111";
                        elsif (ir( 11 downto 9) = "011") then
                            NAF <= "001001";
                        else
                            NAF <= "000100";
                        end if;
                end case;

            -- check if ORdest  ( Bit ORing )
            elsif out1(2) = '0' and out1(1) = '0' and out1(0) = '1' then
                case( ir (4 downto 3) ) is
                    when "00" =>
                        if IR(5)= '0'  then
                            NAF <= "010000";
                        end if;
                    when "01" =>
                        NAF <= "010010";
                    when "10" =>
                        NAF <= "010100";
                    when "11" =>
                        NAF <= "010110";
                    when OTHERS =>
                        NAF <= "000000";
                end case ;

            -- check if ORdest indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '0' and ir(5) = '0' then                                           -- indirect reg
                NAF <= "010001";

            -- check if OR src indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '1'  and ir(11) = '1'  then
                NAF <= "000100";

            -- Check if OR result ( Bit ORing of branching)
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '0' then
                case( ir (11 downto 10) ) is
                    when "00" =>

                        if IR(15 downto 12) = "0000"  then                          -- BR
                            NAF <= out1(15 downto 10);
                        elsif IR(15 downto 12) = "1100" then                        -- BLS
                            if flag_regs(0) = '0' or flag_regs(1) = '1' then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "01" =>

                        if IR(15 downto 12) = "0000"  then                           --BEQ
                            if flag_regs(1) = '1' then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                          --BHI
                            if flag_regs(0) = '1' then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "10" =>

                        if IR(15 downto 12) = "0000"  then                            --BNE
                            if flag_regs(1) = '0' then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                         -- BHS
                            if flag_regs(0) = '1' or flag_regs(1) = '1'  then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;
                        end if;

                    when "11" =>

                        if IR(15 downto 12) = "0000"  then                            --BLO
                            if flag_regs(0) = '0' then
                                NAF <= out1(15 downto 10);
                            else
                                NAF <= "000000";
                            end if;

                        end if;

                    when OTHERS =>
                        NAF <= "000000";
                end case ;

            -- check if OR op (Bit Oring operations )
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '1' then

                case( ir (15 downto 12) ) is
                    when "0001" =>                         --MOV case
                        if IR(5)= '0'  then
                            NAF <= "101111";
                        else
                            NAF <= "101110";
                        end if;
                    when "1101" =>                         -- JSR
                        NAF <= "000000";
                    when "1110" =>
                        if ir(11 downto 10) = "01" then    --RTS
                            NAF <= "000000";
                        else                               -- INTERRUPT or IRET
                            NAF <= out1(15 downto 10);
                        end if;
                    when OTHERS =>                        -- general case
                        NAF <= "110000";
                end case ;

            end if;

        end if;
    end process;
    out_inst <= CONTROL_STORE(to_integer(unsigned(address)));
end architecture;