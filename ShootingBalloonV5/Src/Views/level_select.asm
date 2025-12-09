; ============================================================================
; level_select.asm - Level Selection Screen (moved to Views)
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

PUBLIC ShowLevelSelect
PUBLIC ProcessLevelSelectInput

.data
    szLevelTitle db "S E L E C T   Y O U R   F A T E",0
    szInstruction db "Choose your nightmare level",0
    szLevel1 db "NEIBOLT HOUSE",0
    szLevel2 db "DERRY SEWERS",0
    szLevel3 db "FUNHOUSE MAZE",0
    szLevel4 db "DEADLIGHTS",0
    szDiff1 db "EASY",0
    szDiff2 db "NORMAL",0
    szDiff3 db "HARD",0
    szDiff4 db "NIGHTMARE",0
    szDesc1 db "A good place to start...",0
    szDesc2 db "The darkness below awaits",0
    szDesc3 db "Reality bends and twists",0
    szDesc4 db "Stare into the void",0
    dwSelectedLevel dd 0
    dwMaxLevel dd 4
    bLevelUnlocked db 1,1,0,0
    dwHighScores dd 12500,8900,0,0
    szHighScore db "HIGH SCORE:",0
    szLocked db "[ LOCKED ]",0
    szControls db "LEFT/RIGHT: Select  |  ENTER: Begin  |  ESC: Back",0
    szWarning db "Fear feeds the beast...",0
    szScoreFmt db "%d",0

.code
ShowLevelSelect PROC
    call ClearScreen
    invoke DrawRect,3,2,76,22,THEME_BORDER
    invoke DrawString,23,4,THEME_BORDER,OFFSET szLevelTitle
    invoke DrawString,25,5,THEME_TEXT_MAIN,OFFSET szInstruction
    call DrawSeparator
    call DrawLevelCards
    call DrawLevelDetails
    invoke DrawString,15,20,THEME_TEXT_MAIN,OFFSET szControls
    invoke DrawString,28,21,THEME_WARNING,OFFSET szWarning
    call PresentFrame
    ret
ShowLevelSelect ENDP

; DrawSeparator
DrawSeparator PROC
    mov ecx,8
@@Lp:
    cmp ecx,72
    jge @Done
    invoke DrawChar,ecx,7,THEME_BORDER,196
    inc ecx
    jmp @@Lp
@Done:
    ret
DrawSeparator ENDP

; DrawLevelCards - Draw the 4 level selection cards
; ============================================================================
DrawLevelCards PROC
    LOCAL i:DWORD
    LOCAL xPos:DWORD
    LOCAL yPos:DWORD
    LOCAL color:DWORD
    LOCAL pLevelName:DWORD
    LOCAL pDifficulty:DWORD
    
    mov yPos, 8
    mov i, 0
    
@@CardLoop:
    mov eax, i
    cmp eax, dwMaxLevel
    jge @@Done
    
    ; Calculate X position (4 cards across)
    mov eax, i
    imul eax, 18
    add eax, 6
    mov xPos, eax
    
    ; Determine card color (selected vs normal)
    mov eax, i
    mov ebx, dwSelectedLevel
    cmp eax, ebx
    je @@SelectedColor
    mov color, THEME_TEXT_MAIN
    jmp @@ColorDone
@@SelectedColor:
    mov color, THEME_BORDER
@@ColorDone:
    
    ; Draw card border (small box)
    invoke DrawRect, xPos, yPos, xPos + 16, yPos + 6, color
    
    ; Get level name pointer
    mov eax, i
    .IF eax == 0
        lea eax, szLevel1
    .ELSEIF eax == 1
        lea eax, szLevel2
    .ELSEIF eax == 2
        lea eax, szLevel3
    .ELSE
        lea eax, szLevel4
    .ENDIF
    mov pLevelName, eax
    
    ; Get difficulty pointer
    mov eax, i
    .IF eax == 0
        lea eax, szDiff1
    .ELSEIF eax == 1
        lea eax, szDiff2
    .ELSEIF eax == 2
        lea eax, szDiff3
    .ELSE
        lea eax, szDiff4
    .ENDIF
    mov pDifficulty, eax
    
    ; Draw level number (simple digits)
    mov eax, xPos
    add eax, 7
    mov ecx, yPos
    add ecx, 1
    invoke DrawChar, eax, ecx, color, 48  ; '0'
    mov eax, i
    add eax, 1
    add eax, 48
    mov ebx, xPos
    add ebx, 8
    invoke DrawChar, ebx, ecx, color, eax
    
    ; Draw level name
    mov eax, xPos
    add eax, 2
    mov ecx, yPos
    add ecx, 3
    invoke DrawString, eax, ecx, THEME_TEXT_ACCENT, pLevelName
    
    ; Check if locked
    lea ebx, bLevelUnlocked
    mov eax, i
    add ebx, eax
    movzx eax, BYTE PTR [ebx]
    cmp eax, 0
    je @@Locked
    ; Draw difficulty
    mov eax, xPos
    add eax, 4
    mov ecx, yPos
    add ecx, 5
    invoke DrawString, eax, ecx, THEME_TEXT_MAIN, pDifficulty
    jmp @@Continue
