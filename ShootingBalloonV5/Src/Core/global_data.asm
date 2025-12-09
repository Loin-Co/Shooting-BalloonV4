; ============================================================================
; global_data.asm - Global Game Variables
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================
; This module contains all global game state variables including:
;   - Score, Lives, Fear Meter
;   - Player position
;   - Game state
;   - Menu state
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include common.inc

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC g_Score
PUBLIC g_Lives
PUBLIC g_FearMeter
PUBLIC g_GameState
PUBLIC g_PlayerX
PUBLIC g_SelectedLevel
PUBLIC g_MenuIndex
PUBLIC g_HighScore
PUBLIC g_Deaths
PUBLIC g_CurrentLevel

; ============================================================================
; DATA SECTION
; ============================================================================
.data
    ; Core Game Stats
    g_Score         dd 0
    g_Lives         dd 3
    g_FearMeter     dd 0
    g_HighScore     dd 1850
    g_Deaths        dd 0
    
    ; Game State
    g_GameState     dd 0    ; Current state (see STATE_* constants)
    g_CurrentLevel  dd 0    ; Current level being played
    g_SelectedLevel dd 0    ; Level selected in menu
    
    ; Player State
    g_PlayerX       dd 40   ; Player horizontal position (centered)
    
    ; Menu State
    g_MenuIndex     dd 0    ; Currently selected menu item

end
