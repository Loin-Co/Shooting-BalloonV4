; ============================================================================
; main.asm - Program Entry Point & Main Game Loop
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================
; This module contains:
;   - Program entry point (start)
;   - Main game loop with state machine orchestration
;   - Frame timing control for 60 FPS target
; ============================================================================

.686
.model flat, stdcall
option casemap :none

; ============================================================================
; INCLUDES
; ============================================================================
include windows.inc
include kernel32.inc
include msvcrt.inc

includelib kernel32.lib
includelib msvcrt.lib

include common.inc
include protos.inc

; ============================================================================
; DATA SECTION
; ============================================================================
.data
    szWelcomeMsg    db "WELCOME TO DERRY 2025", 0
    szLoadingMsg    db "[ BALLOON SHOOTER PROTOCOL INITIATED ]", 0
    szExitMsg       db "They all float down here... Goodbye.", 0
    
    dwFrameStart    dd 0
    dwFrameTime     dd 0
    dwTargetTime    dd FRAME_TIME_MS
    
    bRunning        db 1

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; Main Entry Point
; ============================================================================
start:
    ; Initialize all systems
    call InitConsole
    call InitAudio
    call InitMemory
    call SetupBuffer
    
    ; Show loading screen with animations
    call ShowLoadingScreen
    
    ; Set initial game state to main menu
    mov g_GameState, STATE_MENU
    
    ; Start main game loop
    call MainLoop
    
    ; Cleanup and exit
    invoke ExitProcess, 0

; ============================================================================
; MainLoop - Core game loop with state machine
; ============================================================================
MainLoop PROC
    LOCAL tickStart:DWORD
    LOCAL tickEnd:DWORD
    LOCAL elapsed:DWORD
    LOCAL sleepTime:DWORD
    
MainLoop_Start:
    ; Check if we should continue running
    cmp bRunning, 0
    je MainLoop_Exit
    
    ; Get frame start time
    invoke GetTickCount
    mov tickStart, eax
    
    ; Clear the screen buffer
    call ClearScreen
    
    ; Process input
    call ReadKeys
    
    ; Execute current state
    mov eax, g_GameState
    
    cmp eax, STATE_SPLASH
    je State_Splash
    
    cmp eax, STATE_MENU
    je State_Menu
    
    cmp eax, STATE_LEVEL_SELECT
    je State_LevelSelect

    cmp eax, STATE_INSTRUCTIONS
    je State_Instructions

    cmp eax, STATE_PLAYING
    je State_Playing
    
    cmp eax, STATE_PAUSED
    je State_Paused
    
    cmp eax, STATE_GAME_OVER
    je State_GameOver
    
    cmp eax, STATE_JUMPSCARE
    je State_Jumpscare
    
    cmp eax, STATE_EXIT
    je State_Exit
    
    jmp State_Done

; ============================================================================
; STATE: Splash Screen
; ============================================================================
State_Splash:
    ; This state is now replaced by ShowLoadingScreen
    ; Auto-transition to menu
    mov g_GameState, STATE_MENU
    jmp State_Done

; ============================================================================
; STATE: Main Menu
; ============================================================================
State_Menu:
    ; Draw the menu
    call ShowMainMenu
    
    ; Process menu input (returns new state in EAX)
    call ProcessMenuInput
    mov g_GameState, eax
    
    jmp State_Done

; ============================================================================
; STATE: Level Select
; ============================================================================
State_LevelSelect:
    ; Draw level selection screen
    call ShowLevelSelect
    
    ; Process level selection input (returns new state in EAX)
    call ProcessLevelSelectInput
    mov g_GameState, eax
    
    jmp State_Done

; ============================================================================
; STATE: Instructions
; ============================================================================
State_Instructions:
    call ShowInstructions
    call ProcessInstructionsInput
    mov g_GameState, eax
    jmp State_Done

; ============================================================================
; STATE: Playing (Main Game)
; ============================================================================
State_Playing:
    ; Update game entities
    call UpdateArcherPosition
    call UpdateBalloonMovement
    call SpawnManager
    call HandleShooting
    
    ; Check for collisions
    call CheckCollision
    
    ; Render all game entities (would call dedicated renderers)
    ; This is where entity drawing happens
    
    jmp State_Done

; ============================================================================
; STATE: Paused
; ============================================================================
State_Paused:
    ; Display pause menu
    ; Process pause input (ESC to unpause, etc.)
    jmp State_Done

; ============================================================================
; STATE: Game Over
; ============================================================================
State_GameOver:
    ; Display game over screen
    ; Show final score
    ; Wait for input to return to menu
    jmp State_Done

; ============================================================================
; STATE: Jumpscare
; ============================================================================
State_Jumpscare:
    ; Execute jumpscare sequence
    call FlashScreen
    call TriggerJumpscare
    
    ; Transition to game over
    invoke Sleep, 2000
    mov g_GameState, STATE_GAME_OVER
    jmp State_Done

; ============================================================================
; STATE: Exit
; ============================================================================
State_Exit:
    ; Display exit message
    call ClearScreen
    invoke DrawString, 20, 12, THEME_WARNING, ADDR szExitMsg
    call PresentFrame
    invoke Sleep, 1500
    
    ; Stop the main loop
    mov bRunning, 0
    jmp State_Done

State_Done:
    ; Present the frame to screen
    call PresentFrame
    
    ; Calculate frame time and sleep if needed
    invoke GetTickCount
    mov tickEnd, eax
    
    mov eax, tickEnd
    sub eax, tickStart
    mov elapsed, eax
    
    ; If frame took less than target time, sleep for the difference
    mov eax, dwTargetTime
    cmp elapsed, eax
    jge Skip_Sleep
    
    sub eax, elapsed
    mov sleepTime, eax
    invoke Sleep, sleepTime
    
Skip_Sleep:
    ; Loop back
    jmp MainLoop_Start

MainLoop_Exit:
    ret
MainLoop ENDP

end start
