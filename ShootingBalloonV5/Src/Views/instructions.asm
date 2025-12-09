; ============================================================================
; instructions.asm - Instructions Screen
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include kernel32.inc
include msvcrt.inc
include user32.inc

includelib kernel32.lib
includelib msvcrt.lib
includelib user32.lib

include common.inc
include protos.inc

PUBLIC ShowInstructions
PUBLIC ProcessInstructionsInput

.data
    szTitle db "I N S T R U C T I O N S",0
    szLines db "Arrows: Move the archer",0,13,0
    szLines2 db "Space: Shoot",0,13,0
    szLines3 db "ESC: Back to Menu",0,13,0
    szPrompt db "Press ESC to return",0

.code
ShowInstructions PROC
    call ClearScreen
    invoke DrawRect,5,4,74,20,THEME_BORDER
    invoke DrawString, 28,6,THEME_BORDER, OFFSET szTitle
    invoke DrawString, 10,9,THEME_TEXT_MAIN, OFFSET szLines
    invoke DrawString, 10,11,THEME_TEXT_MAIN, OFFSET szLines2
    invoke DrawString, 10,13,THEME_TEXT_MAIN, OFFSET szLines3
    invoke DrawString, 24,17,THEME_TEXT_ACCENT, OFFSET szPrompt
    call PresentFrame
    ret
ShowInstructions ENDP

ProcessInstructionsInput PROC
    ; Check ESC to return
    invoke GetAsyncKeyState, VK_ESCAPE
    test ax, 8000h
    jz @Stay
    mov eax, STATE_MENU
    ret
@Stay:
    mov eax, STATE_INSTRUCTIONS
    ret
ProcessInstructionsInput ENDP

end
