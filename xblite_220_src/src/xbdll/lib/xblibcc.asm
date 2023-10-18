
; #########################
; #####  xblibcc.asm  #####  Clone and concatenate routines
; #########################

.code

; ************************
; *****  %_clone.a1  *****  clones object pointed to by eax
; ************************

; in:	ebx -> object to clone
; out:	ebx -> cloned object

; Destroys: esi, edi.

; Returns 0 in ebx if ebx was 0 on entry or if size of object to clone is 0.

; %_clone.a1 is the same as %_clone.a0, except that its input and output
; values are in ebx, not eax.

%_clone.a1:
	push	edx
	xchg	eax,ebx
	call	%_clone.a0
	xchg	eax,ebx										; isn't this silly?
	pop	edx
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.vv  ***** concatenates two permanent
; ********************************************** variables

; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a0.plus.a1.vv:
%_concat.string.a0.eq.a0.plus.a1.vv:
	push	eax
	push	ebx
	push	0													; "vv" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.vs  ***** concatenates permanent and
; ********************************************** temporary variable

; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a0.plus.a1.vs:
%_concat.string.a0.eq.a0.plus.a1.vs:
	push	eax
	push	ebx
	push	2													; "vs" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.sv  ***** concatenates temporary and
; ********************************************** permanent variable

; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a0.plus.a1.sv:
%_concat.string.a0.eq.a0.plus.a1.sv:
	push	eax
	push	ebx
	push	4													; "sv" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.ss  ***** concatenates two temporary
; ********************************************** variables

; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a0.plus.a1.ss:
%_concat.string.a0.eq.a0.plus.a1.ss:
	push	eax
	push	ebx
	push	6													; "ss" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.vv  ***** concatenates two permanent
; ********************************************** variables

; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a1.plus.a0.vv:
%_concat.string.a0.eq.a1.plus.a0.vv:
	push	ebx
	push	eax
	push	0													; "vv" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.vs  ***** concatenates permanent and
; ********************************************** temporary variable

; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a1.plus.a0.vs:
%_concat.string.a0.eq.a1.plus.a0.vs:
	push	ebx
	push	eax
	push	2													; "vs" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.sv  ***** concatenates temporary and
; ********************************************** permanent variable

; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a1.plus.a0.sv:
%_concat.string.a0.eq.a1.plus.a0.sv:
	push	ebx
	push	eax
	push	4													; "sv" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.ss  ***** concatenates two temporary
; ********************************************** variables

; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string

; Destroys: ebx, ecx, edx, esi, edi.

%_concat.ubyte.a0.eq.a1.plus.a0.ss:
%_concat.string.a0.eq.a1.plus.a0.ss:
	push	ebx
	push	eax
	push	6													; "ss" marker
	call	main.concat								; eax -> new string
	add	esp,12
	ret


; *************************
; *****  main.concat  *****  main string concatenator
; *************************

; #######################################
; ###########  July 15, 1994  ###########
; #####  APPEARS TO HAVE A PROBLEM  #####
; #####  If a1 string has a header  #####
; #####  that has zero elements, a  #####
; #####  memory allocation problem  #####
; #####  occurs after concatenate!  #####
; #####  try: "gonzo$ = a0$ + a1$"  #####
; #######################################
; #######################################


; in:	arg2 -> string a0
; 		arg1 -> string a1
;			arg0 -> index corresponding to entry point (see chart below)
; out:	eax -> new string, consisting of string a1 appended to string a0

; Destroys: ebx, ecx, edx, esi, edi.

; Local variables:
;	[ebp-4] = size of a0
;	[ebp-8] = size of a1
;	[ebp-12] = index into jump table
;	[ebp-16] = return value
;	[ebp-20] = LEN(a0) + LEN(a1)   (not counting null terminator)

; The returned string is always allocated in dynamic memory.  The
; input strings are both assumed to have a # of bytes per element of 1,
; so that there's no need to perform a multiply to determine the size
; of a string.

; For efficiency, i.e. to prevent unnecessary string copying and realloc'ing,
; there are four entry points, each one's label having one of the following
; suffixes:

;     Suffix	Meaning					  Index
;	vv	a0 is a variable,   a1 is a variable	    0
;	vs	a0 is a variable,   a1 is on the stack	  2
;	sv	a0 is on the stack, a1 is a variable	    4
;	ss	a0 is on the stack, a1 is on the stack	  6

; The number in the "Index" column is the number that needs to be passed
; in edx to indicate which entry point the main concatenator was called
; from.

; "On the stack" means that the string is a temporary variable, which
; holds a value that will not be referenced after the current expression
; has been evaluated.  It is the responsibility of the main concatenator
; to free temporary variables that are passed.  However, in some cases,
; e.g. when a temporary variable is concatenated with a null string, the
; most efficient action is to simply return the temporary variable
; without freeing it.

