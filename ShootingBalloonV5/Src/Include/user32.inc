; Minimal user32 prototypes for MASM
IFNDEF __LOCAL_USER32_INC__
__LOCAL_USER32_INC__ EQU 1

; Function prototypes
GetAsyncKeyState PROTO :DWORD
wsprintfA PROTO C :DWORD, :DWORD, :VARARG
wsprintf EQU <wsprintfA>

ENDIF
