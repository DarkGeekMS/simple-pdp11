# Simple PDP11
Simple PDP11-equivalent CPU implemented in vhdl. Comp. Arch. School project

# How to simulate the main integration entity in modelsim:

1. Make sure you compile all files in src/ before compiling src/main.vhdl, solve dependency issues by compiling dependecies first.

0. Start by running main in modelsim gui.

0. Load ram with one of the files in assembler/io.

0. Enfore a clock in `clk` .

0. Enforce zeros in `int` , `int_address` .

0. Enforce Z in `bbus` which is the bus.

0. `rst` must be set for one clock cycle at least one time to reset the system.

* In the middle of the simulation, you can make a hardware interrupt by enforcing 1 in `int` and putting interrupt address in `int_address` , you should'nt interrupt while the CU performs an instruction, but before the instruction is loaded or after it's finished executing.

* `hlt` out signal is set to 1 by CU when the cpu halts.

* `num_iteration` internal signal can be used to keep track of the number of current iteration.

# To run all tests:

``` bash
$ ./run-test
```

# To run specific test:

``` bash
$ ./run-test <test name without suffix>
```

# To create new unit with template

``` bash
$ ./new <unit name> <unit optional path>
```

# To run specific non-vunit-test file:

``` bash
$ ./run <unit name without suffix>
```

# To clean output and kill the daemon:

``` bash
$ ./clean
```

# To list the available test cases:

``` bash
$ ./list-tests
```

# To view the logs of tests:

``` bash
$ ./logs <optional name of test file with no suffix>
```

# To view the wave file of some test case

``` bash
$ ./wave <test file name>.<test case name>
```

# To run the assembler on a given program

* Place the program in "assembler/io" as "program.txt"

``` bash
$ python assembler/assembler.py 
```