; There are seven possible results:

;	A  extended clone of a0 (a1 is copied onto end of clone of a0)
;	B  exact clone of a0
;	C  a1 (exact same pointer)
;	D  exact clone of a1
;	E  null
;	F  extension of a0 (a1 is copied onto end of a0)
;	G  a0 (exact same pointer)

; The following two tables list the conditions required for each result:

;	When a1 is non-null and a1's size > 0:

;	     a0 non-null and	a0 null or
;	     a0's size > 0	a0's size == 0
;	vv	    A		       D
;	vs	    A		       C
;	sv	    F		       D
;	ss	    F		       C

;	When a1 is null or a1's size == 0:

;	     a0 non-null and	a0 null or
;	     a0's size > 0	a0's size == 0
;	vv	    B		       E
;	vs	    B		       E
;	sv	    G		       E
;	ss	    G		       E

; The above two tables are encoded as jump addresses in concat_jump_table.
; Indexes into concat_jump_table are calculated according to the
; following formula, written in fake C:

;	a0null = (a0 == NULL || a0.size == 0)
;	a1null = (a1 == NULL || a1.size == 0)
;	jmp_index = (a1null * 8) + entry_index + a0null

; The same number is also an index into concat_free_table, a jump table
; of addresses of routines to free strings appropriately.

main.concat:
	push	ebp
	mov	ebp,esp
	sub	esp,20

	mov	edi,[ebp+12]								; edi -> string a1
	cld
	test edi,edi										; is it a null pointer?
	jz	> a1_is_null 								; yes: don't look up its length
	mov	edi,[edi-8]									; edi = length of string a1
	test edi,edi										; set ZF for coming SETZ instruction

a1_is_null:
	mov	[ebp-8],edi									; save length of string a1
	setz	dl												; dl = "a1null" variable from header comment
	shl	dl,3												; dl = "a1null * 8"

	mov	ecx,[ebp+16]								; ecx -> string a0
	test ecx,ecx										; is it a null pointer?
	jz	> a0_is_null 								; yes: don't look up its length
	mov	ecx,[ecx-8]									; ecx = length of string a0
	test ecx,ecx										; set ZF for coming SETZ instruction

a0_is_null:
	mov	[ebp-4],ecx									; save length of string a0
	setz	dh												; dh = "a0null" variable from header comment

	add	dl,dh												; dl = a0null + a1null * 4
	and	edx,0xF											; edx = a0null + a1null * 4
	add	edx,[ebp+8]									; edx = (a1null * 4) + entry_index + a0null
	;																;  = index into jump tables
	mov	[ebp-12],edx								; save index into jump tables
	cld															; make sure movs instructions go right way
	jmp	[concat_jump_table+edx*4] 	; concatenate them strings!

; ***** routines pointed to by elements of concat_jump_table
; 	on entry, edi = length of a1, ecx = length of a0
extend.clone.a0:
	add	edi,ecx											; edi = LEN(a1) + LEN(a0)
	mov	[ebp-20],edi								; save it
	mov	esi,edi											; esi = LEN(a1) + LEN(a0) = size of clone
	inc	esi													; add one for null terminator
	call	%_____malloc							; esi -> header of new block, all else destroyed
	mov	ebx,[ebp+16]								; ebx -> string a0
	mov	eax,[ebx-4]									; eax = a0's info word
	btr	eax,24											; eax = info word with system/user bit cleared
	mov	[esi+12],eax								; clone's info word = a0's info word | $$whomask
	mov	eax,[ebp-20]								; eax = LEN(a0) + LEN(a1)
	mov	[esi+8],eax									; clone's # of elements = LEN(a0) + LEN(a1)

	add	esi,16											; esi -> new string
	mov	edi,esi											; edi -> new string
	mov	eax,edi											; save pointer to new string
	mov	esi,[ebp+16]								; esi -> string a0
	mov	ecx,[ebp-4]									; ecx = LEN(a0)
	;																; edi is guaranteed to be on a 4-byte boundary
	add	ecx,3												; round ecx up to next multiple of 4
	shr	ecx,2												; ecx = # of dwords to copy
	jecxz	> ec0_copy_done
	rep movsd

ec0_copy_done:
	mov	edi,eax											; edi -> first byte of new string
	jmp	 concat.copy.a1

