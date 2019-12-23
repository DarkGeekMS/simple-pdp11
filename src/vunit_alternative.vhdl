library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vunit_alternative is
    procedure info(s: string);
    procedure check(v: boolean; msg: string := ""; s: severity_level := error);
end package; 

package body vunit_alternative is
    procedure info(s: string) is
    begin
        report "info: " & s;
    end procedure;

    procedure check(v: boolean; msg: string := ""; s: severity_level := error) is
    begin
        assert v report msg;
    end procedure;
end package body;
