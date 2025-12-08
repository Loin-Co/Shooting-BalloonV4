; ============================================================================
; global_data.asm - Global Game Variables (Score, Lives, FearMeter, Entities)
; Location: Src/Core/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc

; ============================= PUBLIC EXPORTS ===============================
PUBLIC player
PUBLIC balloons
PUBLIC projectiles
PUBLIC currentLevel
PUBLIC fearMeter

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
    
END
