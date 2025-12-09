; ============================================================================
; audio_mgr.asm - Audio Manager
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc

include common.inc

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC PlaySoundEffect

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; PlaySoundEffect - Play a sound effect
; Parameters: soundId (0=shoot, 1=pop, 2=scream)
; ============================================================================
PlaySoundEffect PROC dwSoundId:DWORD
    ; TODO: Implement sound playback using PlaySound API
    ; Placeholder implementation
    ret
PlaySoundEffect ENDP

end
