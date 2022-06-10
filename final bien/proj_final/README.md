# Integrative Activity 5.3:
## Parallel Syntax Highlighter (Evidence of Proficiency)

**Team 13**

Ariadne Alvarez Reyes | A01652080 

Alejandro Fernández del Valle Herrera | A01024998

**This project parses JSON files into HTML.**

# Adaptation to other languages:

This code is an adaptation of an early prototype located in: [This repo](https://github.com/MrDrHax/Racket/tree/main/final).

If you like Racket lang better, you can look at that project and run it by running `doTheTHing.rkt`.

## Description
For this evidence we show an extended preview of the previous installment 3.4. This program **sequentially applies lexical highlighting** to multiple source files contained in one or more nested directories. We implement this one in **parallel** in order to take advantage of the multiple cores/threads available. Now it calculate the obtained speedup.

## Installation

Have Elixir installed on your computer. To run, use:

Download the files of this [gitHub repo](https://github.com/MrDrHax/Racket/tree/main/final%20bien/proj_final)

Navigate to decompressed files and run in terminal:

`> iex ./lib/proj_final.ex`

## Usage

### To convert various files at the same time
```
> ProjFinal.parseFiles(["list", "of", "JSON", "files", "as", "paths"], "output/folder/as/path")
```

> NOTE: paths can be relative or absolute,
>
> To make absolute, use / at the begging, to make relative start with ./

This will use parallelism to make sure you spend the least time waiting for your files to convert. This code can take in large amount of files, and big files. (tested up to 1GB). Requires a lineal amount of RAM per file.

### To convert one file only

```
> ProjFinal.read("input/file/as/path", "output/folder/as/path")
```

Same as parseFiles, but only it does one. 

### Make it yours!

If you want to change the colors, simply modify the style.css located in `lib/elements/style.css` There you can find all the different colors and spaces used. To apply changes, run the code again.

## How it works

Taking the other evidence as a reference, we define a variable for our files and the time that will be measured. This program is sequential and has a lineal complexity, this means that it will run and last as large as the document is.


## Solution to problem

As part of the day to day use of a programer, we need to make sure we can read and understand complex data structures as quick as possible, to be able to debug, reference, and build new information. 

As of now, JSON files are the standard to share information across the internet, as well as save some lightweight data. Therefore, having a tool that allows you to quickly organize and visualize the information you are sending or receiving will allow developers worldwide to correctly and quickly identify what they are working with, as well as how to read the data.

# Algorithms used

This code uses a ***State Machine*** to ensure that syntax highlighting can be done as quick as possible. It checks each individual character and, uses cases when possible to speed up character lookup. 

It lacks flexibility of adaptation due to sacrifices due to speed, meaning that new languages can be added, but it will require a lot more config.

# Conclusion

Now this algorithms allow us to have  a better solution and also have an specific execution of the the time for each  example. The speed of the algorithm depends on how large the document is, so now its not compromised by its complexity. We continued using regex because of it simplicity, making so much simple our program, also it helped us with the html.
