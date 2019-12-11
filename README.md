# Simple PDP11
Simple PDP11-equivalent CPU implemented in vhdl. Comp. Arch. School project

# To run all tests:
```bash
$ ./run-test
```

# To run specific test:
```bash
$ ./run-test <test name without suffix>
```

# To create new unit with template
```bash
$ ./new <unit name> <unit optional path>
```

# To run specific non-vunit-test file:
```bash
$ ./run <unit name without suffix>
```

# To clean output and kill the daemon:
```bash
$ ./clean
```

# To list the available test cases:
```bash
$ ./list-tests
```

# To view the logs of tests:
```bash
$ ./logs <optional name of test file with no suffix>
```

# To view the wave file of some test case
```bash
$ ./wave <test file name>.<test case name>
```

# To run the assembler on a given program
- Place the program in "assembler/io" as "program.txt"
```bash
$ python assembler/assembler.py 
```