extend.a0:
	mov	esi,[ebp+16]								; esi -> string a0
	mov	edx,[esi-16]								; edx = size of a0's chunk, including header
	sub	edx,16											; edx = size of a0's chunk, excluding header
	add	edi,ecx											; edi = LEN(a1) + LEN(a0)
	mov	[ebp-20],edi								; save LEN(a1) + LEN(a0)
	inc	edi													; add one for null terminator
	cmp	edx,edi											; will concatenated string fit in a0?
	jae	> it_fits										; if chunk size >= size needed, then skip realloc
	call	%____realloc							; esi -> new block, all else destroyed

it_fits:
	mov	eax,[ebp-20]								; eax = LEN(a0) + LEN(a1)
	mov	[esi-8],eax									; # of elements = LEN(a0) + LEN(a1)
	mov	eax,esi											; save return value
	mov	edi,esi											; edi -> new block

concat.copy.a1:
	add	edi,[ebp-4]									; edi -> byte after last byte in a0
	mov	esi,[ebp+12]								; esi -> first byte of string a1
	mov	ecx,[ebp-8]									; ecx = # of bytes in a1

e0_byte_boundary:									; get rep movsd started on 4-byte boundary
	test	edi,1											; if bit 0 = 0 then no initial bytes to copy
	jz	> e0_word_boundary
	movsb														; copy first byte
	dec	ecx													; ecx = # of bytes left to copy
	jz	> add_terminator

e0_word_boundary:
	test	edi,2											; if bit 1 = 0 then no initial words to copy
	jz	> e0_dword_boundary
	movsw														; copy a word; now we're on dword boundary
	sub	ecx,2												; ecx = # of bytes left to copy
	jz	> add_terminator

e0_dword_boundary:
	add	ecx,3												; round ecx up to next dword boundary
	shr	ecx,2												; ecx = # of dwords to copy
	jecxz	> add_terminator					; skip if no dwords to copy
	rep movsd												; copy a1 onto end of a0!

add_terminator:
	mov	edi,eax											; edi -> new string
	add	edi,[ebp-20]								; edi -> one byte after last byte of new string
	mov	b[edi],0 										; put null terminator at end of string
	jmp	> ready.to.free 						; eax still -> new string

return.null:
	mov d[ebp-16],0									; return a null pointer
	jmp	 ready.to.free

return.a0:
	mov	eax,[ebp+16]								; eax -> string a0
	jmp	 ready.to.free							; return string a0

return.a1:
	mov	eax,[ebp+12]								; eax -> string a1
	jmp	 ready.to.free							; return string a1

clone.a0:
	mov	eax,[ebp+16]								; eax -> string a0
	call	%_clone.a0								; eax -> clone of a0
	jmp	 ready.to.free							; return clone of a0

clone.a1:
	mov	eax,[ebp+12]								; eax -> string a1
	call	%_clone.a0								; eax -> clone of a1
	jmp	 ready.to.free							; return clone of a1

; ***** finished with routine from concat_jump_table
;	on entry: eax -> string to return
ready.to.free:
	mov	[ebp-16],eax								; save return value
	mov	edx,[ebp-12]								; edx = index into jump tables
	jmp	[concat_free_table+edx*4] 	; free what needs to be freed

; ***** routines to free what needs to be freed
free.a0:
	mov	esi,[ebp+16]								; esi -> string a0
	call	%____free
	jmp	 concat.done

free.a0.a1:
	mov	esi,[ebp+16]								; esi -> string a0
	call	%____free

; fall through
free.a1:
	mov	esi,[ebp+12]								; esi -> string a1
	call	%____free
	jmp	 concat.done

; ***** finished freeing
free.nothing:
concat.done:
	mov	eax,[ebp-16]								; eax -> string to return
	leave
	ret

; *****  jump table for concatenate routines  *****

.const
align	8
concat_jump_table:
;		    a1 has string
;	a0 has string		a0 has no string
	dd	extend.clone.a0,	clone.a1	; vv
	dd	extend.clone.a0,	return.a1	; vs
	dd	extend.a0,		clone.a1			; sv
	dd	extend.a0,		return.a1			; ss

;		   a1 has no string
;	a0 has string		a0 has no string
	dd	clone.a0,		return.null			; vv
	dd	clone.a0,		return.null			; vs
	dd	return.a0,		return.null		; sv
	dd	return.a0,		return.null		; ss

align	8
concat_free_table:
;		    a1 has string
;	a0 has string		a0 has no string
	dd	free.nothing,	free.nothing	; vv
	dd	free.a1,		free.nothing		; vs
	dd	free.nothing,	free.nothing	; sv
	dd	free.a1,		free.nothing		; ss

;		   a1 has no string
;	a0 has string		a0 has no string
	dd	free.nothing,	free.nothing	; vv
	dd	free.a1,		free.a1					; vs
	dd	free.nothing,		free.a0			; sv
	dd	free.a1,		free.a0.a1			; ss

; #################
; #####  END  #####
; #################
