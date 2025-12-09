.686
.model flat, stdcall
option casemap:none

; ============================================================================

; IT: Welcome to Derry 2025 - BALLOON SHOOTER
; Main game file with professional loading screen and themed UI
; ============================================================================

; Windows API includes
includelib kernel32.lib
includelib user32.lib

; Function prototypes
GetStdHandle PROTO STDCALL :DWORD
SetConsoleTextAttribute PROTO STDCALL :DWORD, :WORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadConsoleInputA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD
SetConsoleCursorPosition PROTO STDCALL :DWORD, :DWORD
FillConsoleOutputCharacterA PROTO STDCALL :DWORD, :BYTE, :DWORD, :DWORD, :DWORD
FillConsoleOutputAttribute PROTO STDCALL :DWORD, :WORD, :DWORD, :DWORD, :DWORD
SetConsoleCursorInfo PROTO STDCALL :DWORD, :DWORD
Sleep PROTO STDCALL :DWORD
ExitProcess PROTO STDCALL :DWORD
lstrlenA PROTO STDCALL :DWORD

; Constants
STD_OUTPUT_HANDLE equ -11
STD_INPUT_HANDLE equ -10

; Standard CGA/VGA Colors (Reference)
BLACK equ 0
RED equ 4
BROWN equ 6
LIGHTGRAY equ 7
DARKGRAY equ 8
LIGHTRED equ 12
YELLOW equ 14
WHITE equ 15

; Thematic Semantic Colors (Main Theme)
THEME_BG equ 00h           ; Black Background
THEME_BORDER equ 0Ch       ; Light Red Text on Black (Neon look)
THEME_TEXT_MAIN equ 07h    ; Light Gray (Standard logs/info)
THEME_TEXT_ACCENT equ 0Eh  ; Yellow (High scores, Player stats)
THEME_WARNING equ 04h      ; Red (Darker red for 'Danger' text)
THEME_PLAYER equ 0Eh       ; Yellow Arrow/Archer
THEME_BALLOON_SAFE equ 0Ch ; Light Red (Matches border)
THEME_BALLOON_TRAP equ 0Fh ; Bright White (Pennywise/Anomaly)
THEME_BTN_NORMAL equ 06h   ; Brown/Orange Brackets
THEME_BTN_HOVER equ 4Fh    ; White Text on Red Background (Inverted)
THEME_PROGRESS_FILL equ 04h ; Dark Red for progress bar fill

; Game states
STATE_LOADING equ 0
STATE_MAIN_MENU equ 1
STATE_LEVEL_SELECT equ 2
STATE_GAME_MODE equ 3
STATE_INSTRUCTIONS equ 4
STATE_QUIT equ 5
STATE_PAUSED equ 6

; Structures
COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

KEY_EVENT_RECORD STRUCT
    bKeyDown DWORD ?
    wRepeatCount WORD ?
    wVirtualKeyCode WORD ?
    wVirtualScanCode WORD ?
    uChar WORD ?
    dwControlKeyState DWORD ?
KEY_EVENT_RECORD ENDS

INPUT_RECORD STRUCT
    EventType WORD ?
    Padding WORD ?
    Event KEY_EVENT_RECORD <>
INPUT_RECORD ENDS

CONSOLE_CURSOR_INFO STRUCT
    dwSize DWORD ?
    bVisible DWORD ?
CONSOLE_CURSOR_INFO ENDS

