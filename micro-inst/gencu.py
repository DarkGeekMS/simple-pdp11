import sys
import json

path = sys.argv[1]
instr = {}

with open(path) as f:
    instr = json.load(f)


def fix_sig(sig):
    sig = sig.replace('.', '_')
    sig = sig.replace('=', '_eq_')
    sig = sig.replace('(', '_')
    sig = sig.replace(')', '_')
    sig = sig.replace('+', '_plus_')
    sig = sig.replace('-', '_minus_')
    sig = sig.replace('|', '_or_')
    sig = sig.replace('~', '_not_')
    sig = sig.replace('&', '_not_')
    sig = sig.replace('__', '_')
    sig = sig.lower()

    return sig


def fix_inst(inst: str):
    inst = inst.lower()
    inst = inst.replace(' ', '_')
    inst = inst.replace('(', '_')
    inst = inst.replace(')', '_')
    inst = inst.replace('(', '_')
    inst = inst.replace('@', '_at_')
    inst = inst.replace('+', '_plus_')
    inst = inst.replace('-', '_minus_')

    inst = inst.replace('__', '_')
    inst = inst.replace('__', '_')
    inst = inst.strip('_')

    return inst


sigs = [fix_sig(sig) for sig in instr['signals']]


def out_ones(line: str):
    res = []
    for x in line.split(', '):
        if x == 'IF NOT (Z=1) THEN END':
            res.append("if not (zero_flag = '1') then end_flag <= 1; end if;")
        elif x == 'IF NOT (Z=0) THEN END':
            res.append("if not (zero_flag = '0') then end_flag <= 1; end if;")
        elif x == 'IF NOT (C=0) THEN END':
            res.append("if not (carry_flag = '0') then end_flag <= 1; end if;")
        elif x == 'IF NOT (C=1) THEN END':
            res.append("if not (carry_flag = '1') then end_flag <= 1; end if;")
        elif x == 'IF NOT (C=0 or Z=1) THEN END':
            res.append(
                "if not (carry_flag = '0' or zero_flag = '1') then end_flag <= 1; end if;")
        elif x == 'IF NOT (C=1 or Z=1) THEN END':
            res.append(
                "if not (carry_flag = '1' or zero_flag = '1') then end_flag <= 1; end if;")
        elif x in instr['signals']:
            res.append(f"{fix_sig(x)} <= '1';")

    return ' '.join(res)


def get_function(inst_name: str, fixed_inst_name: str, inst_lines: [str]):
    sp = ' '*4
    func = f'{sp*2}-- {inst_name}'
    func += f'\n{sp*2}procedure {fixed_inst_name} is'
    func += f'\n{sp*2}begin'

    if inst_name == 'HLT':
        func += f"\n{sp*3}hlt_flag <= 1;"
    else:
        func += f'\n{sp*3}case timer is'

        for i, line in enumerate(inst_lines[:-1]):
            func += f'\n{sp*4}when {i} => {out_ones(line)}'
        func += f'\n{sp*4}when others => end_flag <= 1;'

        func += f'\n{sp*3}end case;'

    return func + f'\n{sp*2}end procedure;'


functions = '\n\n'.join([get_function(inst_name, fix_inst(inst_name), inst_lines)
                         for (inst_name, inst_lines) in instr['instructions'].items()])


opcodes = {
    'MOV': '0001',
    'ADD': '0010',
    'ADC': '0011',
    'SUB': '0100',
    'SUBC': '0101',
    'AND': '0110',
    'OR': '0111',
    'XNOR': '1000',
    'CMP': '1001',
    'INC': '11110000',
    'DEC': '11110001',
    'CLR': '11110010',
    'INV': '11110011',
    'LSR': '11110100',
    'ROR': '11110101',
    'RRC': '11110110',
    'ASR': '11110111',
    'LSL': '11111000',
    'ROL': '11111001',
    'RLC': '11111010',
    'BR': '000000',
    'BEQ': '000001',
    'BNE': '000010',
    'BLO': '000011',
    'BLS': '110000',
    'BHI': '110001',
    'BHS': '110011',
    'HLT': '1010',
    'NOP': '1011',
    'JSR': '110100',
    'RTS': '111001',
    'INT': '111010',
    'IRET': '111011',
}


# TODO: fill with actual data
modes = {
    'R': '000',
    '(R)+': '001',
    '-(R)': '010',
    'X(R)': '011',
    '@R': '100',
    '@(R)+': '101',
    '@-(R)': '110',
    '@X(R)': '111',
}


def get_conditions(instr_parts):
    code = opcodes[instr_parts[0]]

    if len(code) == 4:
        return f'ir_data(15 downto {16-len(code)}) = "{code}" and ir_data(11 downto 9) = "{modes[instr_parts[1]]}" and ir_data(5 downto 3) = "{modes[instr_parts[2]]}"'
    else:
        return f'ir_data(15 downto {16-len(code)}) = "{code}" and ir_data(11 downto 9) = "{modes[instr_parts[1]]}"'


def get_instr_case(instr_name, fixed_name):
    instr_name = instr_name.split()
    sp = ' '*4*3
    return f'{sp}if {get_conditions(instr_name)} then {fixed_name}; end if;'


instr_cases = '\n'.join([get_instr_case(inst_name, fix_inst(inst_name))
                         for (inst_name, _) in instr['instructions'].items()])

out = f'''-- Auto generated file, any edits will be lost --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit_hardwired is
    port (
        clk: in std_logic;
        ir_data, flags_data: in std_logic_vector(15 downto 0);

        {', '.join(sigs)}: out std_logic
    );
end entity; 


architecture rtl of control_unit_hardwired is
    -- if set, do no operation
    signal hlt_flag: integer := 0;
    signal end_flag: integer := 0;

    -- from 0 -> n-1, where n is the number of lines for the microprogram
    signal timer: integer := 0;

    -- increment number of clk ticks, when it reachs MAX_CLK_TICKS increment timer and reset clk_ticks
    constant MAX_CLK_TICKS: integer := 4;
    signal clk_ticks: integer := 0;

    -- TODO: fix these assumptions according to the scheme
    alias carry_flag: std_logic is flags_data(0);
    alias zero_flag: std_logic is flags_data(1);
    alias neg_flag: std_logic is flags_data(2);
    alias par_flag: std_logic is flags_data(3);
    alias overfl_flag: std_logic is flags_data(4);
begin

    process (clk)
        procedure zero_all_out is
        begin
            {' '.join([x for x in map(lambda x: f"{x} <= '0';", sigs)])}
        end procedure;

{functions}

        procedure execute_instr is
        begin
{instr_cases}
        end procedure;
    begin
        if hlt_flag = 0 and rising_edge(clk) then
            clk_ticks <= clk_ticks + 1;

            if clk_ticks = MAX_CLK_TICKS then
                clk_ticks <= 0;

                zero_all_out;
                execute_instr;
            end if;

            if end_flag = 1 then
                end_flag <= 0;
                timer <= 0;
                zero_all_out;
            end if;
        end if;
    end process;
end architecture;'''

with open(sys.argv[2] + 'control_unit_hardwired.vhdl', 'w') as f:
    print(out, file=f)
