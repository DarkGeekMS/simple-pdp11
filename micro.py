def fetch_adr(mode: str, tmp: str):
    if mode == 'R':
        return 'R'

    elif mode == '(R)+':
        print(f'R.out, {tmp}.in.r, ALU.r+1')
        print('ALU.out, R.in')

        return tmp

    elif mode == '-(R)':
        print('R.out, ALU.r-1')
        print('ALU.out, R.in')

        return 'R'

    elif mode == 'X(R)':
        # get x
        print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

        # pc++
        print('PC.out, ALU.r+1')
        print('ALU.out, PC.in, WMFC')

        # tmp = x+R
        print(f'MDR.out, {tmp}.in.r')
        print(f'R.out, {tmp}.out.l, ALU.r+l')
        print(f'ALU.out, {tmp}.in.l')

        return tmp

    elif mode == '@R':
        print('R.out, ALU.=r, ALU.out, MAR.in, RD, WMFC')
        print(f'MDR.out, {tmp}.in.r')

        return tmp

    elif mode == '@(R)+':
        print('R.out, ALU.=r, ALU.out, MAR.in, RD')
        print(f'MAR.out, ALU.r+1, ALU.out, R.in, WMFC')
        print(f'MDR.out, {tmp}.in.r')

        return tmp

    elif mode == '@-(R)':
        print(f'R.out, ALU.r-1, ALU.out, {tmp}.in.l')
        print(f'{tmp}.out.l, R.in, MAR.in, RD, WMFC')
        print(f'MDR.out, {tmp}.in.r')

        return tmp

    elif mode == '@X(R)':
        # get x
        print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

        # pc++
        print('PC.out, ALU.r+1')
        print('ALU.out, PC.in, WMFC')

        # tmp = x+R
        print(f'MDR.out, {tmp}.in.r')
        print(f'R.out, {tmp}.out.l, ALU.r+l')

        # get tmp
        print(f'ALU.out, MAR.in, RD, WMFC')
        print(f'MDR.out, {tmp}.in.r')

        return tmp


def _write_adr_R(mode: str):
    if mode in ('R', '-(R)', '(R)+'):
        print('R(src).out, ALU.=r, ALU.out, R(dst).in')

    elif mode == 'X(R)':
        print('R(src).out, ALU.=r, ALU.out, MDR.in, WR, WMFC')

    else:
        print('R(src).out, ALU.=r, ALU.out, MDR.in, WR, WMFC')


def _write_adr_ALU(mode: str):
    if mode in ('R', '-(R)', '(R)+'):
        print('ALU.out, R(dst).in')

    else:
        print('ALU.out, MDR.in, WR, WMFC')


def _write_adr_TMP(mode: str, inp: str):
    if mode in ('R', '-(R)', '(R)+'):
        print(f'{inp}.out.l, R.in')

    else:
        print(f'{inp}.out.l, MDR.in, WR, WMFC')


def write_adr(mode: str, inp: str):
    if inp == 'R':
        _write_adr_R(mode)
    elif inp == 'ALU':
        _write_adr_ALU(mode)
    else:  # TMP#
        _write_adr_TMP(mode, inp)

#############################


def mov(src, dst):
    tmp1 = fetch_adr(src, 'TMP1')
    write_adr(dst, tmp1)


def add(src, dst, func='ALU.r+l'):
    tmp1 = fetch_adr(src, 'TMP1')
    tmp2 = fetch_adr(dst, 'TMP2')

    if tmp1 == 'R' and tmp2 == 'R':
        print(f'R(src).out, TMP1.in.r')
        print(f'R(dst).out, TMP1.out.l, {func}, ALU.out, R(src).in')

    elif tmp1 == 'R':
        print(f'R(src).out, TMP1.in.r')
        print(f'TMP2.out.r, TMP1.out.l, {func}')
        write_adr(dst, 'ALU')

    elif tmp2 == 'R':
        print(f'R(dst).out, TMP1.out.l, {func}')
        write_adr(dst, 'ALU')

    else:
        print(f'{tmp1}.out.r, {tmp2}.out.l, {func}')
        write_adr(dst, 'ALU')


def adc(src, dst):
    return add(src, dst, 'ALU.r+l+c')


def sub(src, dst):
    return add(src, dst, 'ALU.r-l')


def subc(src, dst):
    return add(src, dst, 'ALU.r-l-c')


def andd(src, dst):
    return add(src, dst, 'ALU.r^l')


def orr(src, dst):
    return add(src, dst, 'ALU.r|l')


def xnor(src, dst):
    return add(src, dst, 'ALU.r(XNOR)l')


