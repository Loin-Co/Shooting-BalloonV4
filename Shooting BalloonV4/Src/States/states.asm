; ============================================================================
; states.asm - Menu, Intro, and Game Over Rendering Procedures
; Location: Src/States/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL PROCEDURES ==========================
; From render.asm
ClearBuffer PROTO
PresentFrame PROTO
WriteString PROTO :DWORD, :DWORD, :DWORD, :DWORD
WriteChar PROTO :DWORD, :DWORD, :DWORD, :DWORD

; From utils.asm
StrLen PROTO :DWORD
IntToStr PROTO :DWORD, :DWORD
InitRandom PROTO
InitGame PROTO
InitLevels PROTO

; ============================= EXTERNAL DATA ================================
EXTERN hStdOut:DWORD
EXTERN nextState:DWORD

; From levels.asm
EXTERN selectedLevel:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC RenderSplash
PUBLIC RenderMenu
PUBLIC RenderLevelSelect
PUBLIC RenderGameOver
PUBLIC menuSelection

; ============================= DATA SECTION =================================
.data
    ; Splash screen - Derry Mainframe Terminal (CENTERED)
    splashBorder        db 218, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 191, 0
    splashBorderSide    db 179, 0
    splashBorderBottom  db 192, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 217, 0
    
    splashHeader        db ">_  DERRY MAINFRAME - v1958", 0
    splashSystem        db "[ SYSTEM ]", 0
    splashWelcome       db "W E L C O M E   T O   D E R R Y   2 0 2 5", 0
    splashProtocol      db "[  BALLOON  SHOOTER  PROTOCOL  INITIATED  ]", 0
    
    splashMsg1          db "> Initializing RNG Seed...  ", 0
    splashMsg1OK        db "OK", 0
    splashMsg2          db "> Loading Game Engine...    ", 0
    splashMsg2OK        db "OK", 0
    splashMsg3          db "> Initializing Levels...    ", 0
    splashMsg3OK        db "OK", 0
    splashMsg4          db "> Loading Renderer...       ", 0
    splashMsg4OK        db "OK", 0
    splashMsg5          db "> Checking Fear Sensors...  ", 0
    splashMsg5Warn      db "WARNING: HIGH LEVELS", 0
    splashMsg6          db "> Pennywise AI Status...    ", 0
    splashMsg6Active    db "ACTIVE", 0
    
    splashLoadText      db "LOADING RESOURCES:", 0
    splashBarBracketL   db "[", 0
    splashBarBracketR   db "]", 0
    splashBarFill       db 219, 0
    splashBarEmpty      db 176, 0
    splashPercent       db "   0%", 0
    splashQuote         db '"They all float down here..."', 0
    
    ; Menu screen - New Design
    menuBorderTop       db 201, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 187, 0
    menuBorderSide      db 186, 0
    menuBorderBottom    db 200, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
                        db 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 188, 0
    
    menuTitle           db "W E L C O M E   T O   D E R R Y", 0
    menuSubtitle        db "The 8086 Arcade Edition", 0
    menuDivider         db "________________________________", 0
    
    menuBoxTop          db 218, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 191, 0
    menuBoxSide         db 179, 0
    menuBoxBottom       db 192, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196
                        db 196, 196, 196, 196, 196, 217, 0
    
    menuOption1         db ">  START GAME", 0
    menuOption1NoArrow  db "   START GAME", 0
    menuOption2         db ">  LEVEL SELECT", 0
    menuOption2NoArrow  db "   LEVEL SELECT", 0
    menuOption3         db ">  INSTRUCTIONS", 0
    menuOption3NoArrow  db "   INSTRUCTIONS", 0
    menuOption4         db ">  QUIT TO DOS", 0
    menuOption4NoArrow  db "   QUIT TO DOS", 0
    
    menuHighscore       db "HIGHSCORE: 1850  |  DEATHS: 042", 0
    menuVersion         db "v1.0 | ARROWS: Move | ENTER: Select", 0
    
    ; Level Select screen
    levelSelectTitle    db "SELECT LEVEL", 0
    levelSelectBack     db "________________________________________________", 0
    levelSelectFooter   db "[ARROWS]: Navigate | [ENTER]: Select | [ESC]: Back", 0
    levelStarFilled     db 219, 0   ; Filled block
    levelStarEmpty      db 176, 0   ; Light shade
    levelBestLabel      db "BEST:", 0
    levelLockedLabel    db "[ LOCKED ]", 0
    bestScoreBuffer     db 16 dup(0)
    
    ; Game Over screen
    gameOverTitle   db "Y O U   D I E D", 0
    gameOverQuote   db "YOU'LL FLOAT TOO", 0
    gameOverScore   db "YOUR SCORE: ", 0
    gameOverRetry   db "R: Retry   Q: Quit to Menu", 0
    
    PUBLIC menuSelection
    menuSelection   DWORD 0
    splashProgress  DWORD 0
    
    ; Initialization flags
    rngInitialized      BYTE FALSE
    gameInitialized     BYTE FALSE
    levelsInitialized   BYTE FALSE
    rendererInitialized BYTE FALSE
    
    ; Theme colors (Retro Horror Red & Black)
    THEME_BORDER    equ 0Ch
    THEME_TEXT      equ 07h
    THEME_ACCENT    equ 0Eh
    THEME_WARNING   equ 04h
    THEME_BTN_HOVER equ 4Fh
    
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
; Procedure: RenderSplashFrame
; Description: Render terminal-style loading screen with progress
; Parameters: progress (0-100)
; ----------------------------------------------------------------------------
RenderSplashFrame PROC progress:DWORD
    LOCAL centerX:DWORD
    LOCAL borderX:DWORD
    LOCAL borderY:DWORD
    LOCAL barFilled:DWORD
    LOCAL i:DWORD
    LOCAL currentY:DWORD
    
    call ClearBuffer
    
    ; Calculate border position (centered, 78 chars wide)
    mov eax, SCREEN_WIDTH
    sub eax, 78
    shr eax, 1
    mov borderX, eax
    mov borderY, 1
    
    ; Draw top border
    invoke WriteString, borderX, borderY, ADDR splashBorder, THEME_BORDER
    
    ; Draw header line: ">_ DERRY MAINFRAME - v1958" and "[ SYSTEM ]"
    mov eax, borderY
    inc eax
    mov currentY, eax
    
    ; Left side
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Header text
    mov eax, borderX
    add eax, 2
    invoke WriteString, eax, currentY, ADDR splashHeader, THEME_ACCENT
    
    ; System label (right-aligned)
    mov eax, borderX
    add eax, 62
    invoke WriteString, eax, currentY, ADDR splashSystem, THEME_TEXT
    
    ; Right side
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Draw sides for spacing rows (3-4)
    mov i, 0
