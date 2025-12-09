; Minimal Windows include for MASM
IFNDEF __LOCAL_WINDOWS_INC__
__LOCAL_WINDOWS_INC__ EQU 1

; Basic handle type
HANDLE TYPEDEF DWORD

; Minimal constants
STD_OUTPUT_HANDLE EQU -11
ENABLE_MOUSE_INPUT EQU 0010h

; Minimal structures if needed by other modules
COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS
SMALL_RECT STRUCT
    Left  SWORD ?
    Top   SWORD ?
    Right SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

ENDIF
