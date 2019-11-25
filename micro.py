addressing = ['R', '(R)+', '-(R)', 'X(R)', '@R',
              '@(R)+', '@-(R)', '@X(R)']


fetch = '''PC.out, ALU.=r, ALU.out, MAR.in, RD
PC.out, ALU.r+1
ALU.out, PC.in, WMFC
MDR.out, ALU.=r, ALU.out, IR.in'''


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


def write_adr(mode: str, inp: str, ex: bool = False):
    if mode in ('R', '(R)+', '-(R)'):
        if inp == 'R':
            print('R(src).out, ALU.=r, ALU.out, R(dst).in')
        else:
            print(f'{inp}.out.l, R.in')

    elif mode == 'X(R)':
        if ex:
            # get x
            print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

            # pc++
            print('PC.out, ALU.r+1')
            print('ALU.out, PC.in, WMFC')

            # [x+R] = inp
            print(f'MDR.out, TMP2.in.r')
            print(f'R.out, TMP2.out.l, ALU.r+l')
            print(f'ALU.out, MAR.in')

        tmp = f'{inp}.out.l' if inp != 'R' else 'R.out, ALU.=r, ALU.out'
        print(f'{tmp}, MDR.in, WR, WMFC')

    elif mode == '@R':
        if ex:
            if inp == 'R':
                print('R(first).out, ALU.=r, ALU.out, MAR.in')
                print('R(second).out, ALU.=r, ALU.out, MDR.in, WR. WMFC')
            else:
                print(f'R.out, ALU.=r, ALU.out, MAR.in')
                print(f'{inp}.out.l, MDR.in. WR, WMFC')
        else:
            tmp = f'{inp}.out.r' if inp != 'R' else 'R.out, ALU.=r, ALU.out'
            print(f'{tmp}, MDR.in, WR, WMFC')

    elif mode == '@(R)+':
        if ex:
            if inp == 'R':
                print('R(first).out, ALU.=r, MAR.in')
                print('R(second).out, ALU.=r, ALU.out, MDR.in, WR')
            else:
                print('R.out, ALU.=r, MAR.in')
                print(f'{inp}.out.l, MDR.in')

            print('R.out, ALU.r+1')
            print('ALU.out, R.in, WMFC')

        else:
            print(f'{inp}.out.l, MDR.in, WR, WMFC')

    elif mode == '@-(R)':
        if ex:
            print(f'R.out, ALU.r-1, ALU.out, TMP1.in.l, MAR.in')
            print(f'TMP1.out.l, R.in')

        tmp = f'{inp}.out.l' if inp != 'R' else 'R.out, ALU.=r, ALU.out'
        print(f'{tmp}, MDR.in, WR, WMFC')

    elif mode == '@X(R)':
        if ex:
            # get x
            print('PC.out, ALU.=r, ALU.out, MAR.in, RD')

            # pc++
            print('PC.out, ALU.r+1')
            print('ALU.out, PC.in, WMFC')

            # tmp = x+R
            print(f'MDR.out, TMP1.in.r')
            print(f'R.out, TMP1.out.l, ALU.r+l')

            # get inp
            print(f'ALU.out, MAR.in')

        tmp = f'{inp}.out.l' if inp != 'R' else 'R.out, ALU.=r, ALU.out'
        print(f'{tmp}, MDR.in, WR, WMFC')