DrawEmptyRows1:
    cmp i, 2
    jge EmptyRows1Done
    
    mov eax, currentY
    inc eax
    mov currentY, eax
    
    ; Left side
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Right side
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    inc i
    jmp DrawEmptyRows1
    
EmptyRows1Done:
    ; Draw "WELCOME TO DERRY 2025"
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    invoke CenterText, ADDR splashWelcome
    mov centerX, eax
    invoke WriteString, centerX, currentY, ADDR splashWelcome, COLOR_WHITE
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Draw "[ BALLOON SHOOTER PROTOCOL INITIATED ]"
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    invoke CenterText, ADDR splashProtocol
    mov centerX, eax
    invoke WriteString, centerX, currentY, ADDR splashProtocol, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Draw empty rows (7-9)
    mov i, 0
DrawEmptyRows2:
    cmp i, 3
    jge EmptyRows2Done
    
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    inc i
    jmp DrawEmptyRows2
    
EmptyRows2Done:
    ; Draw initialization messages
    ; Message 1: Loading Memory Modules
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 3
    invoke WriteString, eax, currentY, ADDR splashMsg1, THEME_TEXT
    
    ; Show OK if progress >= 16
    mov eax, progress
    cmp eax, 16
    jl Msg1NoStatus
    mov ebx, borderX
    add ebx, 47
    invoke WriteString, ebx, currentY, ADDR splashMsg1OK, COLOR_LIGHT_GREEN
    
