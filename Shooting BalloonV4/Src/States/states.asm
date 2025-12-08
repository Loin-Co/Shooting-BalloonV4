; ============================================================================
; states.asm - Menu, Intro, and Game Over Rendering Procedures
; Location: Src/States/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN hStdOut:DWORD
EXTERN nextState:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC RenderSplash
PUBLIC RenderMenu
PUBLIC RenderGameOver
PUBLIC menuSelection

; ============================= DATA SECTION =================================
.data
    ; Splash screen
    splashTitle     db "IT: WELCOME TO DERRY 2025", 0
    splashLoading   db "Loading...", 0
    splashBar       db "####################", 0
    
    ; Menu screen
    menuTitle       db "THE 8086 ARCHER", 0
    menuSubtitle    db "Balloon Shooting Game", 0
    menuOption1     db "[ START GAME ]", 0
    menuOption2     db "[ QUIT ]", 0
    menuFooter      db "[UP/DOWN]: Select   [ENTER]: Confirm   [ESC]: Exit", 0
    
    ; Game Over screen
    gameOverTitle   db "Y O U   D I E D", 0
    gameOverQuote   db "YOU'LL FLOAT TOO", 0
    gameOverScore   db "YOUR SCORE: ", 0
    gameOverRetry   db "R: Retry   Q: Quit to Menu", 0
    
    PUBLIC menuSelection
    menuSelection   DWORD 0     ; 0 = Start, 1 = Quit
    splashProgress  DWORD 0
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: CenterText
; Description: Calculate X position to center text
; Parameters: string pointer
; Returns: EAX = centered X position
; ----------------------------------------------------------------------------
CenterText PROC strPtr:DWORD
    push ebx
    invoke StrLen, strPtr
    
    mov ebx, SCREEN_WIDTH
    sub ebx, eax
    shr ebx, 1
    mov eax, ebx
    
    pop ebx
    ret
CenterText ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderSplash
; Description: Render splash/loading screen
; ----------------------------------------------------------------------------
RenderSplash PROC
    LOCAL centerX:DWORD
    
    call ClearBuffer
    
    ; Render title
    invoke CenterText, ADDR splashTitle
    mov centerX, eax
    
    invoke WriteString, centerX, 10, ADDR splashTitle, COLOR_LIGHT_RED
    
    ; Render loading text
    invoke CenterText, ADDR splashLoading
    mov centerX, eax
    
    invoke WriteString, centerX, 12, ADDR splashLoading, COLOR_WHITE
    
    ; Render progress bar
    invoke CenterText, ADDR splashBar
    mov centerX, eax
    
    invoke WriteString, centerX, 14, ADDR splashBar, COLOR_LIGHT_GREEN
    
    ; Present the frame
    call PresentFrame
    
    ; Delay to simulate loading
    invoke Sleep, 1500
    
    ret
RenderSplash ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderMenu
; Description: Render main menu
; ----------------------------------------------------------------------------
RenderMenu PROC
    LOCAL centerX:DWORD
    
    call ClearBuffer
    
    ; Render title
    invoke CenterText, ADDR menuTitle
    mov centerX, eax
    
    invoke WriteString, centerX, 8, ADDR menuTitle, COLOR_MENU_TITLE
    
    ; Render subtitle
    invoke CenterText, ADDR menuSubtitle
    mov centerX, eax
    
    invoke WriteString, centerX, 10, ADDR menuSubtitle, COLOR_WHITE
    
    ; Render option 1 (Start Game)
    invoke CenterText, ADDR menuOption1
    mov centerX, eax
    
    mov eax, menuSelection
    cmp eax, 0
    je HighlightOption1
    
    invoke WriteString, centerX, 14, ADDR menuOption1, COLOR_WHITE
    jmp DoOption2
    
HighlightOption1:
    invoke WriteString, centerX, 14, ADDR menuOption1, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
DoOption2:
    ; Render option 2 (Quit)
    invoke CenterText, ADDR menuOption2
    mov centerX, eax
    
    mov eax, menuSelection
    cmp eax, 1
    je HighlightOption2
    
    invoke WriteString, centerX, 16, ADDR menuOption2, COLOR_WHITE
    jmp DoFooter
    
HighlightOption2:
    invoke WriteString, centerX, 16, ADDR menuOption2, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
DoFooter:
    ; Render footer
    invoke CenterText, ADDR menuFooter
    mov centerX, eax
    
    invoke WriteString, centerX, 24, ADDR menuFooter, COLOR_FOOTER
    
    ; Present the frame
    call PresentFrame
    
    ret
RenderMenu ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderGameOver
; Description: Render game over screen
; ----------------------------------------------------------------------------
RenderGameOver PROC
    LOCAL centerX:DWORD
    
    call ClearBuffer
    
    ; Render "YOU DIED" title
    invoke CenterText, ADDR gameOverTitle
    mov centerX, eax
    
    invoke WriteString, centerX, 10, ADDR gameOverTitle, COLOR_GAMEOVER_BG
    
    ; Render quote
    invoke CenterText, ADDR gameOverQuote
    mov centerX, eax
    
    invoke WriteString, centerX, 12, ADDR gameOverQuote, COLOR_GAMEOVER_BG
    
    ; Render retry options
    invoke CenterText, ADDR gameOverRetry
    mov centerX, eax
    
    invoke WriteString, centerX, 24, ADDR gameOverRetry, COLOR_FOOTER
    
    ; Present the frame
    call PresentFrame
    
    ret
RenderGameOver ENDP

END
