def fetch_value_TMP(mode: str, tmp: str, r_name: str):
    if mode == 'R':
        return f'R({r_name})'

    elif mode == '(R)+':
        wr(f'R({r_name}).out, {tmp}.in, ALU.r+1')
        wr(f'ALU.out, R({r_name}).in')

        return tmp

    elif mode == '-(R)':
        wr(f'R({r_name}).out, ALU.r-1')
        wr(f'ALU.out, R({r_name}).in')

        return f'R({r_name})'

    elif mode == 'X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R({r_name})
        wr(f'MDR.out, TMP0.in')
        # mdr = [tmp]
        wr(f'R({r_name}).out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in, RD')

        # temp = mdr TODO: maybe not optimal?
        wr(f'MDR.out, {tmp}.in')

        return tmp

    elif mode == '@R':
        wr(f'R({r_name}).out, MAR.in, RD')
        wr(f'MDR.out, {tmp}.in')

        return tmp

    elif mode == '@(R)+':
        wr(f'R({r_name}).out, MAR.in, RD')
        wr(f'MAR.out, ALU.r+1')
        wr(f'ALU.out, R({r_name}).in')
        wr(f'MDR.out, {tmp}.in')

        return tmp

    elif mode == '@-(R)':
        wr(f'R({r_name}).out, ALU.r-1')
        wr(f'ALU.out, R({r_name}).in, MAR.in, RD')
        wr(f'MDR.out, {tmp}.in')

        return tmp

    elif mode == '@X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R({r_name})
        wr(f'MDR.out, TMP0.in')
        # get tmp
        wr(f'R({r_name}).out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in, RD')

        # get tmp
        wr(f'MDR.out, MAR.in, RD')

        wr(f'MDR.out, {tmp}.in')

        return tmp


def fetch_addr(mode: str, tmp: str, r_name: str):
    if mode == '@R':
        wr(f'R({r_name}).out, MAR.in')

    elif mode == 'X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R({r_name})
        wr(f'MDR.out, TMP0.in')
        # mdr = [tmp]
        wr(f'R({r_name}).out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in')

    elif mode == '@(R)+':
        wr(f'R({r_name}).out, MAR.in')
        wr(f'MAR.out, ALU.r+1')
        wr(f'ALU.out, R({r_name}).in')

    elif mode == '@-(R)':
        wr(f'R({r_name}).out, ALU.r-1')
        wr(f'ALU.out, R({r_name}).in, MAR.in')

    elif mode == '@X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R({r_name})
        wr(f'MDR.out, TMP0.in')
        # get tmp
        wr(f'R({r_name}).out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in, RD')

        wr(f'MDR.out, MAR.in')


def _write_R(mode: str, need_addr=False):
    if need_addr:
        fetch_addr(mode, 'TMP0', 'dst')

    if mode in ('R', '-(R)', '(R)+'):
        wr(f'R(src).out, R(dst).in')
    else:
        wr(f'R(src).out, MDR.in, WR')


def _write_ALU(mode: str, need_addr=False):
    if mode in ('R', '-(R)', '(R)+'):
        wr(f'ALU.out, R(dst).in')
    else:
        if need_addr:
            wr(f'ALU.out, TMP1.in')
            fetch_addr(mode, 'TMP0', 'dst')
            wr(f'TMP1.out, MDR.in, WR')
        else:
            wr(f'ALU.out, MDR.in, WR')


def _write_TMP(mode: str, inp: str, need_addr=False):
    if mode in ('R', '-(R)', '(R)+'):
        wr(f'{inp}.out, R(dst).in')
    else:
        if need_addr:
            tmp = 'TMP0' if inp != 'TMP0' else 'TMP1'
            fetch_addr(mode, tmp, 'dst')

        wr(f'{inp}.out, MDR.in, WR')


def write(mode: str, inp: str, need_addr=False):
    if inp == 'R':
        _write_R(mode, need_addr)
    elif inp == 'ALU':
        _write_ALU(mode, need_addr)
    else:  # TMP#
        _write_TMP(mode, inp, need_addr)

#############################


def mov(src, dst):
    tmp1 = fetch_value_TMP(src, 'TMP1', 'src')
    write(dst, tmp1, True)


def add(src, dst, func='ALU.c=0, ALU.r+l+c'):
    tmp1 = fetch_value_TMP(src, 'TMP1', 'src')
    tmp0 = fetch_value_TMP(dst, 'TMP0', 'dst')

    if tmp1 == 'R' and tmp0 == 'R':
        wr(f'R(src).out, TMP0.in')
        wr(f'R(dst).out, {func}')
        wr(f'ALU.out, R(src).in')

    elif tmp1 == 'R':
        wr(f'R(src).out, {func}')
        write(dst, 'ALU')

    elif tmp0 == 'R':
        wr(f'TMP1.out, TMP0.in')
        wr(f'R(dst).out, {func}')
        write(dst, 'ALU')

    else:
        wr(f'{tmp1}.out, {func}')
        write(dst, 'ALU')


