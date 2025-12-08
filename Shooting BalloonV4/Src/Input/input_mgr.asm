; ============================================================================
; input_mgr.asm - Keyboard Input Handling (Menu, Game, Game Over)
; Location: Src/Input/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN player:PLAYER_STRUCT
EXTERN currentState:DWORD
EXTERN nextState:DWORD
EXTERN gameRunning:BYTE
EXTERN currentLevel:DWORD

; From states.asm
EXTERN menuSelection:DWORD

; From levels.asm
EXTERN selectedLevel:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC HandleInput
PUBLIC IsKeyPressed
PUBLIC IsKeyDown
PUBLIC ClearKeyStates

; ============================= DATA SECTION =================================
.data
    keyStates       BYTE 256 dup(0)
    prevKeyStates   BYTE 256 dup(0)
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: ClearKeyStates
; Description: Clear all key states (called on state transitions)
; ----------------------------------------------------------------------------
ClearKeyStates PROC
    push edi
    push ecx
    
    ; Clear keyStates array
    mov edi, OFFSET keyStates
    mov ecx, 256
    xor eax, eax
    rep stosb
    
    pop ecx
    pop edi
    ret
ClearKeyStates ENDP

; ----------------------------------------------------------------------------
; Procedure: IsKeyPressed
; Description: Check if key is pressed (rising edge detection)
; Parameters: Virtual key code
; Returns: EAX = 1 if newly pressed, 0 otherwise
; ----------------------------------------------------------------------------
IsKeyPressed PROC vkCode:DWORD
    push ebx
    mov ebx, vkCode
    
    ; Check current state
    invoke GetAsyncKeyState, ebx
    test ax, 8000h
    jz NotPressed
    
    ; Check if was pressed before (debounce)
    movzx eax, BYTE PTR keyStates[ebx]
    test eax, eax
    jnz NotPressed
    
    ; Key is newly pressed
    mov BYTE PTR keyStates[ebx], 1
    mov eax, 1
    jmp Done
    
NotPressed:
    mov BYTE PTR keyStates[ebx], 0
    xor eax, eax
    
Done:
    pop ebx
    ret
IsKeyPressed ENDP

; ----------------------------------------------------------------------------
; Procedure: IsKeyDown
; Description: Check if key is currently held down
; Parameters: Virtual key code
; Returns: EAX = 1 if down, 0 otherwise
; ----------------------------------------------------------------------------
IsKeyDown PROC vkCode:DWORD
    invoke GetAsyncKeyState, vkCode
    test ax, 8000h
    jz NotDown
    mov eax, 1
    jmp Done
NotDown:
    xor eax, eax
Done:
    ret
IsKeyDown ENDP

; ----------------------------------------------------------------------------
; Procedure: HandleMenuInput
; Description: Handle input for menu state
; ----------------------------------------------------------------------------
HandleMenuInput PROC
    ; Check W key (up)
    invoke IsKeyPressed, VK_W
    test eax, eax
    jz CheckDown
    
    ; Move selection up
    cmp menuSelection, 0
    je CheckDown
    dec menuSelection
    
CheckDown:
    ; Check S key (down)
    invoke IsKeyPressed, VK_S
    test eax, eax
    jz CheckEnter
    
    ; Move selection down
    cmp menuSelection, 1
    jge CheckEnter
    inc menuSelection
    
CheckEnter:
    ; Check ENTER key
    invoke IsKeyPressed, VK_RETURN
    test eax, eax
    jz CheckEscape
    
    ; Confirm selection
    mov eax, menuSelection
    cmp eax, 0
    je StartGame
    
    ; Quit
    mov gameRunning, FALSE
    jmp InputDone
    
StartGame:
    ; Transition to level select instead of directly to game
    mov nextState, STATE_LEVEL_SELECT
    mov selectedLevel, 0        ; Reset selection to first level
    jmp InputDone
    
CheckEscape:
    ; Check ESC key
    invoke IsKeyPressed, VK_ESCAPE
    test eax, eax
    jz InputDone
    
    mov gameRunning, FALSE
    
InputDone:
    ret
HandleMenuInput ENDP

; ----------------------------------------------------------------------------
; Procedure: HandleLevelSelectInput
; Description: Handle input for level selection state
; ----------------------------------------------------------------------------
HandleLevelSelectInput PROC
    ; Check W key (up)
    invoke IsKeyPressed, VK_W
    test eax, eax
    jz CheckDown2
    
    ; Move selection up
    cmp selectedLevel, 0
    je CheckDown2
    dec selectedLevel
    
CheckDown2:
    ; Check S key (down)
    invoke IsKeyPressed, VK_S
    test eax, eax
    jz CheckEnter2
    
    ; Move selection down (max 5 for 6 levels: 0-5)
    cmp selectedLevel, 5
    jge CheckEnter2
    inc selectedLevel
    
