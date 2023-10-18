@echo off

del *.obj
del *.o

SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include

REM *************************************
REM * Build the xball static library    *
REM * (Too buggy to use for the moment) *
REM *************************************

REM del c:\xblite\include\xball.dec
REM type c:\xblite\include\xst.dec >> c:\xblite\include\xball.dec
REM type c:\xblite\include\xcm.dec >> c:\xblite\include\xball.dec
REM type c:\xblite\include\xio.dec >> c:\xblite\include\xball.dec
REM type c:\xblite\include\xma.dec >> c:\xblite\include\xball.dec
REM type c:\xblite\include\xsx.dec >> c:\xblite\include\xball.dec

REM copy c:\xblite\src\xbdll\xst.x xst.x
REM copy c:\xblite\src\xbdll\lib\xlib.asm xlib.asm
REM xblite xst.x -lib -bat -rcf -mak
REM if errorlevel 1 goto error
REM goasm xst.asm
REM if errorlevel 1 goto error
REM goasm xlib.asm
REM if errorlevel 1 goto error
REM del xst.x

REM copy c:\xblite\src\xcm\xcm.x xcm.x
REM xblite xcm.x -lib -nodllmain -bat -rcf -mak
REM if errorlevel 1 goto error
REM goasm xcm.asm
REM if errorlevel 1 goto error
REM del xcm.x

REM copy c:\xblite\src\xio\xio.x xio.x
REM xblite xio.x -lib -nodllmain -bat -rcf -mak
REM if errorlevel 1 goto error
REM goasm xio.asm
REM if errorlevel 1 goto error
REM del xio.x

REM copy c:\xblite\src\xma\xma.x xma.x
REM copy c:\xblite\src\xma\xmalib.asm xmalib.asm
REM xblite xma.x -lib -nodllmain -bat -rcf -mak
REM if errorlevel 1 goto error
REM goasm xma.asm
REM if errorlevel 1 goto error
REM goasm xmalib.asm
REM if errorlevel 1 goto error
REM del xma.x

REM copy c:\xblite\src\xsx\xsx.x xsx.x
REM xblite xsx.x -lib -nodllmain -bat -rcf -mak
REM if errorlevel 1 goto error
REM goasm xsx.asm
REM if errorlevel 1 goto error
REM del xsx.x

REM polib *.obj /out:xball.lib
REM if errorlevel 1 goto error

REM copy xball.lib c:\xblite\lib\xball.lib

REM del *.obj

REM ******************************
REM * A special case - XFORMAT.x *
REM ******************************

xblite xformat.x -lib -nodllmain -bat -rcf -mak
if errorlevel 1 goto error
goasm xformat.asm
if errorlevel 1 goto error


REM ***************************************
REM * The below are still in Spasm syntax *
REM ***************************************

spasm int_double.s
if errorlevel 1 goto error

spasm int_longdouble.s
if errorlevel 1 goto error

spasm fix_single.s
if errorlevel 1 goto error

spasm fix_longdouble.s
if errorlevel 1 goto error

spasm fix_double.s
if errorlevel 1 goto error

spasm rpower_double.s
if errorlevel 1 goto error

spasm rpower_single.s
if errorlevel 1 goto error

spasm rpower_giant.s
if errorlevel 1 goto error

spasm rpower_ulong.s
if errorlevel 1 goto error

spasm rpower_s_x_long.s
if errorlevel 1 goto error

spasm power_double.s
if errorlevel 1 goto error

spasm power_single.s
if errorlevel 1 goto error

spasm power_giant.s
if errorlevel 1 goto error

spasm power_ulong.s
if errorlevel 1 goto error

spasm power.s
if errorlevel 1 goto error

spasm div_DCOMPLEX.s
if errorlevel 1 goto error

spasm div_SCOMPLEX.s
if errorlevel 1 goto error

spasm mul_DCOMPLEX.s
if errorlevel 1 goto error

spasm mul_SCOMPLEX.s
if errorlevel 1 goto error

spasm sub_DCOMPLEX.s
if errorlevel 1 goto error

spasm sub_SCOMPLEX.s
if errorlevel 1 goto error

spasm add_DCOMPLEX.s
if errorlevel 1 goto error

spasm add_SCOMPLEX.s
if errorlevel 1 goto error

spasm dshift_giant.s
if errorlevel 1 goto error

spasm rshift_giant.s
if errorlevel 1 goto error