@@Locked:
    mov eax, xPos
    add eax, 4
    mov ecx, yPos
    add ecx, 5
    invoke DrawString, eax, ecx, THEME_WARNING, OFFSET szLocked
@@Continue:
    
    inc i
    jmp @@CardLoop
    
@@Done:
    ret
DrawLevelCards ENDP

; ============================================================================
; DrawLevelDetails - Show detailed info for selected level
; ============================================================================
DrawLevelDetails PROC
    LOCAL pDesc:DWORD
    LOCAL score:DWORD
    LOCAL szScoreStr[16]:BYTE
    LOCAL isUnlocked:DWORD
    
    ; Get selected level description
    mov eax, dwSelectedLevel
    .IF eax == 0
        lea eax, szDesc1
    .ELSEIF eax == 1
        lea eax, szDesc2
    .ELSEIF eax == 2
        lea eax, szDesc3
    .ELSE
        lea eax, szDesc4
    .ENDIF
    mov pDesc, eax
    
    ; Draw description box
    invoke DrawRect, 10, 15, 70, 18, THEME_TEXT_MAIN
    
    ; Draw description text
    invoke DrawString, 25, 16, THEME_TEXT_ACCENT, pDesc
    
    ; Check if unlocked
    lea ebx, bLevelUnlocked
    mov eax, dwSelectedLevel
    add ebx, eax
    movzx eax, BYTE PTR [ebx]
    mov isUnlocked, eax
    
    cmp isUnlocked, 1
    jne @@LockedLabel
    ; Draw high score
    invoke DrawString, 27, 17, THEME_TEXT_MAIN, OFFSET szHighScore
    
    ; Get high score value
    mov eax, dwSelectedLevel
    shl eax, 2  ; multiply by 4 (DWORD size)
    lea ebx, dwHighScores
    add ebx, eax
    mov eax, [ebx]
    mov score, eax
    
    ; Format score string and draw
    lea eax, szScoreStr
    invoke wsprintfA, eax, ADDR szScoreFmt, score
    invoke DrawString, 40, 17, THEME_TEXT_ACCENT, eax
    jmp @@Done
@@LockedLabel:
    invoke DrawString, 28, 17, THEME_WARNING, OFFSET szLocked
@@Done:
    ret
DrawLevelDetails ENDP

; ============================================================================

ProcessLevelSelectInput PROC
    invoke GetAsyncKeyState, VK_LEFT
    test ax,8000h
    jz @CheckRight
    mov eax,dwSelectedLevel
    dec eax
    .IF SDWORD PTR eax < 0
        mov eax,dwMaxLevel
        dec eax
    .ENDIF
    mov dwSelectedLevel,eax
    call ShowLevelSelect
    invoke Sleep,150
    ret
@CheckRight:
    invoke GetAsyncKeyState, VK_RIGHT
    test ax,8000h
    jz @CheckEnter
    mov eax,dwSelectedLevel
    inc eax
    mov ecx,dwMaxLevel
    .IF eax >= ecx
        xor eax,eax
    .ENDIF
    mov dwSelectedLevel,eax
    call ShowLevelSelect
    invoke Sleep,150
    ret
@CheckEnter:
    invoke GetAsyncKeyState, VK_RETURN
    test ax,8000h
    jz @CheckEscape
    lea ebx,bLevelUnlocked
    mov eax,dwSelectedLevel
    add ebx,eax
    movzx eax,BYTE PTR [ebx]
    .IF eax == 1
        mov eax,STATE_PLAYING
        ret
    .ELSE
        ret
    .ENDIF
@CheckEscape:
    invoke GetAsyncKeyState, VK_ESCAPE
    test ax,8000h
    jz @Stay
    mov eax,STATE_MENU
    ret
@Stay:
    mov eax,STATE_LEVEL_SELECT
    ret
ProcessLevelSelectInput ENDP

end