Msg1NoStatus:
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Message 2: Checking Fear Sensors
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 3
    invoke WriteString, eax, currentY, ADDR splashMsg5, THEME_TEXT
    
    mov eax, progress
    cmp eax, 33
    jl Msg2NoStatus
    mov ebx, borderX
    add ebx, 40
    invoke WriteString, ebx, currentY, ADDR splashMsg5Warn, THEME_WARNING
    
Msg2NoStatus:
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Message 3: Pennywise AI
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 3
    invoke WriteString, eax, currentY, ADDR splashMsg6, THEME_TEXT
    
    mov eax, progress
    cmp eax, 50
    jl Msg3NoStatus
    mov ebx, borderX
    add ebx, 47
    invoke WriteString, ebx, currentY, ADDR splashMsg6Active, COLOR_LIGHT_GREEN
    
Msg3NoStatus:
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Message 4: Loading Renderer
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 3
    invoke WriteString, eax, currentY, ADDR splashMsg4, THEME_TEXT
    
    mov eax, progress
    cmp eax, 66
    jl Msg4NoStatus
    mov ebx, borderX
    add ebx, 47
    invoke WriteString, ebx, currentY, ADDR splashMsg4OK, COLOR_LIGHT_GREEN
    
Msg4NoStatus:
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Empty rows before progress bar (14-17)
    mov i, 0
DrawEmptyRows3:
    cmp i, 4
    jge EmptyRows3Done
    
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    inc i
    jmp DrawEmptyRows3
    
EmptyRows3Done:
    ; Draw "LOADING RESOURCES:"
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 6
    invoke WriteString, eax, currentY, ADDR splashLoadText, THEME_TEXT
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Empty row
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Draw progress bar
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Calculate filled portion (60 chars bar)
    mov eax, progress
    imul eax, 60
    mov ebx, 100
    xor edx, edx
    div ebx
    mov barFilled, eax
    
    ; Left bracket
    mov eax, borderX
    add eax, 6
    invoke WriteString, eax, currentY, ADDR splashBarBracketL, THEME_BORDER
    
    ; Draw filled portion
    mov i, 0
    mov eax, borderX
    add eax, 7
    mov centerX, eax
    
DrawBarFilled:
    mov eax, i
    cmp eax, barFilled
    jge DrawBarEmpty
    
    mov ebx, centerX
    add ebx, i
    invoke WriteString, ebx, currentY, ADDR splashBarFill, COLOR_LIGHT_GREEN
    
    inc i
    jmp DrawBarFilled
    
DrawBarEmpty:
    mov eax, i
    cmp eax, 60
    jge DrawBarRight
    
    mov ebx, centerX
    add ebx, i
    invoke WriteString, ebx, currentY, ADDR splashBarEmpty, THEME_TEXT
    
    inc i
    jmp DrawBarEmpty
    
DrawBarRight:
    ; Right bracket
    mov eax, centerX
    add eax, 60
    invoke WriteString, eax, currentY, ADDR splashBarBracketR, THEME_BORDER
    
    ; Percentage (right side of bar)
    add eax, 2
    push eax
    push currentY
    
    ; Format percentage string
    mov eax, progress
    lea ebx, splashPercent
    
    ; Convert to string manually (simple for 0-100)
    cmp eax, 100
    je Percent100
    cmp eax, 10
    jl PercentSingle
    
    ; Two digits
    mov ecx, eax
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    mov byte ptr splashPercent+1, al
    add dl, '0'
    mov byte ptr splashPercent+2, dl
    mov byte ptr splashPercent+3, '%'
    jmp PercentDone
    
Percent100:
    mov byte ptr splashPercent, '1'
    mov byte ptr splashPercent+1, '0'
    mov byte ptr splashPercent+2, '0'
    mov byte ptr splashPercent+3, '%'
    jmp PercentDone
    
