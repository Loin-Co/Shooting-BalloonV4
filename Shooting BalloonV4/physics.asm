; ============================================================================
; physics.asm - Movement, Collision, Weapon Logic
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include common.inc

; ============================= EXTERNAL DATA ================================
EXTERN hStdOut:DWORD
EXTERN nextState:DWORD
EXTERN gameRunning:BYTE
EXTERN currentState:DWORD

; From states.asm
EXTERN menuSelection:DWORD

; From utils.asm
RandomRange PROTO :DWORD
Clamp PROTO :DWORD, :DWORD, :DWORD

; Public exports
PUBLIC InitGame
PUBLIC HandleInput
PUBLIC UpdateGame
PUBLIC player
PUBLIC balloons
PUBLIC projectiles
PUBLIC currentLevel
PUBLIC fearMeter

; Internal prototypes
IsKeyPressed PROTO :DWORD
IsKeyDown PROTO :DWORD
HandleMenuInput PROTO
HandleGameInput PROTO
HandleGameOverInput PROTO
FireProjectile PROTO
SpawnBalloon PROTO
UpdateProjectiles PROTO
UpdateBalloons PROTO
CheckCollisions PROTO

; ============================= DATA SECTION =================================
.data
    ; Player
    player          PLAYER_STRUCT <>
    
    ; Entities
    balloons        ENTITY MAX_BALLOONS dup(<>)
    
    projectiles     ENTITY MAX_PROJECTILES dup(<>)
    
    ; Game state
    currentLevel    DWORD 1
    
    fearMeter       DWORD 0
    
    lastFearUpdate  DWORD 0
    balloonSpawnTimer DWORD 0
    
    ; Input state
    keyStates       BYTE 256 dup(0)
    prevKeyStates   BYTE 256 dup(0)
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: InitGame
; Description: Initialize game data
; ----------------------------------------------------------------------------
InitGame PROC
    ; Initialize player
    mov player.x, PLAYER_START_X
    mov player.y, PLAYER_START_Y
    mov player.weapon, WEAPON_BOW
    mov player.score, 0
    mov player.lives, 3
    
    ; Clear balloons
    push edi
    mov edi, OFFSET balloons
    mov ecx, MAX_BALLOONS
ClearBalloons:
    mov BYTE PTR [edi].ENTITY.active, FALSE
    add edi, SIZEOF ENTITY
    loop ClearBalloons
    pop edi
    
    ; Clear projectiles
    push edi
    mov edi, OFFSET projectiles
    mov ecx, MAX_PROJECTILES
ClearProjectiles:
    mov BYTE PTR [edi].ENTITY.active, FALSE
    add edi, SIZEOF ENTITY
    loop ClearProjectiles
    pop edi
    
    ; Reset game state
    mov currentLevel, 1
    mov fearMeter, 0
    
    invoke timeGetTime
    mov lastFearUpdate, eax
    mov balloonSpawnTimer, eax
    
    ret
InitGame ENDP

; ----------------------------------------------------------------------------
; Procedure: IsKeyPressed
; Description: Check if key is pressed (rising edge)
; Parameters: Virtual key code
; Returns: EAX = 1 if pressed, 0 otherwise
; ----------------------------------------------------------------------------
IsKeyPressed PROC vkCode:DWORD
    push ebx
    mov ebx, vkCode
    
    ; Check current state
    invoke GetAsyncKeyState, ebx
    test ax, 8000h
    jz NotPressed
    
    ; Check if was pressed before
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
    ; Check UP key
    invoke IsKeyPressed, VK_UP
    test eax, eax
    jz CheckDown
    
    ; Move selection up
    cmp menuSelection, 0
    je CheckDown
    dec menuSelection
    
CheckDown:
    ; Check DOWN key
    invoke IsKeyPressed, VK_DOWN
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
    mov nextState, STATE_GAME
    call InitGame
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
; Procedure: HandleGameInput
; Description: Handle input for game state
; ----------------------------------------------------------------------------
HandleGameInput PROC
    ; Check LEFT arrow
    invoke IsKeyDown, VK_LEFT
    test eax, eax
    jz CheckRight
    
    mov eax, player.x
    dec eax
    invoke Clamp, eax, 0, SCREEN_WIDTH - 1
    mov player.x, eax
    
CheckRight:
    ; Check RIGHT arrow
    invoke IsKeyDown, VK_RIGHT
    test eax, eax
    jz CheckUp
    
    mov eax, player.x
    inc eax
    invoke Clamp, eax, 0, SCREEN_WIDTH - 1
    mov player.x, eax
    