def cmpp(src, dst):
    tmp1 = fetch_adr(src, 'TMP1')
    tmp2 = fetch_adr(dst, 'TMP2')

    if tmp1 == 'R' and tmp2 == 'R':
        print(f'R(src).out, TMP1.in.r')
        print(f'R(dst).out, TMP1.out.l, ALU.r-l')

    elif tmp1 == 'R':
        print(f'R(src).out, TMP1.in.r')
        print(f'TMP2.out.r, TMP1.out.l, ALU.r-l')

    elif tmp2 == 'R':
        print(f'R(dst).out, TMP1.out.l, ALU.r-l')

    else:
        print(f'{tmp1}.out.r, {tmp2}.out.l, ALU.r-l')


def inc(dst, func='ALU.r+1'):
    tmp = fetch_adr(dst, 'TMP1')

    if tmp == 'R':
        print(f'R.out, {func}')
    else:
        print(f'{tmp}.out.r, {func}')

    write_adr(dst, 'ALU')


def dec(dst):
    return inc(dst, 'ALU.r-1')


def clr(dst):
    if dst in ('R', '-(R)', '(R)+'):
        print('Zero, R(dst).in')

    elif dst == 'X(R)':
        # get x
        print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

        # pc++
        print('PC.out, ALU.r+1')
        print('ALU.out, PC.in, WMFC')

        # [x+R] = inp
        print('MDR.out, TMP2.in.r')
        print('R.out, TMP2.out.l, ALU.r+l')
        print('ALU.out, MAR.in')

        print('Zero, MDR.in, WR, WMFC')

    elif dst == '@R':
        print('R(dst).out, ALU.=r, ALU.out, MAR.in')

        print('Zero, MDR.in, WR, WMFC')

    elif dst == '@(R)+':
        print('R(dst).out, ALU.=r, MAR.in')

        print('Zero, MDR.in, WR, WMFC')

        print('R.out, ALU.r+1')
        print('ALU.out, R.in, WMFC')

        print('Zero, MDR.in, WR, WMFC')

    elif dst == '@-(R)':
        print('R(dst).out, ALU.r-1, ALU.out, TMP1.in.l, MAR.in')
        print('TMP1.out.l, R.in')

        print('Zero, MDR.in, WR, WMFC')

    elif dst == '@X(R)':
        # get x
        print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

        # pc++
        print('PC.out, ALU.r+1')
        print('ALU.out, PC.in, WMFC')

        # tmp = x+R
        print('MDR.out, TMP1.in.r')
        print('R.out, TMP1.out.l, ALU.r+l')

        # get inp
        print('ALU.out, MAR.in')

        print('Zero, MDR.in, WR, WMFC')


def inv(dst):
    return inc(dst, 'ALU.~r')


def lsr(dst, func='0 || [dst] 15->1'):
    tmp = fetch_adr(dst, 'TMP1')

    print(f'{tmp}.({func})')

    if tmp != 'R':
        write_adr(dst, tmp)


def ror(dst):
    return lsr(dst, '[dst] 0 || [dst] 15->1')


def rrc(dst):
    return lsr(dst, 'C || [dst] 15->1')


def asr(dst):
    return lsr(dst, '[dst] 15 || [dst] 15->1')


def lsl(dst):
    return lsr(dst, '[dst] 14->0 || 0')


def rol(dst):
    return lsr(dst, '[dst] 14->0 || [dst] 15')


def rlc(dst):
    return lsr(dst, '[dst] 14->0 || C')


def branch(cond: str):
    if cond is not None:
        print(f'IF NOT {cond} THEN END, ', end='')

    print('ADDR_PART_IR.out, TMP1.in.r')
    print('TMP1.out.l, PC.out, ALU.r+l')
    print('ALU.out, PC.in')


jsr = '''PC.out, ALU.=r, ALU.out, MAR.in, RD
PC.out, ALU.r+1
ALU.out, PC.in, WMFC
MDR.out, TMP1.in.r
R.out, TMP1.out.l, ALU.r+l
ALU.out, TMP1.in.l
R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
PC.out, ALU.=r, ALU.out, MDR.in, WR, WMFC
TM1.out.l, PC.in'''

rts = '''R6.out, ALU.=r, ALU.out, MAR.in, RD, WMFC
MDR.out, PC.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in'''

intt = '''R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
FLAGS.out, ALU.=r, ALU.out, MDR.in
R6.out, ALU.=r, ALU.out, MAR.in, RD, WMFC
R6.out, ALU.r-1
ALU.out, R6.in, MAR.in
PC.out, ALU.=r, ALU.out, MDR.in
R6.out, ALU.=r, ALU.out, MAR.in, RD, WMFC
PC.in, HARDWARE_ADDRESS'''

iret = '''R6.out, ALU.=r, ALU.out, MAR.in, RD, WMFC
MDR.out, PC.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in
R6.out, ALU.=r, ALU.out, MAR.in, RD, WMFC
MDR.out, ALU.=r, ALU.out, FLAGS.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in'''

#############################