def adc(src, dst):
    return add(src, dst, 'ALU.r+l+c')


def sub(src, dst, func='ALU.c=0, ALU.r-l-c', do_write=True):
    tmp1 = fetch_value_TMP(src, 'TMP1', 'src')
    tmp0 = fetch_value_TMP(dst, 'TMP0' if tmp1 != 'R' else 'TMP1', 'dst')

    if tmp0 == 'R' and tmp1 == 'R':
        wr(f'R(src).out, TMP0.in')
        wr(f'R(dst).out, {func}')

    elif tmp0 == 'R':
        # TMP1 carries src, R(dst) carries dst
        wr(f'TMP1.out, TMP0.in')
        wr(f'R(dst).out, {func}')

    elif tmp1 == 'R':
        # R(src) carries src, TMP1 carries dst
        wr(f'R(src).out, TMP0.in')
        wr(f'TMP1.out, {func}')

    else:
        # TMP1 carries src, TMP0 carries dst
        wr(f'ALU.c=0, ALU.r+l+c')
        wr(f'TMP1.out, TMP0.in')
        wr(f'ALU.out, TMP1.in')

        # TMP0 carries src, TMP1 carries dst
        wr(f'TMP1.out, {func}')

    if do_write:
        write(dst, 'ALU')


def subc(src, dst):
    return sub(src, dst, 'ALU.r-l-c', True)


def andd(src, dst):
    return add(src, dst, 'ALU.r&l')


def orr(src, dst):
    return add(src, dst, 'ALU.r|l')


def xnor(src, dst):
    return add(src, dst, 'ALU.r(XNOR)l')


def cmpp(src, dst):
    return sub(src, dst, 'ALU.c=0, ALU.r-l-c', False)


def inc(dst, func='ALU.r+1'):
    tmp = fetch_value_TMP(dst, 'TMP1', 'src')

    if tmp == 'R':
        wr(f'R.out, {func}')
    else:
        wr(f'{tmp}.out, {func}')

    write(dst, 'ALU')


def dec(dst):
    return inc(dst, 'ALU.r-1')


def clr(dst):
    if dst in ('R', '-(R)', '(R)+'):
        wr(f'ALU.zero, R(dst).in')

    elif dst == 'X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # [x+R] = inp
        wr(f'MDR.out, TMP0.in')
        wr(f'R.out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in')

        wr(f'ALU.zero, MDR.in, WR')

    elif dst == '@R':
        wr(f'R(dst).out, MAR.in')

        wr(f'ALU.zero, MDR.in, WR')

    elif dst == '@(R)+':
        wr(f'R(dst).out, MAR.in')

        wr(f'ALU.zero, MDR.in, WR')

        wr(f'R.out, ALU.r+1')
        wr(f'ALU.out, R.in')

        wr(f'ALU.zero, MDR.in, WR')

    elif dst == '@-(R)':
        wr(f'R(dst).out, ALU.r-1')
        wr(f'ALU.out, MAR.in')
        wr(f'ALU.out, R.in')

        wr(f'ALU.zero, MDR.in, WR')

    elif dst == '@X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R
        wr(f'MDR.out, TMP0.in')
        wr(f'R.out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in')

        wr(f'ALU.zero, MDR.in, WR')


def inv(dst):
    return inc(dst, 'ALU.~r')


def lsr(dst, func='ALU.c=0, ALU.rrc'):
    if dst in ('R', '(R)+'):
        wr(f'R.out, {func}')
        wr(f'ALU.out, R.in')

    elif dst == '-(R)':
        wr(f'R.out, ALU.r-1')
        wr(f'{func}, ALU.out, R.in')

    elif dst == 'X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R
        wr(f'MDR.out, TMP0.in')
        # mdr = [tmp]
        wr(f'R.out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in, RD')

        wr(f'MDR.out, {func}')
        wr(f'ALU.out, MDR.in, WR')

    elif dst == '@R':
        wr(f'R.out, MAR.in, RD')
        wr(f'MDR.out, {func}')
        wr(f'ALU.out, MDR.in, WR')

    elif dst == '@(R)+':
        wr(f'R.out, MAR.in, RD')
        wr(f'MAR.out, ALU.r+1')
        wr(f'ALU.out, R.in')
        wr(f'MDR.out, {func}')
        wr(f'ALU.out, MDR.in, WR')

    elif dst == '@-(R)':
        wr(f'R.out, ALU.r-1')
        wr(f'ALU.out, R.in, MAR.in, RD')
        wr(f'MDR.out, {func}')
        wr(f'ALU.out, MDR.in, WR')

    elif dst == '@X(R)':
        # get x
        wr(f'PC.out, MAR.in, RD')

        # pc++
        wr(f'PC.out, ALU.r+1')
        wr(f'ALU.out, PC.in')

        # tmp = x+R
        wr(f'MDR.out, TMP0.in')

        # get tmp
        wr(f'R.out, ALU.c=0, ALU.r+l+c')
        wr(f'ALU.out, MAR.in, RD')

        # get tmp
        wr(f'MDR.out, MAR.in, RD')

        wr(f'MDR.out, {func}')
        wr(f'ALU.out, MDR.in, WR')