spasm l_u_shift_giant.s
if errorlevel 1 goto error

spasm mod_giant.s
if errorlevel 1 goto error

spasm div_giant.s
if errorlevel 1 goto error

spasm mul_giant.s
if errorlevel 1 goto error

spasm error_d.s
if errorlevel 1 goto error

spasm oct_msd_64.s
if errorlevel 1 goto error

spasm oct_lsd_64.s
if errorlevel 1 goto error

spasm oct_first.s
if errorlevel 1 goto error

spasm oct_shift.s
if errorlevel 1 goto error

spasm oct_dword.s
if errorlevel 1 goto error

spasm sn_save.s
if errorlevel 1 goto error

spasm hex_digits.s
if errorlevel 1 goto error

spasm hex_dword.s
if errorlevel 1 goto error

spasm bin_dword.s
if errorlevel 1 goto error

spasm cvt32.s
if errorlevel 1 goto error

spasm octo_d.s
if errorlevel 1 goto error

spasm octo_d_giant.s
if errorlevel 1 goto error

spasm oct_d.s
if errorlevel 1 goto error

spasm oct_d_giant.s
if errorlevel 1 goto error

spasm hexx_d.s
if errorlevel 1 goto error

spasm hexx_d_giant.s
if errorlevel 1 goto error

spasm hex.s
if errorlevel 1 goto error

spasm hex_d_giant.s
if errorlevel 1 goto error

spasm trim_d.s
if errorlevel 1 goto error

spasm rtrim_d.s
if errorlevel 1 goto error

spasm ltrim_d.s
if errorlevel 1 goto error

spasm stuff_d.s
if errorlevel 1 goto error

spasm mid_d.s
if errorlevel 1 goto error

spasm right_d.s
if errorlevel 1 goto error

spasm left_d.s
if errorlevel 1 goto error

spasm rclip_d.s
if errorlevel 1 goto error

spasm lclip_d.s
if errorlevel 1 goto error

spasm rjust_d.s
if errorlevel 1 goto error

spasm ljust_d.s
if errorlevel 1 goto error

spasm cjust_d.s
if errorlevel 1 goto error

spasm chr_d.s
if errorlevel 1 goto error

spasm binb_d.s
if errorlevel 1 goto error

spasm binb_d_giant.s
if errorlevel 1 goto error

spasm bin_d.s
if errorlevel 1 goto error

spasm bin_d_giant.s
if errorlevel 1 goto error

spasm abs.s
if errorlevel 1 goto error

spasm csize_d.s
if errorlevel 1 goto error

spasm uctolc.s
if errorlevel 1 goto error

spasm lctouc.s
if errorlevel 1 goto error

spasm lcase_ucase_d.s
if errorlevel 1 goto error

spasm pof.s
if errorlevel 1 goto error

spasm lof.s
if errorlevel 1 goto error

spasm eof.s
if errorlevel 1 goto error

spasm close.s
if errorlevel 1 goto error

spasm width_table.s
if errorlevel 1 goto error

spasm make_3arg.s
if errorlevel 1 goto error

spasm make_2arg.s
if errorlevel 1 goto error

spasm extu_3arg.s
if errorlevel 1 goto error

spasm extu_2arg.s
if errorlevel 1 goto error

spasm ext_3arg.s
if errorlevel 1 goto error

spasm ext_2arg.s
if errorlevel 1 goto error

spasm set_3arg.s
if errorlevel 1 goto error

spasm set_2arg.s
if errorlevel 1 goto error

spasm null_d.s
if errorlevel 1 goto error

spasm space_d.s
if errorlevel 1 goto error

spasm cstring_d.s
if errorlevel 1 goto error

spasm csize.s
if errorlevel 1 goto error

spasm clr_2arg.s
if errorlevel 1 goto error

spasm clr_3arg.s
if errorlevel 1 goto error

spasm int_single.s
if errorlevel 1 goto error

spasm high01_giant.s
if errorlevel 1 goto error

spasm high01.s
if errorlevel 1 goto error

spasm rinstri.s
if errorlevel 1 goto error

spasm rinstr.s
if errorlevel 1 goto error

spasm instri.s
if errorlevel 1 goto error

spasm instr.s
if errorlevel 1 goto error

spasm rinchri.s
if errorlevel 1 goto error

spasm rinchr.s
if errorlevel 1 goto error