PercentSingle:
    add al, '0'
    mov byte ptr splashPercent+2, al
    mov byte ptr splashPercent+3, '%'
    
PercentDone:
    pop currentY
    pop eax
    invoke WriteString, eax, currentY, ADDR splashPercent, THEME_ACCENT
    
    ; Right border
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Empty rows before quote (21-22)
    mov i, 0
DrawEmptyRows4:
    cmp i, 2
    jge EmptyRows4Done
    
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    inc i
    jmp DrawEmptyRows4
    
EmptyRows4Done:
    ; Draw Pennywise quote
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    invoke CenterText, ADDR splashQuote
    mov centerX, eax
    invoke WriteString, centerX, currentY, ADDR splashQuote, THEME_TEXT
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Empty row
    inc currentY
    mov eax, borderX
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    mov eax, borderX
    add eax, 77
    invoke WriteString, eax, currentY, ADDR splashBorderSide, THEME_BORDER
    
    ; Draw bottom border
    inc currentY
    invoke WriteString, borderX, currentY, ADDR splashBorderBottom, THEME_BORDER
    
    ; Present the frame
    call PresentFrame
    
    ret
RenderSplashFrame ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderSplash
; Description: Render splash/loading screen
; ----------------------------------------------------------------------------
RenderSplash PROC
    LOCAL progress:DWORD
    LOCAL frameCount:DWORD
    
    mov progress, 0
    mov frameCount, 0
    
AnimationLoop:
    ; Render current frame
    invoke RenderSplashFrame, progress
    
    ; ACTUAL INITIALIZATION BASED ON PROGRESS
    mov eax, progress
    
    ; Stage 1: Initialize RNG (15-16%)
    cmp eax, 15
    jl CheckStage2
    cmp rngInitialized, TRUE
    je CheckStage2
    call InitRandom
    mov rngInitialized, TRUE
    invoke Sleep, 100  ; Simulate initialization time
    
CheckStage2:
    ; Stage 2: Initialize Game Engine (32-33%)
    mov eax, progress
    cmp eax, 32
    jl CheckStage3
    cmp gameInitialized, TRUE
    je CheckStage3
    call InitGame
    mov gameInitialized, TRUE
    invoke Sleep, 150  ; Simulate initialization time
    
CheckStage3:
    ; Stage 3: Initialize Levels (49-50%)
    mov eax, progress
    cmp eax, 49
    jl CheckStage4
    cmp levelsInitialized, TRUE
    je CheckStage4
    call InitLevels
    mov levelsInitialized, TRUE
    invoke Sleep, 120  ; Simulate initialization time
    
CheckStage4:
    ; Stage 4: Initialize Renderer (65-66%)
    mov eax, progress
    cmp eax, 65
    jl CheckStage5
    cmp rendererInitialized, TRUE
    je CheckStage5
    ; Renderer already initialized in InitConsole, but clear buffers
    call ClearBuffer
    mov rendererInitialized, TRUE
    invoke Sleep, 80
    
CheckStage5:
    ; Stage 5-6: Final checks and warmup (82-100%)
    mov eax, progress
    cmp eax, 82
    jl NormalDelay
    invoke Sleep, 60  ; Extra delay for dramatic effect
    jmp AfterDelay
    
NormalDelay:
    ; Normal frame delay (smooth animation)
    invoke Sleep, 25
    
AfterDelay:
    ; Increment progress (slower for realism, ~2% per frame)
    mov eax, progress
    add eax, 2
    mov progress, eax
    
    inc frameCount
    
    ; Check if done
    cmp progress, 100
    jle AnimationLoop
    
    ; Final frame at 100%
    invoke RenderSplashFrame, 100
    invoke Sleep, 800  ; Hold final screen longer
    
    ; Reset initialization flags for next run
    mov rngInitialized, FALSE
    mov gameInitialized, FALSE
    mov levelsInitialized, FALSE
    mov rendererInitialized, FALSE
    
    ret
RenderSplash ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderMenu
; Description: Render main menu with new design
; ----------------------------------------------------------------------------
RenderMenu PROC
    LOCAL centerX:DWORD
    LOCAL i:DWORD
    LOCAL outerBorderX:DWORD
    LOCAL outerBorderY:DWORD
    LOCAL menuBoxX:DWORD
    LOCAL menuBoxY:DWORD
    
    call ClearBuffer
    
    ; Calculate positions for outer border (96 chars wide, 30 chars tall)
    mov eax, SCREEN_WIDTH
    sub eax, 96
    shr eax, 1
    mov outerBorderX, eax
    
    mov outerBorderY, 2  ; Start at row 2
    
    ; Draw outer border top
    invoke WriteString, outerBorderX, outerBorderY, ADDR menuBorderTop, THEME_BORDER
    
    ; Draw outer border sides (28 rows)
    mov i, 1
DrawOuterSides:
    mov eax, outerBorderY
    add eax, i
    
    ; Left side
    invoke WriteString, outerBorderX, eax, ADDR menuBorderSide, THEME_BORDER
    
    ; Right side
    push eax
    mov eax, outerBorderX
    add eax, 95  ; 96-1 for right edge
    mov ebx, outerBorderY
    add ebx, i
    invoke WriteString, eax, ebx, ADDR menuBorderSide, THEME_BORDER
    pop eax
    
    inc i
    cmp i, 28
    jle DrawOuterSides
    
    ; Draw outer border bottom
    mov eax, outerBorderY
    add eax, 29
    invoke WriteString, outerBorderX, eax, ADDR menuBorderBottom, THEME_BORDER
    
    ; Render title (centered inside outer border)
    invoke CenterText, ADDR menuTitle
    mov centerX, eax
    mov eax, outerBorderY
    add eax, 3
    invoke WriteString, centerX, eax, ADDR menuTitle, COLOR_WHITE
    
    ; Render subtitle
    invoke CenterText, ADDR menuSubtitle
    mov centerX, eax
    mov eax, outerBorderY
    add eax, 4
    invoke WriteString, centerX, eax, ADDR menuSubtitle, THEME_TEXT
    
    ; Render divider
    invoke CenterText, ADDR menuDivider
    mov centerX, eax
    mov eax, outerBorderY
    add eax, 5
    invoke WriteString, centerX, eax, ADDR menuDivider, THEME_BORDER
    
    ; Calculate menu box position (66 chars wide, centered)
    mov eax, SCREEN_WIDTH
    sub eax, 66
    shr eax, 1
    mov menuBoxX, eax
    
    mov eax, outerBorderY
    add eax, 8
    mov menuBoxY, eax
    
    ; Draw menu box top
    invoke WriteString, menuBoxX, menuBoxY, ADDR menuBoxTop, THEME_BORDER
    
    ; Draw menu box sides and options
    mov i, 1
DrawMenuBoxContent:
    mov eax, menuBoxY
    add eax, i
    
    ; Left side
    invoke WriteString, menuBoxX, eax, ADDR menuBoxSide, THEME_BORDER
    
    ; Right side
    push eax
    mov eax, menuBoxX
    add eax, 65  ; 66-1 for right edge
    mov ebx, menuBoxY
    add ebx, i
    invoke WriteString, eax, ebx, ADDR menuBoxSide, THEME_BORDER
    pop eax
    
    ; Draw menu options
    mov eax, i
    
    ; Option 1: START GAME (row 2 inside box)
    cmp eax, 2
    jne CheckOption2
    mov ebx, menuBoxX
    add ebx, 3  ; Indent from left border
    mov ecx, menuBoxY
    add ecx, 2
    
    mov eax, menuSelection
    cmp eax, 0
    je DrawOption1Selected
    invoke WriteString, ebx, ecx, ADDR menuOption1NoArrow, COLOR_WHITE
    jmp CheckOption2
DrawOption1Selected:
    invoke WriteString, ebx, ecx, ADDR menuOption1, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
