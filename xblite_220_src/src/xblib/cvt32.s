.text
; *******************
; *****  cvt32  *****  converts a ULONG to hex, binary, or octal
; *******************  internal common entry point
;
; in:	arg2 = minimum number of digits
;	arg1 = number to convert
;	arg0 is ignored
;	[ebp-8] = two-byte string to prepend: 0x7830 = \"0x\"
;					      0x6F30 = \"0o\"
;					      0x6230 = \"0b\"
;					      0      = prepend nothing
;	[ebp-12] -> subroutine to call to generate digits (hex.dword,
;		    bin.dword, or oct.dword)
;
; out:	eax -> string containing ASCII representation of number
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to return
;	[ebp-8] = two-byte string to prepend or zero to prepend nothing
;	[ebp-12] -> subroutine to call to generate digits (hex.dword,
;		    bin.dword, or oct.dword)
;
; IMPORTANT: cvt32 assumes that its local stack frame has already been
; set up, but it frees the stack frame itself before exiting.  This permits
; cvt32's caller to set up [ebp-8] on entry, and then to simply jump
; to cvt32 rather than call, ax the local frame, and return.
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
; If value to convert is zero, nothing (except the prepended string)
; will be stored in the result string: i.e. no \"0\" will be written.
;
.globl cvt32
cvt32:
mov	esi,70             ;get 70 bytes for string (more than necessary)
call	%____calloc        ;esi -> string that will contain result
mov	[ebp-4],esi        ;save it
mov	eax,0              ;eax = system/user bit
cld
or	eax,0x80130001       ;info word indicates: allocated string
mov	[esi-4],eax        ;store info word
mov	edi,esi            ;edi -> result string
mov	eax,[ebp-8]        ;eax = string to prepend
or	eax,eax              ;nothing to prepend?
jz	short cvt32_convert  ;yes
stosw                   ;no: write prefix at beginning of string
cvt32_convert:
mov	edx,[ebp+12]       ;edx = value to convert
mov	esi,[ebp+16]       ;esi = minimum number of digits to output
call	[ebp-12]           ;generate ASCII representation of edx
                        ;edi -> char after last char
cvt32_exit:
mov	eax,[ebp-4]        ;eax -> result string
sub	edi,eax            ;edi = length of result string
mov	[eax-8],edi        ;store length of result string
ret
