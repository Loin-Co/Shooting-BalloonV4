; Minimal kernel32 prototypes for MASM
IFNDEF __LOCAL_KERNEL32_INC__
__LOCAL_KERNEL32_INC__ EQU 1

; Function prototypes
ExitProcess PROTO :DWORD
GetTickCount PROTO
Sleep PROTO :DWORD
SetConsoleTextAttribute PROTO :DWORD, :WORD
GetStdHandle PROTO :DWORD
SetConsoleScreenBufferSize PROTO :DWORD, :DWORD
WriteConsoleOutputA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
SetConsoleTitleA PROTO :DWORD
GetConsoleMode PROTO :DWORD, :DWORD
SetConsoleMode PROTO :DWORD, :DWORD

; Aliases
SetConsoleTitle EQU <SetConsoleTitleA>
WriteConsoleOutput EQU <WriteConsoleOutputA>

ENDIF
