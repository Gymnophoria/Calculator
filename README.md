# Calculator
A basic x86-64 CLI-based assembly calculator for Linux.

Tested on Ubuntu 18.04 LTS; probably works for most versions of Linux. Created as the course project for SRJC's CS 12 (Assembly) class in the Spring 2021 term.

To compile, simply `make main` and then run from terminal with `./main`. The Makefile is set up for yasm and ld.

## Features
 - Five operations supported:
   - Addition (+)
   - Subtraction (-)
   - Multiplication (*)
   - Division (/)
   - Modulus (%)
 - Answer rollover (e.g. operations based on previous answer)
 - Negative/positive support
 - Input validation

## Limitations
 - Max input size is 128 characters
 - Program uses 64 bit signed integers; as a result:
   - Numbers must be within the range -2^63 to 2^63 -1
     - -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
   - No decimals will be provided in results
   - Integers *will* overflow without warning
   - Numbers may be truncated
 - Complex equations (i.e. more than two numbers) are not supported