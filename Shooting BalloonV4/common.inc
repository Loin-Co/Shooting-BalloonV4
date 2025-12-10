; ============================================================================
; common.inc - Global Game Constants and Variable Declarations
; ============================================================================

include bindings.inc

; ============================= GAME CONSTANTS ===============================
SCREEN_WIDTH            equ 80
SCREEN_HEIGHT           equ 25
GAME_HEIGHT             equ 24      ; Row 24 reserved for footer
MAX_BALLOONS            equ 10
MAX_PROJECTILES         equ 20
PLAYER_START_X          equ 40
PLAYER_START_Y          equ 20
FEAR_MAX                equ 100
FEAR_INCREMENT_TIME     equ 5000    ; 5 seconds in milliseconds
FOG_DISTANCE            equ 10
MAX_LEVELS              equ 10

; ============================= GAME STATES ==================================
STATE_SPLASH            equ 0
STATE_MENU              equ 1
STATE_GAME              equ 2
STATE_PAUSE             equ 3
STATE_GAMEOVER          equ 4
STATE_VICTORY           equ 5

; ============================= WEAPON TYPES =================================
WEAPON_BOW              equ 0
WEAPON_SLINGSHOT        equ 1

; ============================= BALLOON TYPES ================================
BALLOON_RED             equ 0
BALLOON_YELLOW          equ 1
BALLOON_PENNYWISE       equ 2

; ============================= VISUAL CHARS =================================
CHAR_PLAYER             equ '@'
CHAR_BALLOON            equ 'O'
CHAR_ARROW              equ '^'
CHAR_STONE              equ '*'
CHAR_WALL               equ 219     ; ?
CHAR_EMPTY              equ ' '
CHAR_FOG                equ 177     ; ?

; ============================= COLORS =======================================
COLOR_PLAYER            equ (COLOR_LIGHT_CYAN + (COLOR_BLACK shl 4))
COLOR_BALLOON_RED       equ (COLOR_LIGHT_RED + (COLOR_BLACK shl 4))
COLOR_BALLOON_YELLOW    equ (COLOR_LIGHT_YELLOW + (COLOR_BLACK shl 4))
COLOR_ARROW             equ (COLOR_WHITE + (COLOR_BLACK shl 4))
COLOR_WALL_COLOR        equ (COLOR_GRAY + (COLOR_BLACK shl 4))
COLOR_FOOTER            equ (COLOR_BLACK + (COLOR_LIGHT_GRAY shl 4))
COLOR_GAMEOVER_BG       equ (COLOR_WHITE + (COLOR_RED shl 4))
COLOR_MENU_TITLE        equ (COLOR_LIGHT_YELLOW + (COLOR_BLACK shl 4))
COLOR_FOG_COLOR         equ (COLOR_GRAY + (COLOR_BLACK shl 4))

; ============================= DATA STRUCTURES ==============================

; Entity Structure (for balloons, projectiles)
ENTITY STRUCT
    x           DWORD ?
    y           DWORD ?
    vx          SDWORD ?    ; Velocity X (signed)
    vy          SDWORD ?    ; Velocity Y (signed)
    active      BYTE ?
    entityType  BYTE ?
    ALIGN 4
ENTITY ENDS

; Player Structure
PLAYER_STRUCT STRUCT
    x           DWORD ?
    y           DWORD ?
    weapon      BYTE ?
    score       DWORD ?
    lives       DWORD ?
    ALIGN 4
PLAYER_STRUCT ENDS

; Level Structure
LEVEL_STRUCT STRUCT
    levelNum        DWORD ?
    balloonCount    DWORD ?
    balloonSpeed    DWORD ?
    fearRate        DWORD ?
    mechanic        BYTE ?      ; 0=Normal, 1=Fog, 2=Wind, 3=Flicker, etc.
    ALIGN 4
LEVEL_STRUCT ENDS

