; ============================================================================
; player.asm - Player Logic
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include user32.inc

includelib user32.lib

include common.inc
include protos.inc

; ============================================================================
; EXTERNAL REFERENCES
; ============================================================================
EXTERN g_PlayerX:DWORD

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC UpdateArcherPosition
PUBLIC HandleShooting

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; UpdateArcherPosition - Update player position based on input
; ============================================================================
UpdateArcherPosition PROC
    ; Check LEFT arrow
    invoke GetAsyncKeyState, VK_LEFT
    test eax, 8000h
    jz UpdateArcher_CheckRight
    
    ; Move left
    mov eax, g_PlayerX
    cmp eax, 1
    jle UpdateArcher_CheckRight
    dec eax
    mov g_PlayerX, eax
    
UpdateArcher_CheckRight:
    ; Check RIGHT arrow
    invoke GetAsyncKeyState, VK_RIGHT
    test eax, 8000h
    jz UpdateArcher_Exit
    
    ; Move right
    mov eax, g_PlayerX
    cmp eax, SCREEN_WIDTH - 2
    jge UpdateArcher_Exit
    inc eax
    mov g_PlayerX, eax
    
UpdateArcher_Exit:
    ret
UpdateArcherPosition ENDP

; ============================================================================
; HandleShooting - Process shooting input
; ============================================================================
HandleShooting PROC
    ; Check SPACE key for shooting
    invoke GetAsyncKeyState, VK_SPACE
    test eax, 8000h
    jz HandleShooting_Exit
    
    ; TODO: Create new arrow at player position
    ; For now, just a placeholder
    
HandleShooting_Exit:
    ret
HandleShooting ENDP

end