CheckUp:
    ; Check UP arrow
    invoke IsKeyDown, VK_UP
    test eax, eax
    jz CheckDown2
    
    mov eax, player.y
    dec eax
    invoke Clamp, eax, 0, GAME_HEIGHT - 1
    mov player.y, eax
    
CheckDown2:
    ; Check DOWN arrow
    invoke IsKeyDown, VK_DOWN
    test eax, eax
    jz CheckShoot
    
    mov eax, player.y
    inc eax
    invoke Clamp, eax, 0, GAME_HEIGHT - 1
    mov player.y, eax
    
CheckShoot:
    ; Check SPACE for shoot
    invoke IsKeyPressed, VK_SPACE
    test eax, eax
    jz CheckSwap
    
    call FireProjectile
    
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
    ; Check ESC to quit
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
    
    cmp eax, STATE_GAME
    je DoGameInput
    
    cmp eax, STATE_GAMEOVER
    je DoGameOverInput
    
    jmp InputDone4
    
DoMenuInput:
    call HandleMenuInput
    jmp InputDone4
    
DoGameInput:
    call HandleGameInput
    jmp InputDone4
    
DoGameOverInput:
    call HandleGameOverInput
    
InputDone4:
    ret
HandleInput ENDP

; ----------------------------------------------------------------------------
; Procedure: FireProjectile
; Description: Create a new projectile
; ----------------------------------------------------------------------------
FireProjectile PROC
    LOCAL projPtr:DWORD
    LOCAL i:DWORD
    
    mov i, 0
    mov projPtr, OFFSET projectiles
    
FindSlot:
    mov eax, i
    cmp eax, MAX_PROJECTILES
    jge NoSlot
    
    mov ebx, projPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je FoundSlot
    
    add projPtr, SIZEOF ENTITY
    inc i
    jmp FindSlot
    
FoundSlot:
    mov ebx, projPtr
    
    ; Set projectile data
    mov eax, player.x
    mov [ebx].ENTITY.x, eax
    mov eax, player.y
    mov [ebx].ENTITY.y, eax
    
    mov [ebx].ENTITY.vx, 0
    mov DWORD PTR [ebx].ENTITY.vy, -1     ; Move up (signed)
    
    mov BYTE PTR [ebx].ENTITY.active, TRUE
    
    movzx eax, player.weapon
    mov BYTE PTR [ebx].ENTITY.entityType, al
    
NoSlot:
    ret
FireProjectile ENDP

; ----------------------------------------------------------------------------
; Procedure: SpawnBalloon
; Description: Spawn a new balloon at random position
; ----------------------------------------------------------------------------
SpawnBalloon PROC
    LOCAL balloonPtr:DWORD
    LOCAL i:DWORD
    
    mov i, 0
    mov balloonPtr, OFFSET balloons
    
FindSlot2:
    mov eax, i
    cmp eax, MAX_BALLOONS
    jge NoSlot2
    
    mov ebx, balloonPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je FoundSlot2
    
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp FindSlot2
    
FoundSlot2:
    mov ebx, balloonPtr
    
    ; Random X position
    invoke RandomRange, SCREEN_WIDTH
    mov [ebx].ENTITY.x, eax
    
    ; Start at top
    mov [ebx].ENTITY.y, 0
    
    ; Velocity
    mov [ebx].ENTITY.vx, 0
    mov [ebx].ENTITY.vy, 1
    
    mov BYTE PTR [ebx].ENTITY.active, TRUE
    mov BYTE PTR [ebx].ENTITY.entityType, BALLOON_RED
    
NoSlot2:
    ret
SpawnBalloon ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateProjectiles
; Description: Update all projectiles
; ----------------------------------------------------------------------------
UpdateProjectiles PROC
    LOCAL i:DWORD
    LOCAL projPtr:DWORD
    
    mov i, 0
    mov projPtr, OFFSET projectiles
    
ProjLoop:
    mov eax, i
    cmp eax, MAX_PROJECTILES
    jge ProjDone
    
    mov ebx, projPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je NextProj
    
    ; Update position
    mov eax, [ebx].ENTITY.vy
    add [ebx].ENTITY.y, eax
    
    ; Check bounds
    mov eax, [ebx].ENTITY.y
    test eax, 80000000h     ; Check if negative (signed)
    jnz DeactivateProj
    cmp eax, GAME_HEIGHT
    jge DeactivateProj
    
    jmp NextProj
    
