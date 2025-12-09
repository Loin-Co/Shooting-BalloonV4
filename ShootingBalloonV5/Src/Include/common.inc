; ============================================================================
; common.inc - Common Constants and Structures
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

; Standard CGA/VGA Colors (Reference)
BLACK        EQU 0
BLUE         EQU 1
GREEN        EQU 2
CYAN         EQU 3
RED          EQU 4
MAGENTA      EQU 5
BROWN        EQU 6   ; Used as Dark Orange
LIGHTGRAY    EQU 7
DARKGRAY     EQU 8
LIGHTBLUE    EQU 9
LIGHTGREEN   EQU 10
LIGHTCYAN    EQU 11
LIGHTRED     EQU 12  ; The main Neon Red
LIGHTMAGENTA EQU 13
YELLOW       EQU 14
WHITE        EQU 15

; Thematic Semantic Colors (Use These in Code)
THEME_BG           EQU 00h  ; Black Background
THEME_BORDER       EQU 0Ch  ; Light Red Text on Black (Neon look)
THEME_TEXT_MAIN    EQU 07h  ; Light Gray (Standard logs/info)
THEME_TEXT_ACCENT  EQU 0Eh  ; Yellow (High scores, Player stats)
THEME_WARNING      EQU 04h  ; Red (Darker red for 'Danger' text)
THEME_PLAYER       EQU 0Eh  ; Yellow Arrow/Archer
THEME_BALLOON_SAFE EQU 0Ch  ; Light Red (Matches border)
THEME_BALLOON_TRAP EQU 0Fh  ; Bright White (Pennywise/Anomaly)
THEME_BTN_NORMAL   EQU 06h  ; Brown/Orange Brackets
THEME_BTN_HOVER    EQU 4Fh  ; White Text on Red Background (Inverted)

; Screen Constants
SCREEN_WIDTH       EQU 80
SCREEN_HEIGHT      EQU 25
BUFFER_SIZE        EQU SCREEN_WIDTH * SCREEN_HEIGHT

; Game Constants
PLAYER_Y           EQU 23
MAX_ARROWS         EQU 10
MAX_BALLOONS       EQU 5
TARGET_FPS         EQU 60
FRAME_TIME_MS      EQU 16   ; ~60 FPS (1000/60)

; Game States
STATE_SPLASH       EQU 0
STATE_MENU         EQU 1
STATE_LEVEL_SELECT EQU 2
STATE_INSTRUCTIONS EQU 2  ; Alias - repurposed for instructions screen
STATE_PLAYING      EQU 3
STATE_PAUSED       EQU 4
STATE_GAME_OVER    EQU 5
STATE_JUMPSCARE    EQU 6
STATE_EXIT         EQU 7

; Virtual Key Codes
VK_LEFT            EQU 25h
VK_UP              EQU 26h
VK_RIGHT           EQU 27h
VK_DOWN            EQU 28h
VK_RETURN          EQU 0Dh
VK_ESCAPE          EQU 1Bh
VK_SPACE           EQU 20h

; Balloon Types
BALLOON_SAFE       EQU 0
BALLOON_BONUS      EQU 1
BALLOON_TRAP       EQU 2

; Console CHAR_INFO Structure
IFNDEF CHAR_INFO
CHAR_INFO STRUCT
    UnicodeChar WORD ?
    Attributes  WORD ?
CHAR_INFO ENDS
ENDIF

; Game Entity Structures
ARROW STRUCT
    Active  BYTE ?
    X       WORD ?
    Y       WORD ?
ARROW ENDS

BALLOON STRUCT
    Active   BYTE ?
    BType    BYTE ?
    X        WORD ?
    Y        WORD ?
    VelX     SWORD ?
BALLOON ENDS

; Rectangle Structure
RECT STRUCT
    Left    WORD ?
    Top     WORD ?
    Right   WORD ?
    Bottom  WORD ?
RECT ENDS
