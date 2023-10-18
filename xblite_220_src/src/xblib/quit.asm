
.code
%_quit:
	mov eax,[esp+4]         				; status argument from QUIT()
	call _XxxTerminate@0