def ror(dst):
    return lsr(dst, 'ALU.ror')


def rrc(dst):
    return lsr(dst, 'ALU.rrc')


def asr(dst):
    return lsr(dst, 'ALU.asr')


def lsl(dst):
    return lsr(dst, 'ALU.c=0, ALU.rlc')


def rol(dst):
    return lsr(dst, 'ALU.rol')


def rlc(dst):
    return lsr(dst, 'ALU.rlc')


def branch(cond: str):
    if cond is not None:
        wr(f'IF NOT {cond} THEN END, ', end='')

    wr(f'IR.addr.out, TMP0.in')
    wr(f'PC.out, ALU.c=0, ALU.r+l+c')
    wr(f'ALU.out, PC.in')


jsr = '''PC.out, MAR.in, RD
PC.out, ALU.r+1
ALU.out, PC.in
MDR.out, TMP1.in
R.out, ALU.c=0, ALU.r+l+c
ALU.out, TMP1.in
R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
PC.out, MDR.in, WR
TMP1.out, PC.in'''

rts = '''R6.out, MAR.in, RD
MDR.out, PC.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in'''

intt = '''R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
FLAGS.out, MDR.in
R6.out, MAR.in, RD
R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
PC.out, MDR.in
R6.out, MAR.in, RD
PC.in, HARDWARE_ADDRESS.out'''

iret = '''R6.out, MAR.in, RD
MDR.out, PC.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in
R6.out, MAR.in, RD
MDR.out, FLAGS.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in'''

#############################

print('''\
------------------------------------------
PDP11-Simplified 2-Bus Micro-instructions
------------------------------------------

Notes:
    - Right bus is shortened as `r`, left is `l`.
    - FLAGS register is connected (out) to `r` and (in) to `l`.
    - ALU has output register to buffer its output, 
        where ALU.out outs it to bus.
    - Instruction fetch micro-instructions are performed one time before each instruction, 
        they are omitted for clearity.
    - ALU functions:
        -- outs zero:                 ALU.zero
        -- clear carry:               ALU.c=0
        -- increment:                 ALU.r+1
        -- decrement:                 ALU.r-1
        -- add with carry:            ALU.r+l+c
        -- sub with carry:            ALU.r-l-c
        -- and:                       ALU.r&l
        -- or:                        ALU.r|l
        -- xnor:                      ALU.r(XNOR)l
        -- not r:                     ALU.~r
        -- arithmetic shift right:    ALU.asr           (ALU[15]   & ALU[15:1])
        -- rotate right:              ALU.ror           (ALU[0]    & ALU[15:1])
        -- rotate left:               ALU.rol           (ALU[14:0] & ALU[15])
        -- rotate right with carry:   ALU.rrc           (carry     & ALU[15:1])
        -- rotate left with carry:    ALU.rlc           (ALU[14:0] & carry)

---------------
Fetch micro-instructions
---------------
PC.out, MAR.in, ALU.r+1, RD
ALU.out, PC.in
MDR.out, IR.in
''') 

cycles, memaccess = 4, 1

inst_to_cycles = {}

all_cycles = []
all_memaccess = []
unique_signals = set()
json_out = {'instructions': {}, 'signals': {}}
lines = []

def get_unique(inp: str):
    global unique_signals
    
    for line in inp.splitlines():
        for x in line.split(', '):
            if 'IF' not in x:
                unique_signals.add(x.strip())


def wr(x: str, end='\n'):
    global cycles, memaccess, lines
    cycles += 1 + x.count('\n')
    memaccess += x.count('RD') + x.count('WR')
    lines.extend(x.splitlines())
    get_unique(x)

    assert x.count('r_name') == 0

    print(x, end=end)


modes = ['R', '(R)+', '-(R)', 'X(R)', '@R',
              '@(R)+', '@-(R)', '@X(R)']

