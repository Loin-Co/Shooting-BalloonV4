;Myr Comment Hello! This is the main assembly file for the "IT: Welcome to Derry 2025" balloon shooting game.
; ============================================================================
; main.asm - Entry Point & State Machine Loop
; IT: Welcome to Derry 2025 - Balloon Shooting Game
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include common.inc

; ============================= EXTERNAL PROCEDURES ==========================
; From states.asm
RenderSplash PROTO
RenderMenu PROTO
RenderGameOver PROTO

; From render.asm
RenderGame PROTO
ClearScreen PROTO

; From physics.asm
UpdateGame PROTO
HandleInput PROTO
InitGame PROTO

; From utils.asm
InitRandom PROTO

; ============================= DATA SECTION =================================
.data
    PUBLIC hStdOut
    PUBLIC hStdIn
    PUBLIC bytesWritten
    PUBLIC currentState
    PUBLIC nextState
    PUBLIC gameRunning
    
    hStdOut         HANDLE ?
    hStdIn          HANDLE ?
    bytesWritten    DWORD ?
    
    ; Game State
    currentState    DWORD STATE_SPLASH
    nextState       DWORD STATE_SPLASH
    gameRunning     BYTE TRUE
    
    ; Timing
    lastTickTime    DWORD 0
    deltaTime       DWORD 0
    frameTime       DWORD 16        ; ~60 FPS target
    
    ; Console Info
    consoleInfo     CONSOLE_SCREEN_BUFFER_INFO <>
    
    ; Window Title
    windowTitle     db "IT: Welcome to Derry 2025", 0
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: CenterConsoleWindow
; Description: Centers the console window on the screen
; ----------------------------------------------------------------------------
CenterConsoleWindow PROC
    LOCAL screenWidth:DWORD
    LOCAL screenHeight:DWORD
    LOCAL consoleWindow:DWORD
    LOCAL windowWidth:DWORD
    LOCAL windowHeight:DWORD
    LOCAL posX:DWORD
    LOCAL posY:DWORD
    
    ; Get screen dimensions
    invoke GetSystemMetrics, SM_CXSCREEN
    mov screenWidth, eax
    
    invoke GetSystemMetrics, SM_CYSCREEN
    mov screenHeight, eax
    
    ; Get console window handle
    invoke GetConsoleWindow
    mov consoleWindow, eax
    
    ; Calculate window dimensions (approximate for 80x25 console)
    mov windowWidth, 640    ; Approximate pixel width
    mov windowHeight, 400   ; Approximate pixel height
    
    ; Calculate centered position
    mov eax, screenWidth
    sub eax, windowWidth
    shr eax, 1
    mov posX, eax
    
    mov eax, screenHeight
    sub eax, windowHeight
    shr eax, 1
    mov posY, eax
    
    ; Set window position
    invoke SetWindowPos, consoleWindow, 0, posX, posY, 640, 400, 0
    
    ret
CenterConsoleWindow ENDP

; ----------------------------------------------------------------------------
; Procedure: InitConsole
; Description: Initialize console handles and settings
; ----------------------------------------------------------------------------
InitConsole PROC
    ; Get stdout handle
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hStdOut, eax
    
    ; Get stdin handle
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hStdIn, eax
    
    ; Set window title
    invoke SetConsoleTitleA, ADDR windowTitle
    
    ; Center the window
    call CenterConsoleWindow
    
    ; Clear screen
    call ClearScreen
    
    ret
InitConsole ENDP

; ----------------------------------------------------------------------------
; Procedure: StateTransition
; Description: Handle state transitions with screen clearing
; ----------------------------------------------------------------------------
StateTransition PROC
    ; Check if state changed
    mov eax, currentState
    cmp eax, nextState
    je @F
    
    ; Clear screen buffer before transition
    call ClearScreen
    
    ; Update state
    mov eax, nextState
    mov currentState, eax
    
@@:
    ret
StateTransition ENDP

; ----------------------------------------------------------------------------
; Procedure: StateMachine
; Description: Main game loop state machine
; ----------------------------------------------------------------------------
StateMachine PROC
    LOCAL tickCount:DWORD
    
GameLoop:
    ; Get current tick count
    invoke timeGetTime
    mov tickCount, eax
    
    ; Calculate delta time
    mov eax, lastTickTime
    cmp eax, 0
    je FirstFrame
    
    mov eax, tickCount
    sub eax, lastTickTime
    mov deltaTime, eax
    jmp AfterDelta
    
FirstFrame:
    mov deltaTime, 16
    
AfterDelta:
    mov eax, tickCount
    mov lastTickTime, eax
    
    ; Handle state transition
    call StateTransition
    
    ; Execute current state
    mov eax, currentState
    
    cmp eax, STATE_SPLASH
    je HandleSplash
    
    cmp eax, STATE_MENU
    je HandleMenu
    
    cmp eax, STATE_GAME
    je HandleGame
    
    cmp eax, STATE_PAUSE
    je HandlePause
    
    cmp eax, STATE_GAMEOVER
    je HandleGameOver
    
    jmp EndStateCheck
    
HandleSplash:
    call RenderSplash
    ; Auto-transition to menu after splash
    mov nextState, STATE_MENU
    jmp EndStateCheck
    
HandleMenu:
    call HandleInput
    call RenderMenu
    jmp EndStateCheck
    
HandleGame:
    call HandleInput
    call UpdateGame
    call RenderGame
    jmp EndStateCheck
    
HandlePause:
    call HandleInput
    ; Render pause overlay
    jmp EndStateCheck
    
HandleGameOver:
    call HandleInput
    call RenderGameOver
    jmp EndStateCheck
    
EndStateCheck:
    ; Frame rate limiting
    invoke Sleep, frameTime
    
    ; Check if still running
    cmp gameRunning, FALSE
    je ExitLoop
    
    jmp GameLoop
    
ExitLoop:
    ret
StateMachine ENDP

; ----------------------------------------------------------------------------
; Procedure: main
; Description: Program entry point
; ----------------------------------------------------------------------------
main PROC
    ; Initialize console
    call InitConsole
    
    ; Initialize random number generator
    call InitRandom
    
    ; Initialize game data
    call InitGame
    
    ; Set initial state
    mov currentState, STATE_SPLASH
    mov nextState, STATE_SPLASH
    
    ; Run state machine
    call StateMachine
    
    ; Exit
    invoke ExitProcess, 0
    
main ENDP

END main
