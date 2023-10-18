February 2004

****************************************
***** Read This About XBLite Demos *****
****************************************

All demo programs have their executable files
copied to the \xblite\programs\ directory.
All the demos can be run from that directory.

All XBLite demonstration programs require
xbl.dll to be in the same directory as
the executable program, or in a directory 
in the current environment PATH. If xbl.dll
cannot be found, it will cause the program
to fail.

The runtime xbl.dll for XBLite is NOT compatible
with xb.dll runtime library for XBasic.

It may be more convenient to copy xbl.dll
into your \windows or \winnt directory.

To save disk space, the sample programs do
not have either xbl.dll, xsx.dll, xio.dll, 
or xma.dll in their directories. 

The standard batch file in each
demo directory will copy the executable to
the c:\xblite\programs\ directory where it
can be run.

Also note that some of the programs have 
file dependencies that are hard coded to 
the exact installation of XBLite into the
c:\xblite\demo\ directory. If you did not
extract the zip file into this arrangement,
then some of the demo programs will not work
correctly from the \programs directory. In this
case, just copy xbl.dll to the demo's directory
and run the program from there.

