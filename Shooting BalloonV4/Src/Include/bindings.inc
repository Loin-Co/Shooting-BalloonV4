; ============================================================================
; bindings.inc - Manual Windows API Bindings (Zero Dependency)
; Replaces windows.inc and masm32 macros with pure definitions
; ============================================================================

; ============================= CONSTANTS ====================================
NULL                    equ 0
TRUE                    equ 1
FALSE                   equ 0

; Console Handles
STD_INPUT_HANDLE        equ -10
STD_OUTPUT_HANDLE       equ -11
STD_ERROR_HANDLE        equ -12

; Console Modes
ENABLE_PROCESSED_INPUT  equ 0001h
ENABLE_LINE_INPUT       equ 0002h
ENABLE_ECHO_INPUT       equ 0004h
ENABLE_WINDOW_INPUT     equ 0008h
ENABLE_MOUSE_INPUT      equ 0010h

; SetWindowPos flags
SWP_NOSIZE              equ 0001h
SWP_NOMOVE              equ 0002h
SWP_NOZORDER            equ 0004h
SWP_SHOWWINDOW          equ 0040h

; System Metrics
SM_CXSCREEN             equ 0
SM_CYSCREEN             equ 1

; Color Attributes
COLOR_BLACK             equ 0
COLOR_BLUE              equ 1
COLOR_GREEN             equ 2
COLOR_CYAN              equ 3
COLOR_RED               equ 4
COLOR_MAGENTA           equ 5
COLOR_YELLOW            equ 6
COLOR_WHITE             equ 7
COLOR_GRAY              equ 8
COLOR_LIGHT_BLUE        equ 9
COLOR_LIGHT_GREEN       equ 10
COLOR_LIGHT_CYAN        equ 11
COLOR_LIGHT_RED         equ 12
COLOR_LIGHT_MAGENTA     equ 13
COLOR_LIGHT_YELLOW      equ 14
COLOR_BRIGHT_WHITE      equ 15
COLOR_LIGHT_GRAY        equ 7

; Virtual Key Codes
VK_ESCAPE               equ 1Bh
VK_SPACE                equ 20h
VK_LEFT                 equ 25h
VK_UP                   equ 26h
VK_RIGHT                equ 27h
VK_DOWN                 equ 28h
VK_RETURN               equ 0Dh
VK_SHIFT                equ 10h
VK_P                    equ 50h
VK_R                    equ 52h
VK_Q                    equ 51h

; ============================= STRUCTURES ===================================

COORD STRUCT
    X   WORD ?
    Y   WORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left    WORD ?
    Top     WORD ?
    Right   WORD ?
    Bottom  WORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

CHAR_INFO STRUCT
    UnicodeChar WORD ?
    Attributes  WORD ?
CHAR_INFO ENDS

CONSOLE_CURSOR_INFO STRUCT
    dwSize      DWORD ?
    bVisible    DWORD ?
CONSOLE_CURSOR_INFO ENDS

RECT STRUCT
    left    DWORD ?
    top     DWORD ?
    right   DWORD ?
    bottom  DWORD ?
RECT ENDS

POINT STRUCT
    x DWORD ?
    y DWORD ?
POINT ENDS

; ============================= TYPE DEFINITIONS =============================
HANDLE textequ <DWORD>

; ============================= PROTOTYPES ===================================

; Kernel32.lib
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleOutputA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadConsoleInputA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD
SetConsoleCursorPosition PROTO STDCALL :DWORD, :DWORD
SetConsoleTextAttribute PROTO STDCALL :DWORD, :DWORD
FillConsoleOutputCharacterA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FillConsoleOutputAttribute PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetConsoleScreenBufferInfo PROTO STDCALL :DWORD, :DWORD
SetConsoleTitleA PROTO STDCALL :DWORD
SetConsoleCursorInfo PROTO STDCALL :DWORD, :DWORD
GetTickCount PROTO STDCALL
Sleep PROTO STDCALL :DWORD
ExitProcess PROTO STDCALL :DWORD
GetConsoleMode PROTO STDCALL :DWORD, :DWORD
SetConsoleMode PROTO STDCALL :DWORD, :DWORD

; User32.lib
GetSystemMetrics PROTO STDCALL :DWORD
GetConsoleWindow PROTO STDCALL
SetWindowPos PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ShowWindow PROTO STDCALL :DWORD, :DWORD
GetAsyncKeyState PROTO STDCALL :DWORD

; Custom implementation (replaces winmm.lib)
; timeGetTime is now implemented in utils.asm as a wrapper around GetTickCount
timeGetTime PROTO STDCALL

; GDI32.lib (if needed for advanced effects)
SetPixel PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD

