; ============================================================================
; common.inc - Global Game Constants and Variable Declarations
; ============================================================================

include bindings.inc

; ============================= GAME CONSTANTS ===============================
SCREEN_WIDTH            equ 100     ; Reduced from 120 to fit better
SCREEN_HEIGHT           equ 35      ; Reduced from 40 to fit better
BUFFER_SIZE             equ SCREEN_WIDTH * SCREEN_HEIGHT
GAME_HEIGHT             equ 33      ; Row 33-34 reserved for HUD/footer
MAX_BALLOONS            equ 10
MAX_PROJECTILES         equ 20
PLAYER_START_X          equ 50      ; Centered (was 60)
PLAYER_START_Y          equ 28      ; Lower position for bigger screen (was 32)
FEAR_MAX                equ 100
FEAR_INCREMENT_TIME     equ 5000    ; 5 seconds in milliseconds
FOG_DISTANCE            equ 10
MAX_LEVELS              equ 10

; ============================= GAME STATES ==================================
STATE_SPLASH            equ 0
STATE_MENU              equ 1
STATE_LEVEL_SELECT      equ 2
STATE_GAME              equ 3
STATE_PAUSE             equ 4
STATE_GAMEOVER          equ 5
STATE_VICTORY           equ 6

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

; ============================= THEMATIC COLORS (Retro Horror Red & Black) ===
; Philosophy: The screen is a dark computer terminal. Only vital info is lit up.
; Hierarchy: Primary=Light Red (Structure/Enemies), Secondary=Yellow (Player/Score),
;            Tertiary=Light Gray (Flavor), Alert=White on Red (Selections/Jumpscares)

THEME_BG                equ 00h     ; Black Background
THEME_BORDER            equ 0Ch     ; Light Red Text on Black (Neon look)
THEME_TEXT_MAIN         equ 07h     ; Light Gray (Standard logs/info)
THEME_TEXT_ACCENT       equ 0Eh     ; Yellow (High scores, Player stats)
THEME_WARNING           equ 04h     ; Red (Darker red for 'Danger' text)
THEME_PLAYER            equ 0Eh     ; Yellow Arrow/Archer
THEME_BALLOON_SAFE      equ 0Ch     ; Light Red (Matches border)
THEME_BALLOON_TRAP      equ 0Fh     ; Bright White (Pennywise/Anomaly)
THEME_BTN_NORMAL        equ 06h     ; Brown/Orange Brackets
THEME_BTN_HOVER         equ 4Fh     ; White Text on Red Background (Inverted)

; ============================= LEGACY COLORS (For Compatibility) ============
COLOR_PLAYER            equ THEME_PLAYER
COLOR_BALLOON_RED       equ THEME_BALLOON_SAFE
COLOR_BALLOON_YELLOW    equ (COLOR_LIGHT_YELLOW + (COLOR_BLACK shl 4))
COLOR_ARROW             equ (COLOR_WHITE + (COLOR_BLACK shl 4))
COLOR_WALL_COLOR        equ (COLOR_GRAY + (COLOR_BLACK shl 4))
COLOR_FOOTER            equ (COLOR_BLACK + (COLOR_LIGHT_GRAY shl 4))
COLOR_GAMEOVER_BG       equ THEME_BTN_HOVER
COLOR_MENU_TITLE        equ THEME_BORDER
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

