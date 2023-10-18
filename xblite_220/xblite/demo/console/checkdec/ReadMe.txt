
CheckDec is a syntax checker for XBLite and XBasic DEC 
files.  See the source code for usage information.

The syntax rules applied by CheckDec are more stringent than 
those applied by the XBasic or XBLite compilers - that is, 
many errors are flagged by CheckDec that the compiler will 
ignore, but may later cause compile, link or runtime errors. 
An example is the use of the colon as a line termination 
character within a TYPE declaration:

TYPE POINT_3D
  SLONG .x : SLONG .y : SLONG .z
END TYPE

The compiler will not complain about this syntax, but will 
ignore anything after the first colon.  The resulting 
composite TYPE has only one SLONG, and any reference to the 
.y or .z members will cause an error.

Some of the errors flagged by CheckDec are errors of form 
only, and do not actually result in compiler or runtime 
errors.


Three kinds of declarations are allowed in a DEC file, in 
any order:

TYPE Declaration
Global Constant Declaration
Function Declaration

In addition, CheckDec allows IMPORT statements in a DEC 
file, so that a file that depends on declarations in another 
file will be processed correctly.  Because neither XBLite 
nor XBasic allow a DEC file to IMPORT a file, IMPORT 
statements can be commented out, and will still be processed 
by CheckDec.

Example:  Suppose file2.dec uses a type that is declared in 
file1.dec. Syntax checking on file2.dec alone will result in 
an "Undeclared type" error. But if file2.dec contains the 
line

'IMPORT "file1"
or
'IMPORT "file1.dec"

then file1.dec will be automatically loaded and processed, 
the required type declaration will be recorded, and the 
Undeclared type error will not occur. Note that any errors 
in file1.dec will not be reported using this method. To 
process the two files, with error reporting for both, list 
both on the command line:

 checkdec file1 file2

