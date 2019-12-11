import argparse
import re

OP_CODES_TABLE = {
    "mov": "0001",
    "add": "0010",
    "adc": "0011",
    "sub": "0100",
    "sbc": "0101",
    "and": "0110",
    "or": "0111",
    "xnor": "1000",
    "cmp": "1001",
    "inc": "11110000",
    "dec": "11110001",
    "clr": "11110010",
    "inv": "11110011",
    "lsr": "11110100",
    "ror": "11110101",
    "rrc": "11110110",
    "asr": "11110111",
    "lsl": "11111000",
    "rol": "11111001",
    "rl": "11111010",
    "br": "000000",
    "beq": "000001",
    "bne": "000010",
    "blo": "000011",
    "bls": "110000",
    "bhi": "110001",
    "bhs": "110011",
    "hlt": "1010",
    "nop": "1011",
    "jsr": "1101",
    "rts": "111001",
    "interrupt": "111010",
    "iret": "111011"
}

INST_2OP = ["mov", "add", "adc", "sub", "sbc", "and", "or", "xnor", "cmp"]

INST_1OP = ["inc", "dec", "clr", "inv", "lsr", "ror", "rrc", "asr", "lsl", "rol", "rl"]

INST_BR = ["br", "beq", "bne", "blo", "bls", "bhi", "bhs"]

INST_SPEC = ["hlt", "nop", "jsr", "rts", "interrupt", "iret"]

REGISTERS = {
    "R0": "000",
    "R1": "001",
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}

def parse_operand(operand):
    """
        Convert the operand text to the corresponding code
        and handles variables and immediate addressing.

        Parameters:
        operand (string): the string of the operand to be parsed.

        Return:
        operand_code (string): binary representation of given operand.
        type (string): type of the operand (register, variable or immediate)
    """
    code = None
    if (operand[0] == '@'):
        code = '1'
        operand = operand[1:]
    else:
        code = '0'        
    if (operand in REGISTERS.keys()):
        return code + "00" + REGISTERS[operand], "reg"
    elif (operand[0] == '(' and operand[-1] == '+'):
        return code + "01" + REGISTERS[operand[1:-2]], "reg"
    elif (operand[0] == '-'):
        return code + "10" + REGISTERS[operand[2:-1]], "reg"   
    elif (operand[0].lower() == 'x' and operand[-1] == ')'):
        return code + "11" + REGISTERS[operand[2:-1]], "reg"
    if (operand[0] == '#'):
        return "001111", "imm"
    else:
        return "011111", "var"   


