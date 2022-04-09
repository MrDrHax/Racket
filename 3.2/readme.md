# The dissect formulas thingy

By Alejandro Fernandez

Index:
- [requisites](#requisites)
- [Functions given:](#functions-given)
  - [arithmetic-lexer](#arithmetic-lexer)
    - [call](#call)
    - [returns](#returns)
    - [Examples](#examples)


# requisites

- Racket-lang

file `activity.rkt`

# Functions given:

## arithmetic-lexer

The arithmetic-lexer does formula dissection, meaning that it separates all the formula parts.

### call
To call it, you need to give it a string-type mathematic formula

### returns
Returns array of components with description of element

Example:
> ((7 int), (//something comment))

### Examples

`$ (arithmetic-lexer "a = 32.4 *(-8.6 - b)/       6.1E-8")`

> `'((#\a Variable) (#\= Asignacion) ((#\3 #\2 #\. #\4) Real) (#\* Multiplicacion) (#\( "Parentesis que abre") ((#\- #\8 #\. #\6) Real) (#\- Resta) (#\b Variable) (#\) "Parentesis que cierra") (#\/ Division) ((#\6 #\. #\1 #\E #\- #\8) Real))`