.data
    hConsoleOutput DWORD ?
    hConsoleInput DWORD ?

    ; Game state variables
    gameState DWORD STATE_LOADING
    menuSelection DWORD 0
    levelSelection DWORD 0
    playerX SWORD 40
    playerY SWORD 20
    score DWORD 0
    balloonCount DWORD 5
    highScore DWORD 1850
    deaths DWORD 42

    ; Loading screen strings
    systemHeader db ">_  DERRY MAINFRAME - v1958", 0
    systemTag db "[ SYSTEM ]", 0
    welcomeMsg db "W E L C O M E   T O   D E R R Y   2 0 2 5", 0
    protocolMsg db "[  BALLOON  SHOOTER  PROTOCOL  INITIATED  ]", 0

    ; Initialization messages
    initMsg1 db "> Loading Memory Modules...", 0
    initStatus1 db "OK", 0
    initMsg2 db "> Checking Fear Sensors...", 0
    initStatus2 db "WARNING: HIGH LEVELS", 0
    initMsg3 db "> Pennywise AI...", 0
    initStatus3 db "ACTIVE", 0
    initMsg4 db "> Loading Render.asm...", 0
    initStatus4 db "OK", 0

    ; Progress bar
    loadingResourcesMsg db "LOADING RESOURCES:", 0
    progressBarStart db "[", 0
    progressBarEnd db "]", 0
    progressPercent db "  0%", 0

    ; Quote
    pennyQuote db '"They all float down here..."', 0

    ; Main menu strings
    menuWelcome db "W E L C O M E   T O   D E R R Y", 0
    menuSubtitle db "The 8086 Arcade Edition", 0
    menuDivider db "___________________________________________", 0
    menuOption1 db ">  START GAME", 0
    menuOption1_normal db "   START GAME", 0
    menuOption2 db ">  INSTRUCTIONS", 0
    menuOption2_normal db "   INSTRUCTIONS", 0
    menuOption3 db ">  QUIT TO DOS", 0
    menuOption3_normal db "   QUIT TO DOS", 0
    
    menuHighScore db "HIGHSCORE: 1850", 0
    menuDeaths db "DEATHS: 042", 0
    menuVersion db "v1.0 | ARROWS: Move | ENTER: Select", 0

    ; Main menu options (old - keep for now)
    menuTitle db "MAIN MENU", 0

    ; Level select
    levelTitle db "SELECT DIFFICULTY", 0
    levelEasy db "1. Easy - Float Away (5 Balloons)", 0
    levelMedium db "2. Medium - Pennywise's Game (10 Balloons)", 0
    levelHard db "3. Hard - You'll Float Too (15 Balloons)", 0

    ; Instructions
    instrTitle db "INSTRUCTIONS", 0
    instrLine1 db "Use W/A/S/D or Arrow Keys to move", 0
    instrLine2 db "Press SPACE to shoot", 0
    instrLine3 db "Red balloons: Safe to pop (+10 points)", 0
    instrLine4 db "White balloons: Pennywise's traps (-20 points)", 0
    instrLine5 db "Press P to pause, ESC to quit", 0
    instrLine6 db "Pop all balloons to win!", 0

    ; Game messages
    gameTitle db "=== GAME MODE ===", 0
    scoreMsg db "Score: 0", 0
    balloonMsg db "Balloons: ", 0
    playerMsg db "Player: [*]", 0
    balloonChar db "O", 0
    pausedMsg db "*** PAUSED *** (Press P to resume)", 0

    ; Generic messages
    pressEnterMsg db "Press ENTER to select, ESC to go back", 0
    pressAnyKeyMsg db "Press any key to continue...", 0
    borderLine db "================================================================================", 0

.data?
    inputRecord INPUT_RECORD <>

    ; Allocate space for 4 DWORDs (Game state, Menu selection, Level selection, Score)
    sharedData DWORD 0, 0, 0, 0

    bytesWritten DWORD ?
    eventsRead DWORD ?
    cursorInfo CONSOLE_CURSOR_INFO <>

.code

; ============================================================================

; Helper Procedures
; ============================================================================

WriteString PROC pString:DWORD
    push eax
    push ebx
    push ecx
    push edx

    invoke lstrlenA, pString
    mov ecx, eax
    invoke WriteConsoleA, hConsoleOutput, pString, ecx, offset bytesWritten, 0

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
WriteString ENDP

WriteChar PROC character:BYTE
    LOCAL charBuf[2]:BYTE
    
    push eax
    push ecx
    
    movzx eax, character
    mov charBuf[0], al
    mov charBuf[1], 0
    
    lea eax, charBuf
    invoke WriteConsoleA, hConsoleOutput, eax, 1, offset bytesWritten, 0
    
    pop ecx
    pop eax
    ret
WriteChar ENDP

SetCursor PROC
    ; EAX = X, EBX = Y
    push edx
    mov dx, bx
    shl edx, 16
    mov dx, ax
    invoke SetConsoleCursorPosition, hConsoleOutput, edx
    pop edx
    ret
