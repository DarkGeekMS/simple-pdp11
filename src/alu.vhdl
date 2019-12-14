library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

--entity alu is
--    generic (WORD_WIDTH: integer := 16);

--    port (
--        r, l: in std_logic_vector(WORD_WIDTH-1 downto 0);  
--        sel: in std_logic_vector(3 downto 0);
--        cin : in std_logic;

--        f: out std_logic_vector(WORD_WIDTH-1 downto 0);
--        cout: out std_logic
--    );
--end entity;

--architecture rtl of alu is
--begin
--    f <= (others => '0');
--    cout <= cin;
--end architecture;


ENTITY ALU is
GENERIC (n : integer := 16);
--temp0 and B are the two operands for the ALU
--mode is the operation
--en: enable
--flagIn: input the flag register
--F is the output of the two operations
--flagOut: the output condition of the flags

port(
    temp0 , B : in std_logic_vector(n-1 downto 0);
    mode : in std_logic_vector(3 downto 0);
    en : in std_logic;
    flagIn:  in std_logic_vector(4 downto 0);
    F : out std_logic_vector(15 downto 0);
    flagOut : out std_logic_vector(4 downto 0)
);
end entity ALU;

architecture archALU of ALU is


--Added components
COMPONENT nadder IS
GENERIC (n : integer := 16);
PORT(A, B : IN std_logic_vector(n-1 DOWNTO 0);
     Cin : IN std_logic;
     SUM : OUT std_logic_vector(n-1 DOWNTO 0);
     Cout : OUT std_logic);
END COMPONENT;

--Added Signals
SIGNAL secInput: std_logic_vector(n-1 DOWNTO 0);
SIGNAL outputAdder: std_logic_vector(n-1 DOWNTO 0);
SIGNAL ALUOUT: std_logic_vector(n-1 DOWNTO 0);
SIGNAL carryIn: std_logic;
SIGNAL carryOut: std_logic;
SIGNAL temp0Bar: std_logic_vector(n-1 DOWNTO 0);
SIGNAL unusedSignal: std_logic;

BEGIN
adder1: nadder PORT MAP(B, secInput, carryIn, ALUOUT, carryOut);
adder2: nadder PORT MAP(temp0,"0000000000000000", flagIn(0), temp0Bar, unusedSignal);