spasm inchri.s
if errorlevel 1 goto error

spasm search_tab.s
if errorlevel 1 goto error

spasm inchr.s
if errorlevel 1 goto error

spasm inline_d.s
if errorlevel 1 goto error

spasm infile.s
if errorlevel 1 goto error

spasm min_longdouble.s
if errorlevel 1 goto error

spasm min_double.s
if errorlevel 1 goto error

spasm min_single.s
if errorlevel 1 goto error

spasm min_ulong.s
if errorlevel 1 goto error

spasm min_slong_xlong.s
if errorlevel 1 goto error

spasm max_longdouble.s
if errorlevel 1 goto error

spasm max_double.s
if errorlevel 1 goto error

spasm max_single.s
if errorlevel 1 goto error

spasm max_ulong.s
if errorlevel 1 goto error

spasm max_slong_ulong.s
if errorlevel 1 goto error

spasm open.s
if errorlevel 1 goto error

spasm seek.s
if errorlevel 1 goto error

spasm shell.s
if errorlevel 1 goto error

spasm str_d_double.s
if errorlevel 1 goto error

spasm float_string.s
if errorlevel 1 goto error

spasm str_d_single.s
if errorlevel 1 goto error

spasm giant_decimal.s
if errorlevel 1 goto error

spasm str_d_giant.s
if errorlevel 1 goto error

spasm str_d.s
if errorlevel 1 goto error

spasm string_longdouble.s
if errorlevel 1 goto error

spasm string_d_double.s
if errorlevel 1 goto error

spasm string_d_single.s
if errorlevel 1 goto error

spasm string_giant.s
if errorlevel 1 goto error

spasm string.s
if errorlevel 1 goto error

spasm str_ulong_x.s
if errorlevel 1 goto error

spasm signed_d_longdouble.s
if errorlevel 1 goto error

spasm signed_d_double.s
if errorlevel 1 goto error

spasm signed_d_single.s
if errorlevel 1 goto error

spasm signed_d_giant.s
if errorlevel 1 goto error

spasm signed_d.s
if errorlevel 1 goto error

spasm type_convert.s
if errorlevel 1 goto error

spasm sign_longdouble.s
if errorlevel 1 goto error

spasm sgn_longdouble.s
if errorlevel 1 goto error



REM ********************************************
REM * The below are already converted to GoAsm *
REM ********************************************

REM GoAsm recalloc.asm
REM if errorlevel 1 goto error

REM GoAsm recalloc.asm
REM if errorlevel 1 goto error

REM GoAsm ZeroMemory.asm
REM if errorlevel 1 goto error

REM GoAsm xxxTerminate.asm
REM if errorlevel 1 goto error

REM GoAsm xxxExceptions.asm
REM if errorlevel 1 goto error

REM GoAsm initialize.asm
REM if errorlevel 1 goto error

GoAsm power@16.asm
if errorlevel 1 goto error

GoAsm write.asm
if errorlevel 1 goto error

GoAsm str_d_longdouble.asm
if errorlevel 1 goto error

GoAsm asc.asm
if errorlevel 1 goto error

GoAsm control_bits.asm
if errorlevel 1 goto error

GoAsm softbreak.asm
if errorlevel 1 goto error

GoAsm read_array_string.asm
if errorlevel 1 goto error

GoAsm write_array_string.asm
if errorlevel 1 goto error

GoAsm quit.asm
if errorlevel 1 goto error

GoAsm read.asm
if errorlevel 1 goto error

GoAsm round_single.asm
if errorlevel 1 goto error

GoAsm round_longdouble.asm
if errorlevel 1 goto error

GoAsm round_double.asm
if errorlevel 1 goto error

GoAsm roundne_single.asm
if errorlevel 1 goto error

GoAsm roundne_longdouble.asm
if errorlevel 1 goto error

GoAsm roundne_double.asm
if errorlevel 1 goto error

GoAsm ceil_single.asm
if errorlevel 1 goto error

GoAsm ceil_longdouble.asm
if errorlevel 1 goto error

GoAsm ceil_double.asm
if errorlevel 1 goto error



REM ********************
REM * Make the library *
REM ********************

polib *.obj *.o /out:xblib.lib
if errorlevel 1 goto error

copy xblib.lib c:\xblite\lib\xblib.lib

echo Library completed
goto finished

:error
echo Error making Library
goto end

:finished
del *.obj
del *.o

:end

pause