CheckOption2:
    ; Option 2: LEVEL SELECT (row 3 inside box)
    mov eax, i
    cmp eax, 3
    jne CheckOption3
    mov ebx, menuBoxX
    add ebx, 3
    mov ecx, menuBoxY
    add ecx, 3
    
    mov eax, menuSelection
    cmp eax, 1
    je DrawOption2Selected
    invoke WriteString, ebx, ecx, ADDR menuOption2NoArrow, COLOR_WHITE
    jmp CheckOption3
DrawOption2Selected:
    invoke WriteString, ebx, ecx, ADDR menuOption2, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
CheckOption3:
    ; Option 3: INSTRUCTIONS (row 4 inside box)
    mov eax, i
    cmp eax, 4
    jne CheckOption4
    mov ebx, menuBoxX
    add ebx, 3
    mov ecx, menuBoxY
    add ecx, 4
    
    mov eax, menuSelection
    cmp eax, 2
    je DrawOption3Selected
    invoke WriteString, ebx, ecx, ADDR menuOption3NoArrow, COLOR_WHITE
    jmp CheckOption4
DrawOption3Selected:
    invoke WriteString, ebx, ecx, ADDR menuOption3, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
CheckOption4:
    ; Option 4: QUIT TO DOS (row 5 inside box)
    mov eax, i
    cmp eax, 5
    jne ContinueMenuBox
    mov ebx, menuBoxX
    add ebx, 3
    mov ecx, menuBoxY
    add ecx, 5
    
    mov eax, menuSelection
    cmp eax, 3
    je DrawOption4Selected
    invoke WriteString, ebx, ecx, ADDR menuOption4NoArrow, COLOR_WHITE
    jmp ContinueMenuBox
DrawOption4Selected:
    invoke WriteString, ebx, ecx, ADDR menuOption4, COLOR_BLACK + (COLOR_LIGHT_YELLOW shl 4)
    
ContinueMenuBox:
    inc i
    cmp i, 7  ; Menu box is 8 rows tall (1 top + 6 content + 1 bottom)
    jle DrawMenuBoxContent
    
    ; Draw menu box bottom
    mov eax, menuBoxY
    add eax, 8
    invoke WriteString, menuBoxX, eax, ADDR menuBoxBottom, THEME_BORDER
    
    ; Render highscore and deaths (centered)
    invoke CenterText, ADDR menuHighscore
    mov centerX, eax
    mov eax, outerBorderY
    add eax, 20
    invoke WriteString, centerX, eax, ADDR menuHighscore, THEME_ACCENT
    
    ; Render version info at bottom (inside outer border)
    invoke CenterText, ADDR menuVersion
    mov centerX, eax
    mov eax, outerBorderY
    add eax, 27
    invoke WriteString, centerX, eax, ADDR menuVersion, THEME_TEXT
    
    ; Present the frame
    call PresentFrame
    
    ret
RenderMenu ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderLevelSelect
; Description: Render level selection screen
; ----------------------------------------------------------------------------
RenderLevelSelect PROC
    LOCAL centerX:DWORD
    LOCAL yPos:DWORD
    LOCAL i:DWORD
    LOCAL isUnlocked:DWORD
    LOCAL bestScore:DWORD
    LOCAL levelNum:DWORD
    LOCAL namePtr:DWORD
    
    call ClearBuffer
    
    ; Render title at top
    invoke CenterText, ADDR levelSelectTitle
    mov centerX, eax
    invoke WriteString, centerX, 3, ADDR levelSelectTitle, THEME_BORDER
    
    ; Render border box (simple horizontal lines)
    mov centerX, 20
    invoke WriteString, centerX, 5, OFFSET levelSelectBack, THEME_TEXT
    invoke WriteString, centerX, 6, OFFSET levelSelectBack, THEME_TEXT
    invoke WriteString, centerX, 6, OFFSET levelSelectBack, THEME_TEXT
    
    ; Starting Y position for level list
    mov yPos, 7
    mov i, 0
    
