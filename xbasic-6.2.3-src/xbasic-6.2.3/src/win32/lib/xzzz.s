.text
.align	8
.globl	%etext
.globl	_XxxEndText
%etext:
_XxxEndText:
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
;
.data
.align	8
.globl	%edata
.globl	_XxxEndData
%edata:
_XxxEndData:
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
;
.bss
.align	8
.comm	%ebss, 8
.comm	_XxxEndBss, 8
