; ============================================================================
; game_orchestrator.asm - Main Game Update Loop Coordinator
; Location: Src/GameLogic/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN balloons:ENTITY
EXTERN projectiles:ENTITY

; ============================= PUBLIC EXPORTS ===============================
PUBLIC InitGame
PUBLIC UpdateGame

; ============================= DATA SECTION =================================
.data
    balloonSpawnTimer DWORD 0
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: InitProjectiles
; Description: Initialize projectiles array (local helper)
; ----------------------------------------------------------------------------
InitProjectiles PROC
    push edi
    push ecx
    
    mov edi, OFFSET projectiles
    mov ecx, MAX_PROJECTILES
    
ClearProjectiles:
    mov BYTE PTR [edi].ENTITY.active, FALSE
    add edi, SIZEOF ENTITY
    loop ClearProjectiles
    
    pop ecx
    pop edi
    ret
InitProjectiles ENDP

; ----------------------------------------------------------------------------
; Procedure: InitGame
; Description: Initialize all game systems
; ----------------------------------------------------------------------------
InitGame PROC
    ; Initialize player
    call InitPlayer
    
    ; Initialize balloons
    call InitBalloons
    
    ; Initialize projectiles
    call InitProjectiles
    
    ; Reset spawn timer
    invoke timeGetTime
    mov balloonSpawnTimer, eax
    
    ret
InitGame ENDP

; ----------------------------------------------------------------------------
; Procedure: AutoSpawnBalloons
; Description: Automatically spawn balloons periodically
; ----------------------------------------------------------------------------
AutoSpawnBalloons PROC
    ; Check if enough time has passed
    invoke timeGetTime
    mov ebx, eax
    sub ebx, balloonSpawnTimer
    cmp ebx, 2000       ; Every 2 seconds
    jl NoSpawn
    
    ; Spawn a balloon
    invoke SpawnBalloon, BALLOON_RED
    
    ; Reset timer
    invoke timeGetTime
    mov balloonSpawnTimer, eax
    
NoSpawn:
    ret
AutoSpawnBalloons ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateGame
; Description: Main game update loop - coordinates all game logic
; Pipeline: Spawn ? Update ? Collisions ? Logic
; ----------------------------------------------------------------------------
UpdateGame PROC
    ; Auto-spawn balloons
    call AutoSpawnBalloons
    
    ; Update all entities
    call UpdateProjectiles
    call UpdateBalloons
    
    ; Check collisions
    call CheckCollisions
    
    ; Update game logic (fear meter, win/lose conditions)
    call UpdateGameLogic
    
    ret
UpdateGame ENDP

END