RenderLevelLoop:
    ; Check if we've rendered 6 levels (only show first 6)
    mov eax, i
    cmp eax, 6
    jge LevelListDone
    
    ; Level number (1-based)
    mov levelNum, eax
    inc levelNum
    
    ; Get level name
    invoke GetLevelName, levelNum
    test eax, eax
    jz NextLevel
    mov namePtr, eax
    
    ; Check if level is unlocked
    invoke IsLevelUnlocked, levelNum
    mov isUnlocked, eax
    
    ; Calculate Y position for this level
    mov eax, yPos
    
    ; Draw level number
    mov ebx, 22                 ; X position for level number
    push eax
    
    ; Format: "1. LEVEL_NAME"
    mov edx, levelNum
    add edx, 48                 ; Convert to ASCII '1', '2', etc.
    
    ; Draw number and dot
    ; (simplified - in real version would use WriteChar)
    
    pop eax
    
    ; Draw level name (centered region)
    mov ebx, 26                 ; X position for level name
    
    ; Check if selected
    mov edx, i
    cmp edx, selectedLevel
    je RenderSelected
    
    ; Not selected - check if unlocked
    cmp isUnlocked, 0
    je RenderLocked
    
    ; Unlocked but not selected
    invoke WriteString, ebx, eax, namePtr, THEME_TEXT
    
    ; Render stars (show 3 stars max based on score)
    add ebx, 28                 ; Move to star position
    invoke GetBestScore, levelNum
    mov bestScore, eax
    
    ; Simple star rendering (3 stars max)
    ; Star 1: if score > 100
    cmp bestScore, 100
    jl Star1Empty
    invoke WriteString, ebx, yPos, ADDR levelStarFilled, THEME_ACCENT
    jmp Star2Check
Star1Empty:
    invoke WriteString, ebx, yPos, ADDR levelStarEmpty, THEME_TEXT
    
Star2Check:
    add ebx, 2
    cmp bestScore, 250
    jl Star2Empty
    invoke WriteString, ebx, yPos, ADDR levelStarFilled, THEME_ACCENT
    jmp Star3Check
Star2Empty:
    invoke WriteString, ebx, yPos, ADDR levelStarEmpty, THEME_TEXT
    
Star3Check:
    add ebx, 2
    cmp bestScore, 400
    jl Star3Empty
    invoke WriteString, ebx, yPos, ADDR levelStarFilled, THEME_ACCENT
    jmp RenderBestScore
Star3Empty:
    invoke WriteString, ebx, yPos, ADDR levelStarEmpty, THEME_TEXT
    
RenderBestScore:
    ; Render "BEST: XXX"
    add ebx, 5
    invoke WriteString, ebx, yPos, ADDR levelBestLabel, THEME_TEXT
    
    ; Convert best score to string
    invoke IntToStr, bestScore, ADDR bestScoreBuffer
    add ebx, 6
    invoke WriteString, ebx, yPos, ADDR bestScoreBuffer, THEME_ACCENT
    
    jmp NextLevel
    
RenderSelected:
    ; Selected level - highlight
    cmp isUnlocked, 0
    je RenderLockedSelected
    
    ; Unlocked and selected
    invoke WriteString, ebx, eax, namePtr, THEME_BTN_HOVER
    jmp NextLevel
    
RenderLockedSelected:
    ; Locked and selected
    invoke WriteString, ebx, eax, ADDR levelLockedLabel, THEME_WARNING
    jmp NextLevel
    
RenderLocked:
    ; Locked level
    invoke WriteString, ebx, eax, ADDR levelLockedLabel, THEME_WARNING
    
NextLevel:
    inc i
    add yPos, 3                 ; Space between levels
    jmp RenderLevelLoop
    
LevelListDone:
    ; Render footer
    invoke CenterText, ADDR levelSelectFooter
    mov centerX, eax
    invoke WriteString, centerX, 30, ADDR levelSelectFooter, COLOR_FOOTER
    
    ; Present the frame
    call PresentFrame
    
    ret
RenderLevelSelect ENDP

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
