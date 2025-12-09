; ============================================================================
; collision.asm - Collision Detection
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include kernel32.inc

includelib kernel32.lib

include common.inc
include protos.inc

; ============================================================================
; EXTERNAL REFERENCES
; ============================================================================
EXTERN g_GameState:DWORD

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC CheckCollision
PUBLIC TriggerJumpscare

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; CheckCollision - Check for arrow-balloon collisions
; ============================================================================
CheckCollision PROC
    ; TODO: Implement collision detection
    ; Placeholder implementation
    ret
CheckCollision ENDP

; ============================================================================
; TriggerJumpscare - Execute jumpscare sequence
; ============================================================================
TriggerJumpscare PROC
    ; Play scream sound
    ; invoke PlaySoundEffect, SOUND_SCREAM
    
    ; Flash the screen (handled by caller)
    
    ; Set game state to jumpscare
    mov g_GameState, STATE_JUMPSCARE
    
    ret
TriggerJumpscare ENDP

end
