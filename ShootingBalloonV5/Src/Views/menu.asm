; ============================================================================
; menu.asm - Main Menu System (Views)
; Modified: simplified menu to three items and inner box layout
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

PUBLIC ShowMainMenu
PUBLIC ProcessMenuInput

.data
    szTitle db "W E L C O M E   T O   D E R R Y   2 0 2 5",0
    szSubtitle db "The 8086 Arcade Edition",0
    szMenuPlay db " START GAME ",0
    szMenuHelp db " INSTRUCTIONS ",0
    szMenuExit db " QUIT ",0
    dwMenuSelection dd 0
    dwMenuCount dd 3
    MENU_BOX_LEFT EQU 28
    MENU_BOX_TOP  EQU 10
    MENU_BOX_RIGHT EQU 52
    MENU_BOX_BOTTOM EQU 16
    MENU_ITEM_X EQU MENU_BOX_LEFT + 3
    MENU_ITEM_Y EQU MENU_BOX_TOP + 1
    ITEM_LINE_SPACING EQU 2
    szControls db "ARROWS: Move  |  ENTER: Select",0
    szFooterStats db "HIGHSCORE: 1850  |  DEATHS: 042",0

.code
ShowMainMenu PROC
    call ClearScreen
    invoke DrawRect,2,2,78,23,THEME_BORDER
    invoke DrawString,22,5,THEME_TEXT_MAIN,OFFSET szTitle
    invoke DrawString,28,7,THEME_TEXT_ACCENT,OFFSET szSubtitle
    mov esi,18
@@Sep:
    cmp esi,62
    jge @SepDone
    invoke DrawChar,esi,9,THEME_BORDER,196
    inc esi
    jmp @@Sep
@SepDone:
    invoke DrawRect,MENU_BOX_LEFT-1,MENU_BOX_TOP-1,MENU_BOX_RIGHT+1,MENU_BOX_BOTTOM+1,THEME_TEXT_MAIN
    invoke DrawRect,MENU_BOX_LEFT,MENU_BOX_TOP,MENU_BOX_RIGHT,MENU_BOX_BOTTOM,THEME_BORDER
    call DrawMenuItems
    invoke DrawString,10,19,THEME_TEXT_MAIN,OFFSET szFooterStats
    invoke DrawString,24,21,THEME_TEXT_MAIN,OFFSET szControls
    call PresentFrame
    ret
ShowMainMenu ENDP

DrawMenuItems PROC
    LOCAL yPos:DWORD
    LOCAL color:DWORD
    mov eax,MENU_ITEM_Y
    mov yPos,eax
    mov eax,dwMenuSelection
    .IF eax == 0
        mov color,THEME_BTN_HOVER
        invoke DrawChar,MENU_ITEM_X - 2,yPos,THEME_BORDER,62
    .ELSE
        mov color,THEME_BTN_NORMAL
    .ENDIF
    invoke DrawString,MENU_ITEM_X,yPos,color,OFFSET szMenuPlay
    add yPos,ITEM_LINE_SPACING
    mov eax,dwMenuSelection
    .IF eax == 1
        mov color,THEME_BTN_HOVER
        invoke DrawChar,MENU_ITEM_X - 2,yPos,THEME_BORDER,62
    .ELSE
        mov color,THEME_BTN_NORMAL
    .ENDIF
    invoke DrawString,MENU_ITEM_X,yPos,color,OFFSET szMenuHelp
    add yPos,ITEM_LINE_SPACING
    mov eax,dwMenuSelection
    .IF eax == 2
        mov color,THEME_BTN_HOVER
        invoke DrawChar,MENU_ITEM_X - 2,yPos,THEME_BORDER,62
    .ELSE
        mov color,THEME_BTN_NORMAL
    .ENDIF
    invoke DrawString,MENU_ITEM_X,yPos,color,OFFSET szMenuExit
    ret
DrawMenuItems ENDP

ProcessMenuInput PROC
    invoke GetAsyncKeyState, VK_UP
    test ax,8000h
    jz @Down
    mov eax,dwMenuSelection
    cmp eax,0
    je @Done
    dec eax
    mov dwMenuSelection,eax
    call ShowMainMenu
    invoke Sleep,120
    ret
@Down:
    invoke GetAsyncKeyState, VK_DOWN
    test ax,8000h
    jz @Enter
    mov eax,dwMenuSelection
    inc eax
    mov ecx,dwMenuCount
    cmp eax,ecx
    jl @Set
    xor eax,eax
@Set:
    mov dwMenuSelection,eax
    call ShowMainMenu
    invoke Sleep,120
    ret
@Enter:
    invoke GetAsyncKeyState, VK_RETURN
    test ax,8000h
    jz @Esc
    mov eax,dwMenuSelection
    .IF eax == 0
        mov eax,STATE_PLAYING
        ret
    .ELSEIF eax == 1
        mov eax,STATE_INSTRUCTIONS
        ret
    .ELSE
        mov eax,STATE_EXIT
        ret
    .ENDIF
@Esc:
    invoke GetAsyncKeyState, VK_ESCAPE
    test ax,8000h
    jz @Done
    mov eax,STATE_EXIT
    ret
@Done:
    mov eax,STATE_MENU
    ret
ProcessMenuInput ENDP

end
