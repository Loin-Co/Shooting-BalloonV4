; ============================================================================
; render_core.asm - Double Buffered Graphics Engine
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include kernel32.inc

includelib kernel32.lib

include common.inc

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC SetupBuffer
PUBLIC PresentFrame
PUBLIC ClearScreen
PUBLIC g_ConsoleBuffer
PUBLIC g_hConsoleOut

; ============================================================================
; DATA SECTION
; ============================================================================
.data
    g_hConsoleOut   dd 0
    g_ConsoleBuffer CHAR_INFO BUFFER_SIZE dup(<>)
    
    dwBytesWritten  dd 0
    dwConsoleSize   dd (SCREEN_HEIGHT shl 16) or SCREEN_WIDTH  ; Packed COORD

    consoleSize     COORD <SCREEN_WIDTH, SCREEN_HEIGHT>
    bufferCoord     COORD <0, 0>
    writeRegion     SMALL_RECT <0, 0, SCREEN_WIDTH-1, SCREEN_HEIGHT-1>

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; SetupBuffer - Initialize the console buffer
; ============================================================================
SetupBuffer PROC
    ; Get console output handle
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov g_hConsoleOut, eax
    
    ; Set console buffer size (using packed DWORD)
    invoke SetConsoleScreenBufferSize, g_hConsoleOut, dwConsoleSize
    
    ret
SetupBuffer ENDP

; ============================================================================
; ClearScreen - Clear the buffer with theme background (OPTIMIZED)
; ============================================================================
ClearScreen PROC
    LOCAL pBuffer:DWORD
    LOCAL clearValue:DWORD
    
    ; Pre-calculate the fill value (space + black background)
    mov clearValue, ' ' or (THEME_BG shl 16)  ; Combine char and attribute
    
    lea eax, g_ConsoleBuffer
    mov pBuffer, eax
    mov ecx, BUFFER_SIZE
    mov edi, pBuffer
    mov eax, clearValue
    
    ; Fast DWORD fill using REP STOSD (4 bytes at a time)
    rep stosd
    
    ret
ClearScreen ENDP

; ============================================================================
; PresentFrame - Write buffer to console (VSync simulation)
; ============================================================================
PresentFrame PROC
    LOCAL tempCoord:DWORD
    
    ; Pack bufferCoord into a DWORD (Y << 16 | X)
    xor eax, eax
    mov tempCoord, eax
    
    invoke WriteConsoleOutputA, g_hConsoleOut, ADDR g_ConsoleBuffer, \
           dwConsoleSize, tempCoord, ADDR writeRegion
    ret
PresentFrame ENDP

end
