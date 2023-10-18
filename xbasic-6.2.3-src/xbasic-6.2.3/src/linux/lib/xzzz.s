#####################################################################
# Created from /xb/lib/xzzz.s using unspas.pl V0.57(September 10, 1995)
#####################################################################

.text
.align	8
.globl	_etext
_etext:
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
#
.data
.align	8
.globl	_edata
_edata:
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
#
.bss
.align	8
.comm	_ebss, 8
