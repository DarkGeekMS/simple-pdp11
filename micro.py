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
    return add(src, dst, 'ALU.rXNORl')


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
    return inc(dst, 'ALU.not')


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
MDR.out, FLAGS.in
R6.out, ALU.r+1
ALU.out, R6.in, MAR.in'''

#############################

fetch = '''PC.out, ALU.=r, ALU.out, MAR.in, RD
PC.out, ALU.r+1
ALU.out, PC.in, WMFC
MDR.out, ALU.=r, ALU.out, IR.in
'''

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

            print(fetch)
            instr(src, dst)
            print('\nEND')

for (instr, instr_name) in [(inc, 'INC'), (dec, 'DEC'), (clr, 'CLR'),
                            (inv, 'INV'), (lsr, 'LSR'), (ror, 'ROR'), (rrc, 'RRC'),
                            (asr, 'ASR'), (lsl, 'LSL'), (rol, 'ROL'), (rlc, 'RLC')]:
    for dst in modes:
        print()
        print('-'*15)
        print(instr_name, dst)
        print('-'*15)

        print(fetch)
        instr(dst)
        print('\nEND')

for (name, cond) in [('BR', None),
                     ('BEQ', '(Z=1)'), ('BNE', '(Z=0)'),
                     ('BLO', '(C=0)'), ('BLS', '(C=0 or Z=1)'),
                     ('BHI', '(C=1)'), ('BHS', '(C=1 or Z=1)')]:
    print()
    print('-'*15)
    print(name, '<OFFSET>')
    print('-'*15)

    print(fetch)
    branch(cond)
    print('\nEND')

for (name, code) in [('HLT', 'HLT'), ('NOP', 'END'),
                     ('JSR X(R)', jsr),
                     ('RTS', rts),
                     ('INT', intt),
                     ('IRET', iret)]:
    print()
    print('-'*15)
    print(name)
    print('-'*15)

    print(fetch)
    print(code)
    print('\nEND')