for (instr, instr_name) in [(mov, 'MOV'), (add, 'ADD'), (adc, 'ADC'),
                            (sub, 'SUB'), (subc, 'SUBC'), (andd, 'AND'),
                            (orr, 'OR'), (xnor, 'XNOR'), (cmpp, 'CMP')]:
    inst_cycles = []

    for src in modes:
        for dst in modes:
            print()
            print('-'*15)
            print(instr_name, src, dst)
            print('-'*15)

            instr(src, dst)
            wr(f'END')

            json_out['instructions'][f'{instr_name} {src} {dst}'] = lines
            print()
            print(f'CPU cycles = {cycles}')
            print(f'MEM access = {memaccess}')
            all_cycles.append(cycles)
            inst_cycles.append(cycles)
            all_memaccess.append(memaccess)
            cycles, memaccess = 4, 1
            lines = []

    inst_to_cycles[instr_name] = {
        'avg': sum(inst_cycles)/len(inst_cycles),
        'max': max(inst_cycles),
        'min': min(inst_cycles)
    }
    

for (instr, instr_name) in [(inc, 'INC'), (dec, 'DEC'), (clr, 'CLR'),
                            (inv, 'INV'), (lsr, 'LSR'), (ror, 'ROR'), (rrc, 'RRC'),
                            (asr, 'ASR'), (lsl, 'LSL'), (rol, 'ROL'), (rlc, 'RLC')]:
    inst_cycles = []

    for dst in modes:
        print()
        print('-'*15)
        print(instr_name, dst)
        print('-'*15)

        instr(dst)
        wr(f'END')

        json_out['instructions'][f'{instr_name} {src} {dst}'] = lines
        print()
        print(f'CPU cycles = {cycles}')
        print(f'MEM access = {memaccess}')
        all_cycles.append(cycles)
        inst_cycles.append(cycles)
        all_memaccess.append(memaccess)
        cycles, memaccess = 4, 1
        lines = []

    inst_to_cycles[instr_name] = {
        'avg': sum(inst_cycles)/len(inst_cycles),
        'max': max(inst_cycles),
        'min': min(inst_cycles)
    }

for (name, cond) in [('BR', None),
                     ('BEQ', '(Z=1)'), ('BNE', '(Z=0)'),
                     ('BLO', '(C=0)'), ('BLS', '(C=0 or Z=1)'),
                     ('BHI', '(C=1)'), ('BHS', '(C=1 or Z=1)')]:
    inst_cycles = []

    print()
    print('-'*15)
    print(name, '<OFFSET>')
    print('-'*15)

    branch(cond)
    wr(f'END')

    json_out['instructions'][f'{name}'] = lines
    print()
    print(f'CPU cycles = {cycles}')
    print(f'MEM access = {memaccess}')
    all_cycles.append(cycles)
    inst_cycles.append(cycles)
    all_memaccess.append(memaccess)
    cycles, memaccess = 4, 1
    lines = []

    inst_to_cycles[name] = {
        'avg': sum(inst_cycles)/len(inst_cycles),
        'max': max(inst_cycles),
        'min': min(inst_cycles)
    }

for (name, code) in [('HLT', 'HLT'), ('NOP', ''),
                     ('JSR X(R)', jsr),
                     ('RTS', rts),
                     ('INT', intt),
                     ('IRET', iret)]:
    print()
    print('-'*15)
    print(name)
    print('-'*15)

    if code != '':
        wr(code)
    if name != 'HLT':
        wr(f'END')

    json_out['instructions'][f'{name}'] = lines
    print()
    print(f'CPU cycles = {cycles}')
    print(f'MEM access = {memaccess}')
    all_cycles.append(cycles)
    all_memaccess.append(memaccess)
    cycles, memaccess = 4, 1
    lines = []

    inst_to_cycles[name] = {
        'avg': cycles,
        'max': cycles,
        'min': cycles
    }


print('-'*20)
print('-'*20)
print(f'Total CPU cycles = {sum(all_cycles)}')
print(f'Total MEM access = {sum(all_memaccess)}')


print()
print(f'Average MEM access = {sum(all_memaccess)/len(all_memaccess):3.3f}')
print(f'CPI = {sum(all_cycles)/len(all_cycles):3.3f}')

print()
print('-'*20)
print('-'*20)
print('INSTRUCTION  MIN  MAX  AVG')
items = sorted([(x, y) for (x,y) in inst_to_cycles.items()], key=lambda x: x[0])

for name, cyc in items:
    print(name, '\t', cyc['min'], cyc['max'], int(cyc['avg']))


unique_signals.discard('')
unique_signals.discard('R.out')
unique_signals.discard('R.in')
unique_signals.discard('R6.out')
unique_signals.discard('R6.in')
unique_signals.discard('END')
unique_signals.discard('HLT')
unique_signals.discard('HARDWARE_ADDRESS.out')

unique_signals = list(unique_signals)
unique_signals.sort()

print('-'*20)
print('-'*20)
print(f'Total Control Signals ({len(unique_signals)}):', '{')
for sig in unique_signals: print('\t', sig, sep='')
print('}')

import json, sys
json_out['signals'] = unique_signals
print(json.dumps(json_out), file=sys.stderr)