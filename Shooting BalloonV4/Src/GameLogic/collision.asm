; ============================================================================
; collision.asm - Collision Detection and Game Logic
; Location: Src/GameLogic/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN player:PLAYER_STRUCT
EXTERN balloons:ENTITY
EXTERN projectiles:ENTITY
EXTERN fearMeter:DWORD
EXTERN nextState:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC UpdateProjectiles
PUBLIC CheckCollisions
PUBLIC UpdateGameLogic

; ============================= DATA SECTION =================================
.data
    lastFearUpdate      DWORD 0
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: UpdateProjectiles
; Description: Update all active projectiles (movement & bounds checking)
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
    
    ; Update position (apply velocity)
    mov eax, [ebx].ENTITY.vy
    add [ebx].ENTITY.y, eax
    
    mov eax, [ebx].ENTITY.vx
    add [ebx].ENTITY.x, eax
    
    ; Check bounds (Y axis)
    mov eax, [ebx].ENTITY.y
    test eax, 80000000h     ; Check if negative (signed)
    jnz DeactivateProj
    cmp eax, GAME_HEIGHT
    jge DeactivateProj
    
    ; Check bounds (X axis)
    mov eax, [ebx].ENTITY.x
    cmp eax, SCREEN_WIDTH
    jge DeactivateProj
    test eax, 80000000h
    jnz DeactivateProj
    
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
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
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
    
    ; Check collision (X coordinate)
    mov eax, [ebx].ENTITY.x
    cmp eax, [edi].ENTITY.x
    jne NextBalloon2
    
    ; Check collision (Y coordinate)
    mov eax, [ebx].ENTITY.y
    cmp eax, [edi].ENTITY.y
    jne NextBalloon2
    
    ; ===== COLLISION DETECTED! =====
    
    ; Deactivate both entities
    mov BYTE PTR [ebx].ENTITY.active, FALSE
    mov BYTE PTR [edi].ENTITY.active, FALSE
    
    ; Increase score
    add player.score, 10
    
    ; Decrease fear meter (reward for popping balloon)
    mov eax, fearMeter
    sub eax, 5
    jns FearNotNegative
    xor eax, eax        ; Clamp to 0
FearNotNegative:
    mov fearMeter, eax
    
    ; TODO: Play sound effect here
    ; invoke PlaySoundEffect, SOUND_POP
    
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
; Procedure: UpdateGameLogic
; Description: Main game logic update (fear meter, win/lose conditions)
; ----------------------------------------------------------------------------
UpdateGameLogic PROC
    ; Update fear meter over time
    invoke timeGetTime
    mov ebx, eax
    sub ebx, lastFearUpdate
    cmp ebx, FEAR_INCREMENT_TIME
    jl SkipFearUpdate
    
    ; Increment fear
    inc fearMeter
    invoke timeGetTime
    mov lastFearUpdate, eax
    
    ; Check game over condition (fear too high)
    mov eax, fearMeter
    cmp eax, FEAR_MAX
    jge GameOver
    
SkipFearUpdate:
    ; Check if player lost all lives
    mov eax, player.lives
    test eax, eax
    jz GameOver
    
    jmp UpdateDone
    
GameOver:
    mov nextState, STATE_GAMEOVER
    
UpdateDone:
    ret
UpdateGameLogic ENDP

END