SetCursor ENDP

ClearScreen PROC
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 0
    mov ebx, 0
    call SetCursor

    mov eax, 0
    mov bx, 0
    shl ebx, 16
    mov bx, ax

    invoke FillConsoleOutputCharacterA, hConsoleOutput, ' ', 2400, ebx, offset bytesWritten
    invoke FillConsoleOutputAttribute, hConsoleOutput, THEME_BG, 2400, ebx, offset bytesWritten

    mov eax, 0
    mov ebx, 0
    call SetCursor

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ClearScreen ENDP

DrawBorder PROC
    push eax
    push ebx

    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER

    mov eax, 0
    mov ebx, 0
    call SetCursor
    invoke WriteString, offset borderLine

    mov eax, 0
    mov ebx, 24
    call SetCursor
    invoke WriteString, offset borderLine

    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    pop ebx
    pop eax
    ret
DrawBorder ENDP

; ============================================================================

; DrawASCIIBorder - Professional ASCII box border
; ============================================================================

DrawASCIIBorder PROC
    LOCAL x:DWORD
    LOCAL y:DWORD
    
    push eax
    push ebx
    push ecx
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    
    ; Top-left corner
    mov eax, 1
    mov ebx, 1
    call SetCursor
    invoke WriteChar, 218
    
    ; Top edge
    mov x, 2
topLoop:
    mov eax, x
    cmp eax, 78
    jge topDone
    mov ebx, 1
    call SetCursor
    invoke WriteChar, 196
    inc x
    jmp topLoop
topDone:
    
    ; Top-right corner
    mov eax, 78
    mov ebx, 1
    call SetCursor
    invoke WriteChar, 191
    
    ; Side edges
    mov y, 2
sideLoop:
    mov eax, y
    cmp eax, 23
    jge sideDone
    
    mov eax, 1
    mov ebx, y
    call SetCursor
    invoke WriteChar, 179
    
    mov eax, 78
    mov ebx, y
    call SetCursor
    invoke WriteChar, 179
    
    inc y
    jmp sideLoop
sideDone:
    
    ; Bottom-left corner
    mov eax, 1
    mov ebx, 23
    call SetCursor
    invoke WriteChar, 192
    
    ; Bottom edge
    mov x, 2
bottomLoop:
    mov eax, x
    cmp eax, 78
    jge bottomDone
    mov ebx, 23
    call SetCursor
    invoke WriteChar, 196
    inc x
    jmp bottomLoop
bottomDone:
    
    ; Bottom-right corner
    mov eax, 78
    mov ebx, 23
    call SetCursor
    invoke WriteChar, 217
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop ecx
    pop ebx
    pop eax
    ret
DrawASCIIBorder ENDP

; ============================================================================

; DrawMenuBox - Inner menu box for arcade-style menu
; ============================================================================

DrawMenuBox PROC
    LOCAL x:DWORD
    LOCAL y:DWORD
    
    push eax
    push ebx
    push ecx
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    ; Top-left corner
    mov eax, 18
    mov ebx, 10
    call SetCursor
    invoke WriteChar, 218
    
    ; Top edge
    mov x, 19
topLoop:
    mov eax, x
    cmp eax, 48
    jge topDone
    mov ebx, 10
    call SetCursor
    invoke WriteChar, 196
    inc x
    jmp topLoop
topDone:
    
    ; Top-right corner
    mov eax, 48
    mov ebx, 10
    call SetCursor
    invoke WriteChar, 191
    
    ; Side edges
    mov y, 11
sideLoop:
    mov eax, y
    cmp eax, 15
    jge sideDone
    
    mov eax, 18
    mov ebx, y
    call SetCursor
    invoke WriteChar, 179
    
    mov eax, 48
    mov ebx, y
    call SetCursor
    invoke WriteChar, 179
    
    inc y
    jmp sideLoop
sideDone:
    
    ; Bottom-left corner
    mov eax, 18
    mov ebx, 15
    call SetCursor
    invoke WriteChar, 192
    
    ; Bottom edge
    mov x, 19
bottomLoop:
    mov eax, x
    cmp eax, 48
    jge bottomDone
    mov ebx, 15
    call SetCursor
    invoke WriteChar, 196
    inc x
    jmp bottomLoop
bottomDone:
    
    ; Bottom-right corner
    mov eax, 48
    mov ebx, 15
    call SetCursor
    invoke WriteChar, 217
    
    pop ecx
    pop ebx
    pop eax
    ret
DrawMenuBox ENDP

; ============================================================================

; AnimateProgressBar - Smooth progress bar animation
; ============================================================================

AnimateProgressBar PROC
    LOCAL i:DWORD
    LOCAL barPos:DWORD
    LOCAL percent:DWORD
    
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    ; Draw opening bracket
    mov eax, 6
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteChar, '['
    
    mov i, 0
    mov barPos, 7
    
progressLoop:
    mov eax, i
    cmp eax, 60
    jge progressDone
    
    ; Calculate percentage
    mov eax, i
    imul eax, 100
    xor edx, edx
    mov ecx, 60
    div ecx
    mov percent, eax
    
    ; Draw character
    mov eax, barPos
    mov ebx, 20
    call SetCursor
    
    mov eax, i
    cmp eax, 40
    jl filledBlock
    
    invoke SetConsoleTextAttribute, hConsoleOutput, DARKGRAY
    invoke WriteChar, 176
    jmp showPercent
    
filledBlock:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_PROGRESS_FILL
    invoke WriteChar, 178
    
showPercent:
    ; Display percentage
    mov eax, 68
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    mov eax, percent
    call UpdatePercentString
    invoke WriteString, offset progressPercent
    
    inc barPos
    inc i
    invoke Sleep, 25
    jmp progressLoop

progressDone:
    ; Closing bracket
    mov eax, 67
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteChar, ']'
    
    ; Final 100%
    mov eax, 68
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    mov eax, 100
    call UpdatePercentString
    invoke WriteString, offset progressPercent
    invoke Sleep, 300
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
AnimateProgressBar ENDP

UpdatePercentString PROC
    ; EAX contains percentage (0-100)
    push ebx
    push ecx
    push edx
    
    mov ebx, 10
    
    cmp eax, 100
    jne notHundred
    mov BYTE PTR [progressPercent + 2], '1'
    mov BYTE PTR [progressPercent + 3], '0'
    mov BYTE PTR [progressPercent + 4], '0'
    jmp percentDone
    
notHundred:
    mov BYTE PTR [progressPercent + 2], ' '
    mov BYTE PTR [progressPercent + 3], ' '
    
    mov edx, 0
    div ebx
    push edx
    
    cmp eax, 0
    je noTens
    add al, '0'
    mov BYTE PTR [progressPercent + 3], al
    jmp getOnes
    
noTens:
    mov BYTE PTR [progressPercent + 3], ' '
    
getOnes:
    pop eax
    add al, '0'
    mov BYTE PTR [progressPercent + 4], al
    
percentDone:
    pop edx
    pop ecx
    pop ebx
    ret
UpdatePercentString ENDP

DrawBalloons PROC
    push eax
    push ebx
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_SAFE
    
    mov eax, 20
    mov ebx, 10
    call SetCursor
    invoke WriteChar, 'O'
    
    mov eax, 30
    mov ebx, 8
    call SetCursor
    invoke WriteChar, 'O'
    
    mov eax, 50
    mov ebx, 12
    call SetCursor
    invoke WriteChar, 'O'
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_TRAP
    
    mov eax, 40
    mov ebx, 15
    call SetCursor
    invoke WriteChar, 'O'
    
    mov eax, 60
    mov ebx, 9
    call SetCursor
    invoke WriteChar, 'O'
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop ebx
    pop eax
    ret
DrawBalloons ENDP

; ============================================================================

; Main Entry Point
; ============================================================================

start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hConsoleOutput, eax

    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hConsoleInput, eax
    
    ; Hide cursor
    mov cursorInfo.dwSize, 1
    mov cursorInfo.bVisible, 0
    invoke SetConsoleCursorInfo, hConsoleOutput, offset cursorInfo

; ============================================================================

; Main Game Loop
; ============================================================================

gameLoop:
    mov eax, gameState

    cmp eax, STATE_LOADING
    je doLoading

    cmp eax, STATE_MAIN_MENU
    je doMainMenu

    cmp eax, STATE_LEVEL_SELECT
    je doLevelSelect

    cmp eax, STATE_GAME_MODE
    je doGameMode

    cmp eax, STATE_INSTRUCTIONS
    je doInstructions

    cmp eax, STATE_PAUSED
    je doPaused

    cmp eax, STATE_QUIT
    je exitProgram

    jmp exitProgram

; ============================================================================

; LOADING STATE - DERRY MAINFRAME Loading Screen
; ============================================================================

doLoading:
    call ClearScreen
    call DrawASCIIBorder

    ; Header
    mov eax, 3
    mov ebx, 2
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset systemHeader

    mov eax, 56
    mov ebx, 2
    call SetCursor
    invoke WriteString, offset systemTag
    invoke Sleep, 300

    ; Welcome message
    mov eax, 18
    mov ebx, 6
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset welcomeMsg
    invoke Sleep, 400

    ; Protocol message
    mov eax, 14
    mov ebx, 8
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset protocolMsg
    invoke Sleep, 600

    ; Loading messages
    mov eax, 6
    mov ebx, 12
    call SetCursor
    invoke WriteString, offset initMsg1
    invoke Sleep, 200
    mov eax, 60
    mov ebx, 12
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset initStatus1
    invoke Sleep, 300

    mov eax, 6
    mov ebx, 13
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset initMsg2
    invoke Sleep, 200
    mov eax, 45
    mov ebx, 13
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset initStatus2
    invoke Sleep, 300

    mov eax, 6
    mov ebx, 14
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset initMsg3
    invoke Sleep, 200
    mov eax, 60
    mov ebx, 14
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteString, offset initStatus3
    invoke Sleep, 300

    mov eax, 6
    mov ebx, 15
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset initMsg4
    invoke Sleep, 200
    mov eax, 60
    mov ebx, 15
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset initStatus4
    invoke Sleep, 400

    ; Progress bar
    mov eax, 6
    mov ebx, 18
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset loadingResourcesMsg
    invoke Sleep, 200

    call AnimateProgressBar

    ; Quote
    mov eax, 6
    mov ebx, 22
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset pennyQuote
    invoke Sleep, 1200

    ; Clear screen before transitioning to menu
    call ClearScreen
    invoke Sleep, 100
    call ClearScreen
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    mov gameState, STATE_MAIN_MENU
    mov menuSelection, 0
    jmp gameLoop

; ============================================================================

; MAIN MENU STATE
; ============================================================================

doMainMenu:
    ; Ensure complete screen clear
    call ClearScreen
    invoke Sleep, 50
    call ClearScreen
    
    call DrawASCIIBorder

    ; "WELCOME TO DERRY" header
    mov eax, 18
    mov ebx, 3
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuWelcome

    ; "The 8086 Arcade Edition" subtitle
    mov eax, 22
    mov ebx, 4
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuSubtitle

    ; Divider line
    mov eax, 18
    mov ebx, 5
    call SetCursor
    invoke WriteString, offset menuDivider

    ; Draw inner menu box
    call DrawMenuBox

    ; Menu options inside the box (3 options only)
    mov eax, 20
    mov ebx, 11
    call SetCursor
    mov eax, menuSelection
    cmp eax, 0
    jne menu_opt1_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption1
    jmp menu_opt2
menu_opt1_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption1_normal

menu_opt2:
    mov eax, 20
    mov ebx, 12
    call SetCursor
    mov eax, menuSelection
    cmp eax, 1
    jne menu_opt2_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption2
    jmp menu_opt3
menu_opt2_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption2_normal

menu_opt3:
    mov eax, 20
    mov ebx, 13
    call SetCursor
    mov eax, menuSelection
    cmp eax, 2
    jne menu_opt3_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption3
    jmp menu_stats
menu_opt3_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuOption3_normal

menu_stats:
    ; HIGHSCORE and DEATHS stats
    mov eax, 18
    mov ebx, 19
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset menuHighScore

    mov eax, 36
    mov ebx, 19
    call SetCursor
    invoke WriteChar, '|'

    mov eax, 40
    mov ebx, 19
    call SetCursor
    invoke WriteString, offset menuDeaths

    ; Version and controls at bottom
    mov eax, 13
    mov ebx, 21
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset menuVersion
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    invoke Sleep, 50
    call GetMenuInput
    jmp gameLoop

; ============================================================================

; LEVEL SELECT STATE
; ============================================================================

doLevelSelect:
    call ClearScreen
    call DrawBorder

    mov eax, 28
    mov ebx, 3
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset levelTitle
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 20
    mov ebx, 8
    call SetCursor
    mov eax, levelSelection
    cmp eax, 0
    jne level_opt1_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
level_opt1_normal:
    invoke WriteString, offset levelEasy
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 20
    mov ebx, 10
    call SetCursor
    mov eax, levelSelection
    cmp eax, 1
    jne level_opt2_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
level_opt2_normal:
    invoke WriteString, offset levelMedium
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 20
    mov ebx, 12
    call SetCursor
    mov eax, levelSelection
    cmp eax, 2
    jne level_opt3_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
level_opt3_normal:
    invoke WriteString, offset levelHard
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 15
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset pressEnterMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    call GetLevelInput
    jmp gameLoop

; ============================================================================

; GAME MODE STATE
; ============================================================================

doGameMode:
    call ClearScreen
    call DrawBorder

    mov eax, 30
    mov ebx, 1
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset gameTitle
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 5
    mov ebx, 3
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset scoreMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 60
    mov ebx, 3
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset balloonMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    movsx eax, playerX
    movsx ebx, playerY
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_PLAYER
    invoke WriteString, offset playerMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    call DrawBalloons
    call GetGameInput
    jmp gameLoop

; ============================================================================

; INSTRUCTIONS STATE
; ============================================================================

doInstructions:
    call ClearScreen
    call DrawBorder

    mov eax, 28
    mov ebx, 3
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset instrTitle
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    mov eax, 15
    mov ebx, 7
    call SetCursor
    invoke WriteString, offset instrLine1

    mov eax, 15
    mov ebx, 9
    call SetCursor
    invoke WriteString, offset instrLine2

    mov eax, 15
    mov ebx, 11
    call SetCursor
    invoke WriteString, offset instrLine3

    mov eax, 15
    mov ebx, 13
    call SetCursor
    invoke WriteString, offset instrLine4

    mov eax, 15
    mov ebx, 15
    call SetCursor
    invoke WriteString, offset instrLine5

    mov eax, 15
    mov ebx, 17
    call SetCursor
    invoke WriteString, offset instrLine6

    mov eax, 22
    mov ebx, 22
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset pressAnyKeyMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    call WaitForKey
    mov gameState, STATE_MAIN_MENU
    jmp gameLoop

; ============================================================================

; PAUSED STATE
; ============================================================================

doPaused:
    mov eax, 25
    mov ebx, 12
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
    invoke WriteString, offset pausedMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    call GetPauseInput
    jmp gameLoop

; ============================================================================

; Input Handlers
; ============================================================================

GetMenuInput PROC
    push eax
    push ebx

waitMenuKey:
    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead

    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne waitMenuKey

    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je waitMenuKey

    movzx eax, inputRecord.Event.wVirtualKeyCode

    cmp eax, 57h
    je menuUp
    cmp eax, 26h
    je menuUp

    cmp eax, 53h
    je menuDown
    cmp eax, 28h
    je menuDown

    cmp eax, 0Dh
    je menuSelect

    cmp eax, 1Bh
    je menuExit

    jmp waitMenuKey

menuUp:
    mov eax, menuSelection
    cmp eax, 0
    je waitMenuKey
    dec menuSelection
    jmp menuInputDone

menuDown:
    mov eax, menuSelection
    cmp eax, 2
    je waitMenuKey
    inc menuSelection
    jmp menuInputDone

menuSelect:
    mov eax, menuSelection
    cmp eax, 0
    je selectStart
    cmp eax, 1
    je selectInstr
    cmp eax, 2
    je selectExit
    jmp menuInputDone