CheckEnter2:
    ; Check ENTER key to start selected level
    invoke IsKeyPressed, VK_RETURN
    test eax, eax
    jz CheckEscape2
    
    ; Check if selected level is unlocked
    mov eax, selectedLevel
    inc eax                     ; Convert to 1-based level number
    invoke IsLevelUnlocked, eax
    test eax, eax
    jz CheckEscape2             ; If locked, ignore enter
    
    ; Start the selected level
    mov eax, selectedLevel
    inc eax
    mov currentLevel, eax       ; Set current level
    call InitGame               ; Initialize game for this level
    mov nextState, STATE_GAME
    jmp InputDone2
    
CheckEscape2:
    ; Check ESC key to go back to menu
    invoke IsKeyPressed, VK_ESCAPE
    test eax, eax
    jz InputDone2
    
    mov nextState, STATE_MENU
    
InputDone2:
    ret
HandleLevelSelectInput ENDP

; ----------------------------------------------------------------------------
; Procedure: HandleGameInput
; Description: Handle input for game state
; ----------------------------------------------------------------------------
HandleGameInput PROC
    LOCAL deltaX:SDWORD
    LOCAL deltaY:SDWORD
    
    mov deltaX, 0
    mov deltaY, 0
    
    ; Check A key (left)
    invoke IsKeyDown, VK_A
    test eax, eax
    jz CheckRight
    
    dec deltaX
    
CheckRight:
    ; Check D key (right)
    invoke IsKeyDown, VK_D
    test eax, eax
    jz CheckUp
    
    inc deltaX
    
CheckUp:
    ; Check W key (up/forward)
    invoke IsKeyDown, VK_W
    test eax, eax
    jz CheckDown2
    
    dec deltaY
    
CheckDown2:
    ; Check S key (down/backward)
    invoke IsKeyDown, VK_S
    test eax, eax
    jz ApplyMovement
    
    inc deltaY
    
ApplyMovement:
    ; Apply movement if any
    mov eax, deltaX
    or eax, deltaY
    jz CheckShoot
    
    invoke UpdatePlayerMovement, deltaX, deltaY
    
CheckShoot:
    ; Check SPACE for shoot
    invoke IsKeyPressed, VK_SPACE
    test eax, eax
    jz CheckSwap
    
    call FireProjectile
    ; TODO: Play shoot sound
    
CheckSwap:
    ; Check SHIFT for weapon swap
    invoke IsKeyPressed, VK_SHIFT
    test eax, eax
    jz CheckPause
    
    mov al, player.weapon
    xor al, 1
    mov player.weapon, al
    
CheckPause:
    ; Check P for pause
    invoke IsKeyPressed, VK_P
    test eax, eax
    jz CheckQuit
    
    mov nextState, STATE_PAUSE
    
CheckQuit:
    ; Check ESC to quit to menu
    invoke IsKeyPressed, VK_ESCAPE
    test eax, eax
    jz InputDone2
    
    mov nextState, STATE_MENU
    
InputDone2:
    ret
HandleGameInput ENDP

; ----------------------------------------------------------------------------
; Procedure: HandleGameOverInput
; Description: Handle input for game over state
; ----------------------------------------------------------------------------
HandleGameOverInput PROC
    ; Check R for retry
    invoke IsKeyPressed, VK_R
    test eax, eax
    jz CheckQuit2
    
    call InitGame
    mov nextState, STATE_GAME
    jmp InputDone3
    
CheckQuit2:
    ; Check Q for quit to menu
    invoke IsKeyPressed, VK_Q
    test eax, eax
    jz InputDone3
    
    mov nextState, STATE_MENU
    
InputDone3:
    ret
HandleGameOverInput ENDP

; ----------------------------------------------------------------------------
; Procedure: HandleInput
; Description: Main input handler (delegates to state-specific handlers)
; ----------------------------------------------------------------------------
HandleInput PROC
    mov eax, currentState
    
    cmp eax, STATE_MENU
    je DoMenuInput
    
    cmp eax, STATE_LEVEL_SELECT
    je DoLevelSelectInput
    
    cmp eax, STATE_GAME
    je DoGameInput
    
    cmp eax, STATE_GAMEOVER
    je DoGameOverInput
    
    jmp InputDone4
    
DoMenuInput:
    call HandleMenuInput
    jmp InputDone4
    
DoLevelSelectInput:
    call HandleLevelSelectInput
    jmp InputDone4
    
DoGameInput:
    call HandleGameInput
    jmp InputDone4
    
DoGameOverInput:
    call HandleGameOverInput
    
InputDone4:
    ret
HandleInput ENDP

END
