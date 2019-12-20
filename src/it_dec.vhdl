library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity it_dec is
    port (
        clk : in std_logic;
        IR: in std_logic_vector(15 downto 0);
        FLAGS: in std_logic_vector(4 downto 0);
        address: in std_logic_vector(5 downto 0);
        controlSignal : out std_logic_vector(37 downto 0);
        NAF: out std_logic_vector(5 downto 0)
    );
end entity;

architecture it_dec_arch of it_dec is
    signal cw: std_logic_vector(25 downto 0);
begin
	it: entity work.iterator port map(clk, IR, FLAGS, address, cw, NAF);
    dec: entity work.decoder port map(clk, IR, cw, controlSignal);	
end architecture;