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


def write_adr(mode:str, tmp: str):
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
