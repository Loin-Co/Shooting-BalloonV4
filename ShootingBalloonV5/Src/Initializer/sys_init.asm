; ============================================================================
; sys_init.asm - System Initialization
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
PUBLIC InitConsole
PUBLIC InitAudio
PUBLIC InitMemory

; ============================================================================
; DATA SECTION
; ============================================================================
.data
    szConsoleTitle db "IT: Welcome to Derry 2025 - The 8086 Arcade Edition", 0

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; InitConsole - Initialize console window
; ============================================================================
InitConsole PROC
    LOCAL hConsole:DWORD
    LOCAL consoleMode:DWORD
    
    ; Get console handle
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hConsole, eax
    
    ; Set console title
    invoke SetConsoleTitle, ADDR szConsoleTitle
    
    ; Disable cursor
    ; (Would set CONSOLE_CURSOR_INFO here)
    
    ; Set console mode to disable mouse input, etc.
    invoke GetConsoleMode, hConsole, ADDR consoleMode
    and consoleMode, NOT ENABLE_MOUSE_INPUT
    invoke SetConsoleMode, hConsole, consoleMode
    
    ret
InitConsole ENDP

; ============================================================================
; InitAudio - Initialize audio system
; ============================================================================
InitAudio PROC
    ; Placeholder - would initialize sound system
    ; For now, just return success
    ret
InitAudio ENDP

; ============================================================================
; InitMemory - Initialize memory pools
; ============================================================================
InitMemory PROC
    ; Placeholder - would allocate memory pools for entities
    ; For now, just return success
    ret
InitMemory ENDP

end
