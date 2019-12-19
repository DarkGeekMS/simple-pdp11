library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iterator is
	generic (
		PATH      : string := "rom.txt";  -- path to rom file relative to project dir
		WORD_WIDTH: natural := 26;        -- number of bits in word
		ROM_SIZE  : natural := 64         -- ROM size
    );
    
	port (
        clk      : in std_logic;
        ir       : in std_logic_vector(15 downto 0);             -- IR register data
        flag_regs: in std_logic_vector(4 downto 0);
        address  : in std_logic_vector(5 downto 0);              -- address to be fetched from control store
        out_inst : out std_logic_vector(WORD_WIDTH-1 downto 0);  -- output micro instruction
        NAF      : out std_logic_vector(5 downto 0)              --next address field
    );
end entity;

architecture arch_iterator OF iterator is
    signal out1: std_logic_vector(WORD_WIDTH-1 downto 0);
    signal StarterOut: std_logic_vector(5 downto 0);
begin
    U1: entity work.rom generic map (PATH, WORD_WIDTH, ROM_SIZE) port map (clk, '1', '0', address, out1);
    U2: entity work.starter generic map (16) port map (IR, StarterOut , clk);

    process (ir, address)
    begin
        -- check PLAout = 0 return NAF
        if out1(3) = '0'  then
            out_inst <= out1;
            NAF <= out1(25 downto 20);
        else
        -- check PLAout = 1
        -- check  group 9 = "000" return the starter output in NAF
            if out1(2) = '0' and out1(1) = '0' and out1(0) = '0' then
                out_inst <= out1;
                NAF <= StarterOut;

            -- check if ORdest  ( Bit ORing )
            elsif out1(2) = '0' and out1(1) = '0' and out1(0) = '1' then
                case( ir (4 downto 3) ) is
                    when "00" =>
                        if IR(5)= '0'  then
                            out_inst <= out1;
                            NAF <= "010000";
                        end if;
                    when "01" =>
                        out_inst <= out1;
                        NAF <= "010010";
                    when "10" =>
                        out_inst <= out1;
                        NAF <= "010100";
                    when "11" =>
                        out_inst <= out1;
                        NAF <= "010110";
                    when OTHERS =>
                        out_inst <= out1;
                        NAF <= "000000";
                end case ;

            -- check if ORdest indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '0' and ir(5) = '0' then                                           -- indirect reg
                out_inst <= out1;
                NAF <= "010001";

            -- check if OR src indirect ( Bit ORing )

            elsif out1(2) = '0' and out1(1) = '1' and out1(0) = '1'  and ir(11) = '1'  then
                out_inst <= out1;
                NAF <= "000100";

            -- Check if OR result ( Bit ORing of branching)
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '0' then
                case( ir (11 downto 10) ) is
                    when "00" =>

                        if IR(15 downto 12) = "0000"  then                          -- BR
                            out_inst <= out1;
                            NAF <= out1(15 downto 10);
                        elsif IR(15 downto 12) = "1100" then                        -- BLS
                            if flag_regs(0) = '0' or flag_regs(1) = '1' then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;
                        end if;

                    when "01" =>

                        if IR(15 downto 12) = "0000"  then                           --BEQ
                            if flag_regs(1) = '1' then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                          --BHI
                            if flag_regs(0) = '1' then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;
                        end if;

                    when "10" =>

                        if IR(15 downto 12) = "0000"  then                            --BNE
                            if flag_regs(1) = '0' then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;
                        elsif IR(15 downto 12) = "1100" then                         -- BHS
                            if flag_regs(0) = '1' or flag_regs(1) = '1'  then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;
                        end if;

                    when "11" =>

                        if IR(15 downto 12) = "0000"  then                            --BLO
                            if flag_regs(0) = '0' then
                                out_inst <= out1;
                                NAF <= out1(15 downto 10);
                            else
                                out_inst <= out1;
                                NAF <= "000000";
                            end if;

                        end if;

                    when OTHERS =>
                        out_inst <= out1;
                        NAF <= "000000";
                end case ;

            -- check if OR op (Bit Oring operations )
            elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '1' then

                case( ir (15 downto 12) ) is
                    when "0001" =>                         --MOV case
                        if IR(5)= '0'  then
                            out_inst <= out1;
                            NAF <= "101110";
                        end if;
                    when "1101" =>                         -- JSR
                        out_inst <= out1;
                        NAF <= "000000";
                    when "1110" =>
                        if ir(11 downto 10) = "01" then    --RTS
                            out_inst <= out1;
                            NAF <= "000000";
                        else                               -- INTERRUPT or IRET
                            out_inst <= out1;
                            NAF <= out1(15 downto 10);
                        end if;
                    when OTHERS =>                        -- general case
                        out_inst <= out1;
                        NAF <= "110000";
                end case ;

            end if;

        end if;
    end process;
end architecture;