DeactivateProj:
    mov BYTE PTR [ebx].ENTITY.active, FALSE
    
NextProj:
    add projPtr, SIZEOF ENTITY
    inc i
    jmp ProjLoop
    
ProjDone:
    ret
UpdateProjectiles ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateBalloons
; Description: Update all balloons
; ----------------------------------------------------------------------------
UpdateBalloons PROC
    LOCAL i:DWORD
    LOCAL balloonPtr:DWORD
    
    mov i, 0
    mov balloonPtr, OFFSET balloons
    
BalloonLoop:
    mov eax, i
    cmp eax, MAX_BALLOONS
    jge BalloonDone
    
    mov ebx, balloonPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je NextBalloon
    
    ; Update position
    mov eax, [ebx].ENTITY.vy
    add [ebx].ENTITY.y, eax
    
    ; Check if off screen
    mov eax, [ebx].ENTITY.y
    cmp eax, GAME_HEIGHT
    jge DeactivateBalloon
    
    jmp NextBalloon
    
DeactivateBalloon:
    mov BYTE PTR [ebx].ENTITY.active, FALSE
    ; Increment fear when balloon escapes
    inc fearMeter
    
NextBalloon:
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp BalloonLoop
    
BalloonDone:
    ret
UpdateBalloons ENDP

; ----------------------------------------------------------------------------
; Procedure: CheckCollisions
; Description: Check collisions between projectiles and balloons
; ----------------------------------------------------------------------------
CheckCollisions PROC
    LOCAL i:DWORD
    LOCAL j:DWORD
    LOCAL projPtr:DWORD
    LOCAL balloonPtr:DWORD
    
    mov i, 0
    mov projPtr, OFFSET projectiles
    
ProjLoop2:
    mov eax, i
    cmp eax, MAX_PROJECTILES
    jge CollisionDone
    
    mov ebx, projPtr
    cmp BYTE PTR [ebx]. ENTITY.active, FALSE
    je NextProj2
    
    ; Check against all balloons
    mov j, 0
    mov balloonPtr, OFFSET balloons
    
BalloonLoop2:
    mov eax, j
    cmp eax, MAX_BALLOONS
    jge NextProj2
    
    mov edi, balloonPtr
    cmp BYTE PTR [edi].ENTITY.active, FALSE
    je NextBalloon2
    
    ; Check collision
    mov eax, [ebx].ENTITY.x
    cmp eax, [edi].ENTITY.x
    jne NextBalloon2
    
    mov eax, [ebx].ENTITY.y
    cmp eax, [edi].ENTITY.y
    jne NextBalloon2
    
    ; Collision detected!
    mov BYTE PTR [ebx].ENTITY.active, FALSE
    mov BYTE PTR [edi].ENTITY.active, FALSE
    
    ; Increase score
    add player.score, 10
    
    ; Decrease fear
    mov eax, fearMeter
    sub eax, 5
    jns FearNotNegative
    xor eax, eax
FearNotNegative:
    mov fearMeter, eax
    
NextBalloon2:
    add balloonPtr, SIZEOF ENTITY
    inc j
    jmp BalloonLoop2
    
NextProj2:
    add projPtr, SIZEOF ENTITY
    inc i
    jmp ProjLoop2
    
CollisionDone:
    ret
CheckCollisions ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateGame
; Description: Main game update loop
; ----------------------------------------------------------------------------
UpdateGame PROC
    ; Update fear meter
    invoke timeGetTime
    mov ebx, eax
    sub ebx, lastFearUpdate
    cmp ebx, FEAR_INCREMENT_TIME
    jl SkipFearUpdate
    
    inc fearMeter
    invoke timeGetTime
    mov lastFearUpdate, eax
    
    ; Check game over condition
    mov eax, fearMeter
    cmp eax, FEAR_MAX
    jge GameOver
    
SkipFearUpdate:
    ; Spawn balloons periodically
    invoke timeGetTime
    mov ebx, eax
    sub ebx, balloonSpawnTimer
    cmp ebx, 2000       ; Every 2 seconds
    jl SkipSpawn
    
    call SpawnBalloon
    invoke timeGetTime
    mov balloonSpawnTimer, eax
    
SkipSpawn:
    call UpdateProjectiles
    call UpdateBalloons
    call CheckCollisions
    
    jmp UpdateDone
    
GameOver:
    mov nextState, STATE_GAMEOVER
    
UpdateDone:
    ret
UpdateGame ENDP

END
