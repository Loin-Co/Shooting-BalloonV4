; ============================================================================
; player.asm - Player Movement, Shooting, and Weapon Management
; Location: Src/GameLogic/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN player:PLAYER_STRUCT
EXTERN projectiles:ENTITY

; ============================= PUBLIC EXPORTS ===============================
PUBLIC InitPlayer
PUBLIC UpdatePlayerMovement
PUBLIC FireProjectile

; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: InitPlayer
; Description: Initialize player data
; ----------------------------------------------------------------------------
InitPlayer PROC
    mov player.x, PLAYER_START_X
    mov player.y, PLAYER_START_Y
    mov player.weapon, WEAPON_BOW
    mov player.score, 0
    mov player.lives, 3
    ret
InitPlayer ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdatePlayerMovement
; Description: Update player position based on input
; Parameters: deltaX (SDWORD), deltaY (SDWORD)
; ----------------------------------------------------------------------------
UpdatePlayerMovement PROC deltaX:SDWORD, deltaY:SDWORD
    ; Update X position
    mov eax, player.x
    add eax, deltaX
    invoke Clamp, eax, 0, SCREEN_WIDTH - 1
    mov player.x, eax
    
    ; Update Y position
    mov eax, player.y
    add eax, deltaY
    invoke Clamp, eax, 0, GAME_HEIGHT - 1
    mov player.y, eax
    
    ret
UpdatePlayerMovement ENDP

; ----------------------------------------------------------------------------
; Procedure: FireProjectile
; Description: Create a new projectile from player position
; Returns: EAX = 1 if projectile created, 0 if no slots available
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
    
    mov eax, 1      ; Success
    jmp Done
    
NoSlot:
    xor eax, eax    ; Failure
    
Done:
    ret
FireProjectile ENDP

END
