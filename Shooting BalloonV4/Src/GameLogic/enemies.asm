; ============================================================================
; enemies.asm - Balloon Spawning, Movement, and AI
; Location: Src/GameLogic/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN balloons:ENTITY
EXTERN fearMeter:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC InitBalloons
PUBLIC SpawnBalloon
PUBLIC UpdateBalloons

; ============================= DATA SECTION =================================
.data
    balloonSpawnTimer DWORD 0
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: InitBalloons
; Description: Initialize balloon array (clear all)
; ----------------------------------------------------------------------------
InitBalloons PROC
    push edi
    push ecx
    
    mov edi, OFFSET balloons
    mov ecx, MAX_BALLOONS
    
ClearBalloons:
    mov BYTE PTR [edi].ENTITY.active, FALSE
    add edi, SIZEOF ENTITY
    loop ClearBalloons
    
    ; Reset spawn timer
    invoke timeGetTime
    mov balloonSpawnTimer, eax
    
    pop ecx
    pop edi
    ret
InitBalloons ENDP

; ----------------------------------------------------------------------------
; Procedure: SpawnBalloon
; Description: Spawn a new balloon at random position
; Parameters: Optional balloonType (DWORD) - defaults to BALLOON_RED
; Returns: EAX = 1 if spawned, 0 if no slots
; ----------------------------------------------------------------------------
SpawnBalloon PROC balloonType:DWORD
    LOCAL balloonPtr:DWORD
    LOCAL i:DWORD
    
    mov i, 0
    mov balloonPtr, OFFSET balloons
    
FindSlot:
    mov eax, i
    cmp eax, MAX_BALLOONS
    jge NoSlot
    
    mov ebx, balloonPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je FoundSlot
    
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp FindSlot
    
FoundSlot:
    mov ebx, balloonPtr
    
    ; Random X position
    invoke RandomRange, SCREEN_WIDTH
    mov [ebx].ENTITY.x, eax
    
    ; Start at top
    mov [ebx].ENTITY.y, 0
    
    ; Velocity (move down)
    mov [ebx].ENTITY.vx, 0
    mov [ebx].ENTITY.vy, 1
    
    mov BYTE PTR [ebx].ENTITY.active, TRUE
    
    ; Set balloon type
    mov eax, balloonType
    test eax, eax
    jz DefaultType
    mov BYTE PTR [ebx].ENTITY.entityType, al
    jmp TypeSet
    
DefaultType:
    mov BYTE PTR [ebx].ENTITY.entityType, BALLOON_RED
    
TypeSet:
    mov eax, 1      ; Success
    jmp Done
    
NoSlot:
    xor eax, eax    ; Failure
    
Done:
    ret
SpawnBalloon ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateBalloons
; Description: Update all active balloons (movement & bounds checking)
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
    
    ; Update position (apply velocity)
    mov eax, [ebx].ENTITY.vy
    add [ebx].ENTITY.y, eax
    
    mov eax, [ebx].ENTITY.vx
    add [ebx].ENTITY.x, eax
    
    ; Check if off screen (bottom)
    mov eax, [ebx].ENTITY.y
    cmp eax, GAME_HEIGHT
    jge BalloonEscaped
    
    ; Check if off screen (sides)
    mov eax, [ebx].ENTITY.x
    cmp eax, SCREEN_WIDTH
    jge DeactivateBalloon
    test eax, 80000000h     ; Check if negative
    jnz DeactivateBalloon
    
    jmp NextBalloon
    
BalloonEscaped:
    ; Balloon escaped - increase fear
    inc fearMeter
    jmp DeactivateBalloon
    
DeactivateBalloon:
    mov BYTE PTR [ebx].ENTITY.active, FALSE
    
NextBalloon:
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp BalloonLoop
    
BalloonDone:
    ret
UpdateBalloons ENDP

END
