library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

--temp0 and B are the two operands for the alu
--mode is the operation
--en: enable
--flagIn: input the flag register
--F is the output of the two operations
--flagOut: the output condition of the flags
entity alu is
    generic (n : integer := 16);

    port (
        temp0 , B : in std_logic_vector(n-1 downto 0);
        mode : in std_logic_vector(3 downto 0);
        clk,en : in std_logic;
        flagIn:  in std_logic_vector(4 downto 0);
        F : out std_logic_vector(15 downto 0);
        flagOut : out std_logic_vector(4 downto 0)
    );
end entity;

architecture archALU of alu is
    signal secInput_Signal: std_logic_vector(n-1 downto 0);
    signal ALUOUT_SIGNAL: std_logic_vector(n-1 downto 0);
    signal carryIn: std_logic;
    signal carryOut: std_logic;
    signal temp0Bar: std_logic_vector(n-1 downto 0);
    signal unusedSignal: std_logic;
begin
    adder1: entity work.nadder port map(B, secInput_Signal, carryIn, ALUOUT_SIGNAL, carryOut);
    adder2: entity work.nadder port map(temp0,"0000000000000000", flagIn(0), temp0Bar, unusedSignal);

    process (temp0, B, mode, en, flagIn, clk)
        variable ALUOUT: std_logic_vector(n-1 DOWNTO 0);
        variable secInput: std_logic_vector(n-1 DOWNTO 0);
    begin
        if (en='1' and rising_edge(clk)) then
            case mode is
                when "0000" =>
                    --ADD
                    --Won't check on the carry's state as it gets added any ways
                    secInput := temp0;
                    secInput_Signal <= temp0;
                    carryIn <= flagIn(0);
                    flagOut(0)<=carryOut;
                    ALUOUT := ALUOUT_SIGNAL;
                    --P + P = N
                    if (B(n-1) = '0' and secInput(n-1) = '0' and ALUOUT(n-1) = '1') then
                        flagOut(4) <= '1';
                    --N+N = P
                    ELSIF (B(n-1) = '1' and secInput(n-1) = '1' and ALUOUT(n-1) = '0') then 
                        flagOut(4) <= '1';
                    else
                        flagOut(4) <= '0';
                    end if;
                when "0001" =>
                    --SUB
                    --NOTE: A - B == A + (B)` + 1 
                    --NOTE: A - B - C == A - (B+C) == A + (B+C)` + 1
                    --SO, temp0Bar = (B+C), whether C = 0 or 1
                    secInput := not temp0Bar;
                    secInput_Signal <= not temp0Bar;
                    carryIn <= '1';
                    flagOut(0)<=carryOut;
                    ALUOUT := ALUOUT_SIGNAL;
                    --P - N = N
                    if (B(n-1) = '0' and secInput(n-1) = '1' and ALUOUT(n-1) = '1') then
                        flagOut(4) <= '1';
                    --N-P = P
                    ELSIF (B(n-1) = '1' and secInput(n-1) = '0' and ALUOUT(n-1) = '0') then 
                        flagOut(4) <= '1';
                    else
                        flagOut(4) <= '0';
                    end if;
                when "0010" =>
                    --AND
                    ALUOUT := temp0 and B;
                    flagOut(0) <= flagIn(0);
                    flagOut(4) <= '0';
                when "0011" =>
                    --OR
                    ALUOUT := temp0 or B;
                    flagOut(0) <= flagIn(0);
                    flagOut(4) <= '0';
                when "0100" =>
                    --NOT
                    ALUOUT := not B;
                    flagOut(0) <= flagIn(0);
                    flagOut(4) <= '0';
                when "0101" =>
                    --XNOR
                    ALUOUT := temp0 XNOR B;
                    flagOut(0) <= flagIn(0);
                    flagOut(4) <= '0';
                when "0110" =>
                    --LSR: Logical shift Right
                    ALUOUT := '0' & B(n-1 downto 1);
                    flagOut(0) <= B(0);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "0111" =>
                    --ROR
                    ALUOUT := B(0) & B(n-1 downto 1);
                    flagOut(0) <= B(0);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1000" =>
                    --RRC
                    ALUOUT := flagIn(0) & B(n-1 downto 1);
                    flagOut(0) <= B(0);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1001" =>
                    --ASR: Arithmetic shift right
                    ALUOUT := B(n-1) & B(n-1 downto 1);
                    flagOut(0) <= B(0);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1010" =>
                    --LSL: Logical Shift Left
                    ALUOUT :=  B(n-2 downto 0) & '0'; 
                    flagOut(0) <= B(n-1);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1011" =>
                    --ROL
                    ALUOUT :=  B(n-2 downto 0) & B(n-1);
                    flagOut(0) <= B(n-1);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1100" =>
                    --RLC
                    ALUOUT :=  B(n-2 downto 0) & flagIn(0);
                    flagOut(0) <= B(n-1);
                    flagOut(4) <= flagIn(0) XOR flagIn(2);
                when "1101" =>
                    --DEC
                    --F = B - 1 == (B + 1), not 001 but 111
                    secInput := "1111111111111111";
                    carryIn <= '0';
                    ALUOUT := ALUOUT_SIGNAL;
                    flagOut(0)<=carryOut;
                    if (B="1000000000000000") then
                        flagOut(4) <= '1';
                    else
                        flagOut(4) <= '0';
                    end if;
                when "1110" =>
                    --INC
                    --F = B + 1 == B + 0 and carry = 1
                    secInput := "0000000000000000";
                    carryIn <= '1';
                    ALUOUT := ALUOUT_SIGNAL;
                    flagOut(0)<=carryOut;
                    if (B="0111111111111111") then
                        flagOut(4) <= '1';
                    else
                        flagOut(4) <= '0';
                    end if;
                when OTHERS =>
                    --CLR
                    ALUOUT := "0000000000000000";
                    flagOut(0) <= '0'; --Carry
                    flagOut(2) <= '0'; --Negative
                    flagOut(4) <= '0'; --Overflow
            end case;

            --Check on the zero flag
            F <= ALUOUT;

            if (ALUOUT="0000000000000000") then
                flagOut(1) <= '1';
            else
                flagOut(1) <= '0';
            end if;

            --Check on Negative flag
            if (ALUOUT(n-1)='1') then
                flagOut(2) <= '1';
            else
                flagOut(2) <= '0';
            end if;

            --Parity Flag
            flagOut(3) <= ALUOUT(0) xor (ALUOUT(1) xor (ALUOUT(2) xor (ALUOUT(3) xor (ALUOUT(4) xor (ALUOUT(5) xor (ALUOUT(6) xor (ALUOUT(7) xor (ALUOUT(8) xor (ALUOUT(9) xor (ALUOUT(10) xor (ALUOUT(11) xor (ALUOUT(12) xor (ALUOUT(13) xor ( ALUOUT(14)  xor ALUOUT(15) ) )   ))))))))))) );
        else
            F <= "ZZZZZZZZZZZZZZZZ";
            flagOut <= "ZZZZZ";
        end if;
    end process;
end architecture;