PROCESS(temp0, B, mode, en, flagIn)
    BEGIN
    IF (en='0') THEN
        F <= "ZZZZZZZZZZZZZZZZ";
        flagOut <= "ZZZZZ";
    ELSE
        CASE mode IS
            WHEN "0000" =>
                --ADD
                --Won't check on the carry's state as it gets added any ways
                secInput <= temp0;
                carryIn <= flagIn(0);
                flagOut(0)<=carryOut;
                --P + P = N
                IF (B(n-1) = '0' and secInput(n-1) = '0' and outputAdder(n-1) = '1') THEN
                    flagOut(4) <= '1';
                --N+N = P
                ELSIF (B(n-1) = '1' and secInput(n-1) = '1' and outputAdder(n-1) = '0') THEN 
                    flagOut(4) <= '1';
                ELSE
                    flagOut(4) <= '0';
                END IF;
            WHEN "0001" =>
                --SUB
                --NOTE: A - B == A + (B)` + 1 
                --NOTE: A - B - C == A - (B+C) == A + (B+C)` + 1
                --SO, temp0Bar = (B+C), whether C = 0 or 1
                secInput <= not temp0Bar;
                carryIn <= '1';
                flagOut(0)<=carryOut;
                --P - N = N
                IF (B(n-1) = '0' and secInput(n-1) = '1' and outputAdder(n-1) = '1') THEN
                    flagOut(4) <= '1';
                --N-P = P
                ELSIF (B(n-1) = '1' and secInput(n-1) = '0' and outputAdder(n-1) = '0') THEN 
                    flagOut(4) <= '1';
                ELSE
                    flagOut(4) <= '0';
                END IF;
            WHEN "0010" =>
                --AND
                ALUOUT <= temp0 and B;
                flagOut(0) <= flagIn(0);
                flagOut(4) <= '0';
            WHEN "0011" =>
                --OR
                ALUOUT <= temp0 or B;
                flagOut(0) <= flagIn(0);
                flagOut(4) <= '0';
            WHEN "0100" =>
                --NOT
                ALUOUT <= not B;
                flagOut(0) <= flagIn(0);
                flagOut(4) <= '0';
            WHEN "0101" =>
                --XNOR
                ALUOUT <= temp0 XNOR B;
                flagOut(0) <= flagIn(0);
                flagOut(4) <= '0';
            WHEN "0110" =>
                --LSR: Logical shift Right
                ALUOUT <= '0' & B(n-1 downto 1);
                flagOut(0) <= B(0);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "0111" =>
                --ROR
                ALUOUT <= B(0) & B(n-1 downto 1);
                flagOut(0) <= B(0);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1000" =>
                --RRC
                ALUOUT <= flagIn(0) & B(n-1 downto 1);
                flagOut(0) <= B(0);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1001" =>
                --ASR: Arithmetic shift right
                ALUOUT <= B(n-1) & B(n-1 downto 1);
                flagOut(0) <= B(0);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1010" =>
                --LSL: Logical Shift Left
                ALUOUT <=  B(n-2 downto 0) & '0'; 
                flagOut(0) <= B(n-1);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1011" =>
                --ROL
                ALUOUT <=  B(n-2 downto 0) & B(n-1);
                flagOut(0) <= B(n-1);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1100" =>
                --RLC
                ALUOUT <=  B(n-2 downto 0) & flagIn(0);
                flagOut(0) <= B(n-1);
                flagOut(4) <= flagIn(0) XOR flagIn(2);
            WHEN "1101" =>
                --DEC
                --F = B - 1 == (B + 1), not 001 but 111
                secInput <= "1111111111111111";
                carryIn <= '0';
                ALUOUT <= outputAdder;
                flagOut(0)<=carryOut;
                IF (B="1000000000000000") THEN
                    flagOut(4) <= '1';
                ELSE
                    flagOut(4) <= '0';
                END IF;
            WHEN "1110" =>
                --INC
                --F = B + 1 == B + 0 and carry = 1
                secInput <= "0000000000000000";
                carryIn <= '1';
                ALUOUT <= outputAdder;
                flagOut(0)<=carryOut;
                IF (B="0111111111111111") THEN
                    flagOut(4) <= '1';
                ELSE
                    flagOut(4) <= '0';
                END IF;
            WHEN OTHERS =>
                --CLR
                ALUOUT <= "0000000000000000";
                flagOut(0) <= '0'; --Carry
                flagOut(2) <= '0'; --Negative
                flagOut(4) <= '0'; --Overflow
         END CASE;
         --Check on the zero flag
        F <= ALUOUT;
        IF (ALUOUT="0000000000000000") THEN
            flagOut(1) <= '1';
        ELSE
            flagOut(1) <= '0';
        END IF;
        --Check on Negative flag
        IF (ALUOUT(n-1)='0') THEN
            flagOut(2) <= '1';
        ELSE
            flagOut(2) <= '0';
        END IF;
        --Parity Flag
        flagOut(3) <= ALUOUT(0) xor (ALUOUT(1) xor (ALUOUT(2) xor (ALUOUT(3) xor (ALUOUT(4) xor (ALUOUT(5) xor (ALUOUT(6) xor (ALUOUT(7) xor (ALUOUT(8) xor (ALUOUT(9) xor (ALUOUT(10) xor (ALUOUT(11) xor (ALUOUT(12) xor (ALUOUT(13) xor ( ALUOUT(14)  xor ALUOUT(15) ) )   ))))))))))) );
    END IF;
    END PROCESS;

END archALU;
