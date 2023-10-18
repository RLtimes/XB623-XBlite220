; ##############################
; #####  XxxSwapMemory ()  #####
; ##############################

.code

_XxxSwapMemory@12:
	push	ebp												; standard function entry
	mov	ebp,esp											; ditto
	push esi,edi,ebx								; ditto
	mov	esi,[ebp+16]								; esi = length
	call	%____malloc								; allocate intermediate memory
	push	esi												; esi = addrx = intermediate memory
	mov	edi,esi											; edi = addrx = destination
	mov	esi,[ebp+8]									; esi = addr1 = source
	mov	ecx,[ebp+16]								; ecx = length
	call	%_assignComposite
	mov	edi,[ebp+8]									; edi = addr1 = destination
	mov	esi,[ebp+12]								; esi = addr2 = source
	mov	ecx,[ebp+16]								; ecx = length
	call	%_assignComposite
	mov	edi,[ebp+12]								; edi = addr2 = destination
	pop	esi													; esi = addrx = source
	mov	ecx,[ebp+16]								; ecx = length
	call	%_assignComposite
	pop	ebx,edi,esi									; standard function exit
	leave														; ditto
	ret	12													; ditto (remove arguments - STDCALL)


; #################
; #####  END  #####
; #################
