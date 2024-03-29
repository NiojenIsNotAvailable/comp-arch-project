# comp_arch_project
## Assembly Project
Horiachok Daryna, Variant - 3

## Formulation of the problem

This is an assembly program that reads data from a file until EOF appears (maximum 10000 lines), finds keys and numbers around them, finds the average value among the numbers of one key.

Each line is a "<key> <value>" pair (separated by a space), where the key is a text identifier of max 16 characters (any characters except white space chars - a space or a newline), and the value is a decimal integer signed number in the range [-10000, 10000].

Sorted by the bubble sort algorithm according to <average>, and output to stdout key values from larger to smaller (average desc), each key in a separate line.



The following Visual Studio Code extension is used to launch files with the .asm extension:
https://marketplace.visualstudio.com/items?itemName=xsro.masm-tasm