def assemble(input_txt, output_txt):
    """
        Go through the input text, 
        assemble RAM words
        and save them to output text.

        Parameters:
        input_txt (string): name of input text.
        output_txt (string): name of outut text.
    """
    #initialize variables
    in_file = open("assembler/io/"+input_txt, "r")
    br_labels = dict()
    var_labels = dict()
    ram_layout = dict()
    bin_iter = 0

    # loop over every line in the input program
    for line in in_file:
        # remove comments
        com_idx = line.find(";")
        if (com_idx != -1):
            if (com_idx != 0):
                line = line[:com_idx-1]
            else:
                continue
        # check for labels
        lb_idx = line.find(":")
        if (lb_idx != -1):
            br_labels[line[:lb_idx].strip().lower()] = bin_iter  
            if (lb_idx != len(line)-1): 
                line = line[lb_idx+1:]
            else:
                continue      
        # split words by delimiters        
        line_words = re.split(';|,| |\n', line)    
        line_words = [x for x in line_words if x != '']
        if (len(line_words) == 0):
            continue    
        # parse the instruction 
        bin_inst = None  
        if (len(line_words) == 0 and line_words[0].isnumeric()): # numeric value (X)
            value = str(format(int(line_words[0]), 'b'))
            if (value[0] == '-'):
                bin_inst = '1' + '0'*(15-len(value[1:])) + value[1:]
            else:
                bin_inst = '0' + '0'*(15-len(value)) + value
            ram_layout[bin_iter] = bin_inst    
        elif (line_words[0].lower() in INST_2OP): # 2-operand instruction
            op_code = OP_CODES_TABLE[line_words[0].lower()]
            op1_code, type1 = parse_operand(line_words[1])
            op2_code, type2 = parse_operand(line_words[2])
            bin_inst = op_code + op1_code + op2_code
            ram_layout[bin_iter] = bin_inst
            if (type1 == "imm"):
                bin_iter += 1
                value = str(format(int(line_words[1][1:]), 'b'))
                if (value[0] == '-'):
                    bin_inst = '1' + '0'*(15-len(value[1:])) + value[1:]
                else:
                    bin_inst = '0' + '0'*(15-len(value)) + value    
                ram_layout[bin_iter] = bin_inst 
            elif (type1 == "var"):
                bin_iter += 1
                ram_layout[bin_iter] = '?' + line_words[1].lower()
            if (type2 == "imm"):
                bin_iter += 1
                value = str(format(int(line_words[2][1:]), 'b'))
                if (value[0] == '-'):
                    bin_inst = '1' + '0'*(15-len(value[1:])) + value[1:]
                else:
                    bin_inst = '0' + '0'*(15-len(value)) + value    
                ram_layout[bin_iter] = bin_inst
            elif (type2 == "var"):
                bin_iter += 1
                ram_layout[bin_iter] = '?' + line_words[2].lower()           
        elif (line_words[0].lower() in INST_1OP): # 1-operand instruction
            op_code = OP_CODES_TABLE[line_words[0].lower()] + "00"
            op_code_, type_ = parse_operand(line_words[1])
            bin_inst = op_code + op_code_
            ram_layout[bin_iter] = bin_inst
            if (type_ == "imm"):
                bin_iter += 1
                value = str(format(int(line_words[1][1:]), 'b'))
                if (value[0] == '-'):
                    bin_inst = '1' + '0'*(15-len(value[1:])) + value[1:]
                else:
                    bin_inst = '0' + '0'*(15-len(value)) + value    
                ram_layout[bin_iter] = bin_inst
            elif (type_ == "var"):
                bin_iter += 1
                ram_layout[bin_iter] = '?' + line_words[1].lower()
        elif (line_words[0].lower() in INST_BR): # branch instruction
            op_code = OP_CODES_TABLE[line_words[0].lower()]
            bin_inst = op_code + '?' + line_words[1].lower()
            ram_layout[bin_iter] = bin_inst
        elif (line_words[0].lower() in INST_SPEC): # special instruction
            if (line_words[0].lower() == "jsr"):
                bin_inst = OP_CODES_TABLE["jsr"] + line_words[1]
            else:
                op_code = OP_CODES_TABLE[line_words[0].lower()]
                bin_inst = op_code + '0'*(16-len(op_code))   
            ram_layout[bin_iter] = bin_inst              
        # define variables
        if (line_words[0].lower() == "define"):
            var_labels[line_words[1].lower()] = bin_iter 
            value = str(format(int(line_words[2]), 'b'))
            if (value[0] == '-'):
                bin_inst = '1' + '0'*(15-len(value[1:])) + value[1:]
            else:
                bin_inst = '0' + '0'*(15-len(value)) + value    
            ram_layout[bin_iter] = bin_inst    
        # increase address count      
        bin_iter += 1

    in_file.close()
    # loop over current RAM layout to fill in variable addresses
    for key in ram_layout.keys():
        idx = ram_layout[key].find('?')
        if (idx != -1):
            if (idx != 0): # branch label
                label_address = br_labels[ram_layout[key][idx+1:]]
                offset = label_address - key - 1
                value = str(format(int(offset), 'b'))
                if (value[0] == '-'):
                    ram_layout[key] = ram_layout[key][:6] + '1' + '0'*(9-len(value[1:])) + value[1:]
                else:
                    ram_layout[key] = ram_layout[key][:6] + '0' + '0'*(9-len(value)) + value  
            else: # variable
                var_address = var_labels[ram_layout[key][idx+1:]]
                offset = var_address - key - 1
                value = str(format(int(offset), 'b'))
                if (value[0] == '-'):
                    ram_layout[key] = '1' + '0'*(15-len(value[1:])) + value[1:]
                else:
                    ram_layout[key] = '0' + '0'*(15-len(value)) + value 

    # write the RAM layout to the output text
    out_file = open("assembler/io/"+output_txt, "w")    
    for row in ram_layout.values():
        out_file.write(row)
        out_file.write("\n")
    out_file.close()


def main():
    """
        The main function for argument parsing.
    """
    argparser = argparse.ArgumentParser(description=__doc__)
    argparser.add_argument(
        '-if', '--input_file',
        metavar='IF',
        default='program.txt',
        help='name of input text in io directory')
    argparser.add_argument(
        '-of', '--output_file',
        metavar='OF',
        default='ram.txt',
        help='name of output text in io directory'
    )
    args = argparser.parse_args()
    assemble(args.input_file, args.output_file)


if __name__ == '__main__':
    main()    