print('''\
------------------------------------------
PDP11-Simplified 2-Bus Micro-instructions
------------------------------------------

Notes:
    - Right bus is shortened as `r`, left is `l`.
    - Every register can perform the following shift operations in-place:
        --  0 || [dst] 15->1
        --  [dst] 0 || [dst] 15->1
        --  C || [dst] 15->1
        --  [dst] 15 || [dst] 15->1
        --  [dst] 14->0 || 0
        --  [dst] 14->0 || [dst] 15
        --  [dst] 14->0 || C
    - FLAGS register is connected (out) to `r` and (in) to `l`.
    - ALU has output tri-state to buffer its output.
    - ALU functions:
        -- pass input from `r`:  =r
        -- enable output:        out
        -- add:                  r+l
        -- sub:                  r-l
        -- increment:            r+1
        -- decrement:            r-1
        -- add with carry:       r+l+c
        -- sub with carry:       r-l-c
        -- and:                  r&l
        -- or:                   r|l
        -- xnor:                 r(XNOR)l
        -- not r:                ~r
    - Every line in micro-instructions needs one and only one clock cicle.
    - Instruction fetch micro-instructions are performed one time before each instruction, 
        they are omitted for clearity.

---------------
Fetch micro-instructions
---------------
PC.out, ALU.=r, ALU.out, MAR.in, RD
PC.out, ALU.r+1
ALU.out, PC.in, WMFC
MDR.out, ALU.=r, ALU.out, IR.in
''')

cicles, memaccess = 4, 1

all_cicles = []
all_memaccess = []

def wr(x):
    global cicles, memaccess
    cicles += 1 + x.count('\n')
    memaccess += x.count('RD') + x.count('WR')

    print(x)

modes = ['R', '(R)+', '-(R)', 'X(R)', '@R',
              '@(R)+', '@-(R)', '@X(R)']

for (instr, instr_name) in [(mov, 'MOV'), (add, 'ADD'), (adc, 'ADC'),
                            (sub, 'SUB'), (subc, 'SUBC'), (andd, 'AND'),
                            (orr, 'OR'), (xnor, 'XNOR'), (cmpp, 'CMP')]:
    for src in modes:
        for dst in modes:
            print()
            print('-'*15)
            print(instr_name, src, dst)
            print('-'*15)

            instr(src, dst)
            wr('END')

            print(f'\nInstruction Total CPU cicles = {cicles}')
            print(f'Instruction Total MEM access (RD,WR) = {memaccess}')
            all_cicles.append(cicles)
            all_memaccess.append(memaccess)
            cicles, memaccess = 4, 1

for (instr, instr_name) in [(inc, 'INC'), (dec, 'DEC'), (clr, 'CLR'),
                            (inv, 'INV'), (lsr, 'LSR'), (ror, 'ROR'), (rrc, 'RRC'),
                            (asr, 'ASR'), (lsl, 'LSL'), (rol, 'ROL'), (rlc, 'RLC')]:
    for dst in modes:
        print()
        print('-'*15)
        print(instr_name, dst)
        print('-'*15)

        instr(dst)
        wr('END')

        print(f'\nInstruction Total CPU cicles = {cicles}')
        print(f'Instruction Total MEM access (RD,WR) = {memaccess}')
        all_cicles.append(cicles)
        all_memaccess.append(memaccess)
        cicles, memaccess = 4, 1

for (name, cond) in [('BR', None),
                     ('BEQ', '(Z=1)'), ('BNE', '(Z=0)'),
                     ('BLO', '(C=0)'), ('BLS', '(C=0 or Z=1)'),
                     ('BHI', '(C=1)'), ('BHS', '(C=1 or Z=1)')]:
    print()
    print('-'*15)
    print(name, '<OFFSET>')
    print('-'*15)

    branch(cond)
    wr('END')

    print(f'\nInstruction Total CPU cicles = {cicles}')
    print(f'Instruction Total MEM access (RD,WR) = {memaccess}')
    all_cicles.append(cicles)
    all_memaccess.append(memaccess)
    cicles, memaccess = 4, 1

for (name, code) in [('HLT', 'HLT'), ('NOP', 'END'),
                     ('JSR X(R)', jsr),
                     ('RTS', rts),
                     ('INT', intt),
                     ('IRET', iret)]:
    print()
    print('-'*15)
    print(name)
    print('-'*15)

    wr(code)
    wr('END')

    print(f'\nInstruction Total CPU cicles = {cicles}')
    print(f'Instruction Total MEM access (RD,WR) = {memaccess}')
    all_cicles.append(cicles)
    all_memaccess.append(memaccess)
    cicles, memaccess = 4, 1


print('-'*20)
print('-'*20)
print(f'Average MEM access = {sum(all_memaccess)/len(all_memaccess):3.3f}')
print(f'CPI = {sum(all_cicles)/len(all_cicles):3.3f}')