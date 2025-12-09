; ============================================================================
; input_mgr.asm - Input Manager
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib

include common.inc
include protos.inc

; ============================================================================
; EXTERNAL REFERENCES
; ============================================================================
EXTERN g_GameState:DWORD
EXTERN g_MenuIndex:DWORD

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC ReadKeys

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; ReadKeys - Poll keyboard state
; ============================================================================
ReadKeys PROC
    ; Check ESC key for exit/pause
    invoke GetAsyncKeyState, VK_ESCAPE
    test eax, 8000h
    jz ReadKeys_CheckOther
    
    ; Handle ESC based on current state
    mov eax, g_GameState
    cmp eax, STATE_PLAYING
    je ReadKeys_Pause
    
    cmp eax, STATE_MENU
    je ReadKeys_Exit
    jmp ReadKeys_CheckOther
    
ReadKeys_Pause:
    mov g_GameState, STATE_PAUSED
    jmp ReadKeys_CheckOther
    
ReadKeys_Exit:
    mov g_GameState, STATE_EXIT
    
ReadKeys_CheckOther:
    ; Additional key checks would go here
    
    ret
ReadKeys ENDP

end
