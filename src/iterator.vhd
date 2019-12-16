library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY iterator IS
	GENERIC (
		PATH      : string := "rom.txt";  -- path to rom file relative to project dir
		WORD_WIDTH: natural := 26;        -- number of bits in word
		ROM_SIZE  : natural := 64         -- ROM size
	);
	PORT (
        clk      : IN std_logic;
        ir       : IN std_logic_vector(15 DOWNTO 0);             -- IR register data
        flag_regs: IN std_logic_vector(4 DOWNTO 0);
        address  : IN std_logic_vector(5 DOWNTO 0);              -- address to be fetched from control store
        out_inst : OUT std_logic_vector(WORD_WIDTH-1 downto 0);  -- output micro instruction
        NAF      : OUT std_logic_vector(5 DOWNTO 0)              --next address field
    );

END ENTITY iterator;

ARCHITECTURE arch_iterator OF iterator IS

-- definition of ROM component for control store handling
COMPONENT rom IS
    generic (
        PATH: string;
        WORD_WIDTH: natural;
        ROM_SIZE: natural
    );
    port (
        clk, rd, reset: in std_logic;
        address: in std_logic_vector(5 downto 0);
        data_out: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
END COMPONENT;

-- definition of starter component for starting address navigation
COMPONENT STARTER IS
    GENERIC (n: integer);
    PORT(
        IR: IN std_logic_vector(n-1 DOWNTO 0);
        MeuAR_ADD : OUT std_logic_vector(5 DOWNTO 0);
        starter_clk : IN std_logic
    );
END COMPONENT;


-- useful signals

SIGNAL out1: std_logic_vector(WORD_WIDTH-1 DOWNTO 0);
SIGNAL StarterOut: std_logic_vector(5 DOWNTO 0);


BEGIN

U1: rom GENERIC MAP (PATH, WORD_WIDTH, ROM_SIZE) PORT MAP (clk, '1', '0', address, out1);
U2: STARTER GENERIC MAP (16) PORT MAP (IR, StarterOut , clk);

process (ir, address)
begin
    -- check PLAout = 0 return NAF
    if out1(3) = '0'  then
        out_inst <= out1;
        NAF <= out1(25 DOWNTO 20);
    else
    -- check PLAout = 1
    -- check  group 9 = "000" return the starter output in NAF
        if out1(2) = '0' and out1(1) = '0' and out1(0) = '0' then
            out_inst <= out1;
            NAF <= StarterOut;

        -- check if ORdest  ( Bit ORing )
        elsif out1(2) = '0' and out1(1) = '0' and out1(0) = '1' then
            case( ir (4 DOWNTO 3) ) is
                when "00" =>
                    IF IR(5)= '0'  THEN
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
                WHEN OTHERS =>
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
            case( ir (11 DOWNTO 10) ) is
                when "00" =>

                    IF IR(15 DOWNTO 12) = "0000"  THEN                          -- BR
                        out_inst <= out1;
                        NAF <= out1(15 DOWNTO 10);
                    elsif IR(15 DOWNTO 12) = "1100" THEN                        -- BLS
                        if flag_regs(0) = '0' or flag_regs(1) = '1' THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;
                    end if;

                when "01" =>

                    IF IR(15 DOWNTO 12) = "0000"  THEN                           --BEQ
                        IF flag_regs(1) = '1' THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;
                    elsif IR(15 DOWNTO 12) = "1100" THEN                          --BHI
                        if flag_regs(0) = '1' THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;
                    end if;

                when "10" =>

                    IF IR(15 DOWNTO 12) = "0000"  THEN                            --BNE
                        IF flag_regs(1) = '0' THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;
                    elsif IR(15 DOWNTO 12) = "1100" THEN                         -- BHS
                        if flag_regs(0) = '1' or flag_regs(1) = '1'  THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;
                    end if;

                when "11" =>

                    IF IR(15 DOWNTO 12) = "0000"  THEN                            --BLO
                        IF flag_regs(0) = '0' THEN
                            out_inst <= out1;
                            NAF <= out1(15 DOWNTO 10);
                        else
                            out_inst <= out1;
                            NAF <= "000000";
                        end if;

                    end if;

                WHEN OTHERS =>
                    out_inst <= out1;
                    NAF <= "000000";
            end case ;

        -- check if OR op (Bit Oring operations )
        elsif out1(2) = '1' and out1(1) = '0' and out1(0) = '1' then

            case( ir (15 DOWNTO 12) ) is
                when "0001" =>                         --MOV case
                    IF IR(5)= '0'  THEN
                        out_inst <= out1;
                        NAF <= "101110";
                    end if;
                when "1101" =>                         -- JSR
                    out_inst <= out1;
                    NAF <= "000000";
                when "1110" =>
                    if ir(11 DOWNTO 10) = "01" THEN    --RTS
                        out_inst <= out1;
                        NAF <= "000000";
                    else                               -- INTERRUPT or IRET
                        out_inst <= out1;
                        NAF <= out1(15 DOWNTO 10);
                    end if;
                WHEN OTHERS =>                        -- general case
                    out_inst <= out1;
                    NAF <= "110000";
            end case ;

        end if;

    end if;

end process;

END ARCHITECTURE;