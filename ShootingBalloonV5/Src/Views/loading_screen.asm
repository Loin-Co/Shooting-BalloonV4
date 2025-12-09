; ============================================================================
; loading_screen.asm - DERRY MAINFRAME Loading Screen
; Dynamic loading with system messages and progress bar
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

PUBLIC ShowLoadingScreen
PUBLIC UpdateLoadingProgress

.data
    ; Header
    szHeader1       db ">_ DERRY MAINFRAME - v1958",0
    szHeader2       db "[ SYSTEM ]",0
    
    ; Welcome message
    szWelcome       db "W E L C O M E   T O   D E R R Y   2 0 2 5",0
    
    ; Protocol message
    szProtocol      db "[  BALLOON  SHOOTER  PROTOCOL  INITIATED  ]",0
    
    ; Loading messages
    szLoadMsg1      db "> Loading Memory Modules...  OK",0
    szLoadMsg2      db "> Checking Fear Sensors...   WARNING: HIGH LEVELS",0
    szLoadMsg3      db "> Pennywise AI...            ACTIVE",0
    szLoadMsg4      db "> Loading Render.asm...      OK",0
    
    ; Loading resources section
    szLoadRes       db "LOADING RESOURCES:",0
    
    ; Progress bar
    szProgressStart db "[",0
    szProgressEnd   db "]",0
    
    ; Quote
    szQuote         db '"They all float down here..."',0
    
    ; Formatting
    szPercentFmt    db " %d%%",0
    szPercentBuf    db 8 dup(0)

    dwLoadProgress  dd 0
    dwLoadStage     dd 0

.code

ShowLoadingScreen PROC uses ebx esi edi
    LOCAL i:DWORD
    LOCAL barPos:DWORD
    LOCAL percent:DWORD
    
    mov dwLoadProgress, 0
    mov dwLoadStage, 0

    ; Clear screen and draw border
    call ClearScreen
    call DrawLoadingBorder

    ; Draw header
    invoke DrawString, 2, 2, THEME_TEXT_MAIN, OFFSET szHeader1
    invoke DrawString, 56, 2, THEME_TEXT_MAIN, OFFSET szHeader2
    call PresentFrame
    invoke Sleep, 300

    ; Draw welcome message (centered around line 6)
    invoke DrawString, 18, 6, THEME_TEXT_ACCENT, OFFSET szWelcome
    call PresentFrame
    invoke Sleep, 400

    ; Draw protocol message (centered around line 8)
    invoke DrawString, 14, 8, THEME_TEXT_MAIN, OFFSET szProtocol
    call PresentFrame
    invoke Sleep, 600

    ; Draw loading messages one by one
    invoke DrawString, 6, 12, THEME_TEXT_MAIN, OFFSET szLoadMsg1
    call PresentFrame
    invoke Sleep, 300

    invoke DrawString, 6, 13, THEME_TEXT_MAIN, OFFSET szLoadMsg2
    call PresentFrame
    invoke Sleep, 300

    invoke DrawString, 6, 14, THEME_TEXT_MAIN, OFFSET szLoadMsg3
    call PresentFrame
    invoke Sleep, 300

    invoke DrawString, 6, 15, THEME_TEXT_MAIN, OFFSET szLoadMsg4
    call PresentFrame
    invoke Sleep, 400

    ; Draw "LOADING RESOURCES:" label
    invoke DrawString, 6, 18, THEME_TEXT_MAIN, OFFSET szLoadRes
    call PresentFrame
    invoke Sleep, 200

    ; Draw progress bar opening bracket
    invoke DrawString, 6, 20, THEME_TEXT_MAIN, OFFSET szProgressStart
    
    ; Animate progress bar (60 characters wide)
    mov i, 0
    mov barPos, 7  ; Start position after "["
    
@@ProgressLoop:
    mov eax, i
    cmp eax, 60
    jge @@ProgressDone
    
    ; Calculate percentage: (i * 100) / 60
    mov eax, i
    imul eax, 100
    xor edx, edx
    mov ecx, 60
    div ecx
    mov percent, eax
    
    ; Determine which character to use based on position
    mov eax, i
    cmp eax, 40  ; First 40 chars are filled (lighter blocks)
    jl @@FilledBlock
    
    ; Darker/dotted blocks for remaining portion (unfilled)
    invoke DrawChar, barPos, 20, DARKGRAY, 176  ; Light dotted block
    jmp @@ShowPercent
    
@@FilledBlock:
    invoke DrawChar, barPos, 20, THEME_TEXT_MAIN, 178  ; Medium block
    
@@ShowPercent:
    ; Format and display percentage
    invoke wsprintfA, ADDR szPercentBuf, ADDR szPercentFmt, percent
    invoke DrawString, 68, 20, THEME_TEXT_ACCENT, ADDR szPercentBuf
    call PresentFrame
    
    inc barPos
    inc i
    invoke Sleep, 25  ; Animation speed
    jmp @@ProgressLoop

@@ProgressDone:
    ; Draw closing bracket
    invoke DrawString, 67, 20, THEME_TEXT_MAIN, OFFSET szProgressEnd
    
    ; Show final 100%
    invoke wsprintfA, ADDR szPercentBuf, ADDR szPercentFmt, 100
    invoke DrawString, 68, 20, THEME_TEXT_ACCENT, ADDR szPercentBuf
    call PresentFrame
    invoke Sleep, 300

    ; Show Pennywise quote
    invoke DrawString, 6, 22, THEME_TEXT_ACCENT, OFFSET szQuote
    call PresentFrame
    invoke Sleep, 1200

    ; Transition to main menu
    mov g_GameState, STATE_MENU
    ret
ShowLoadingScreen ENDP

; Draw ASCII border
DrawLoadingBorder PROC
    LOCAL x:DWORD
    LOCAL y:DWORD

    ; Top-left corner
    invoke DrawChar, 1, 1, THEME_BORDER, 218
    
    ; Top edge
    mov x, 2
@@TopLoop:
    mov eax, x
    cmp eax, 78
    jge @@TopDone
    invoke DrawChar, x, 1, THEME_BORDER, 196
    inc x
    jmp @@TopLoop
@@TopDone:
    
    ; Top-right corner
    invoke DrawChar, 78, 1, THEME_BORDER, 191
    
    ; Side edges
    mov y, 2
@@SideLoop:
    mov eax, y
    cmp eax, 27
    jge @@SideDone
    invoke DrawChar, 1, y, THEME_BORDER, 179
    invoke DrawChar, 78, y, THEME_BORDER, 179
    inc y
    jmp @@SideLoop
@@SideDone:
    
    ; Bottom-left corner
    invoke DrawChar, 1, 27, THEME_BORDER, 192
    
    ; Bottom edge
    mov x, 2
@@BottomLoop:
    mov eax, x
    cmp eax, 78
    jge @@BottomDone
    invoke DrawChar, x, 27, THEME_BORDER, 196
    inc x
    jmp @@BottomLoop
@@BottomDone:
    
    ; Bottom-right corner
    invoke DrawChar, 78, 27, THEME_BORDER, 217
    
    ret
DrawLoadingBorder ENDP

; UpdateLoadingProgress (external API)
UpdateLoadingProgress PROC dwProgress:DWORD
    mov eax, dwProgress
    cmp eax, 100
    jle @@ValidProgress
    mov eax, 100
@@ValidProgress:
    mov dwLoadProgress, eax
    ret
UpdateLoadingProgress ENDP

end