selectStart:
    ; Go directly to game with default settings
    mov balloonCount, 5
    mov score, 0
    mov playerX, 40
    mov playerY, 20
    mov gameState, STATE_GAME_MODE
    jmp menuInputDone

selectInstr:
    mov gameState, STATE_INSTRUCTIONS
    jmp menuInputDone

selectExit:
    mov gameState, STATE_QUIT
    jmp menuInputDone

menuExit:
    mov gameState, STATE_QUIT

menuInputDone:
    pop ebx
    pop eax
    ret
GetMenuInput ENDP

GetLevelInput PROC
    push eax

waitLevelKey:
    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead

    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne waitLevelKey

    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je waitLevelKey

    movzx eax, inputRecord.Event.wVirtualKeyCode

    cmp eax, 57h
    je levelUp
    cmp eax, 26h
    je levelUp

    cmp eax, 53h
    je levelDown
    cmp eax, 28h
    je levelDown

    cmp eax, 0Dh
    je levelSelect

    cmp eax, 1Bh
    je levelBack

    jmp waitLevelKey

levelUp:
    mov eax, levelSelection
    cmp eax, 0
    je waitLevelKey
    dec levelSelection
    jmp levelInputDone

levelDown:
    mov eax, levelSelection
    cmp eax, 2
    je waitLevelKey
    inc levelSelection
    jmp levelInputDone

levelSelect:
    mov eax, levelSelection
    cmp eax, 0
    je setEasy
    cmp eax, 1
    je setMedium
    jmp setHard

setEasy:
    mov balloonCount, 5
    jmp startGame
setMedium:
    mov balloonCount, 10
    jmp startGame
setHard:
    mov balloonCount, 15

startGame:
    mov score, 0
    mov playerX, 40
    mov playerY, 20
    mov gameState, STATE_GAME_MODE
    jmp levelInputDone

levelBack:
    mov gameState, STATE_MAIN_MENU

levelInputDone:
    pop eax
    ret
GetLevelInput ENDP

GetGameInput PROC
    push eax

    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead

    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne gameInputDone

    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je gameInputDone

    movzx eax, inputRecord.Event.wVirtualKeyCode

    cmp eax, 57h
    je moveUp
    cmp eax, 26h
    je moveUp

    cmp eax, 53h
    je moveDown
    cmp eax, 28h
    je moveDown

    cmp eax, 41h
    je moveLeft
    cmp eax, 25h
    je moveLeft

    cmp eax, 44h
    je moveRight
    cmp eax, 27h
    je moveRight

    cmp eax, 50h
    je gamePause

    cmp eax, 1Bh
    je gameExit

    jmp gameInputDone

moveUp:
    cmp playerY, 5
    jle gameInputDone
    dec playerY
    jmp gameInputDone

moveDown:
    cmp playerY, 23
    jge gameInputDone
    inc playerY
    jmp gameInputDone

moveLeft:
    cmp playerX, 2
    jle gameInputDone
    sub playerX, 2
    jmp gameInputDone

moveRight:
    cmp playerX, 70
    jge gameInputDone
    add playerX, 2
    jmp gameInputDone

gamePause:
    mov gameState, STATE_PAUSED
    jmp gameInputDone

gameExit:
    mov gameState, STATE_MAIN_MENU

gameInputDone:
    invoke Sleep, 50
    pop eax
    ret
GetGameInput ENDP

GetPauseInput PROC
    push eax

waitPauseKey:
    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead

    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne waitPauseKey

    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je waitPauseKey

    movzx eax, inputRecord.Event.wVirtualKeyCode

    cmp eax, 50h
    je resumeGame

    cmp eax, 1Bh
    je pauseExit

    jmp waitPauseKey

resumeGame:
    mov gameState, STATE_GAME_MODE
    jmp pauseInputDone

pauseExit:
    mov gameState, STATE_MAIN_MENU

pauseInputDone:
    pop eax
    ret
GetPauseInput ENDP

WaitForKey PROC
    push eax

waitKey:
    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead

    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne waitKey

    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je waitKey

    pop eax
    ret
WaitForKey ENDP

exitProgram:
    invoke ExitProcess, 0

end start
