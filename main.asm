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
includelib winmm.lib

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
PlaySoundA PROTO STDCALL :DWORD, :DWORD, :DWORD
GetTickCount PROTO STDCALL

; Constants
STD_OUTPUT_HANDLE equ -11
STD_INPUT_HANDLE equ -10

; Sound flags for PlaySound
SND_FILENAME equ 00020000h
SND_ASYNC equ 00000001h
SND_NODEFAULT equ 00000002h

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
STATE_GAME_OVER equ 7

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

    ; === NEW GAME MODE VARIABLES ===
    fearLevel DWORD 45           ; Current fear level (0-100)
    ammoCount DWORD 7            ; Current ammo
    maxAmmo DWORD 20             ; Maximum ammo capacity
    balloonsLeft DWORD 4         ; Balloons remaining in level
    currentLevel DWORD 1         ; Current level number
    gameOverReason DWORD 0       ; 0=OutOfAmmo, 1=FearDeath
    lastAmmoCount DWORD 7        ; Track ammo from last frame
    
    ; Sound control variables
    lastFearLevel DWORD 0        ; Track fear level changes
    lastScareTime DWORD 0        ; Prevent sound spam
    
    ; Sound file paths (MUST BE .WAV FILES - PlaySound API only supports WAV format!)
    ; Place these WAV files in your Debug folder
    soundScare1 db "laugh1.wav", 0
    soundScare2 db "scare1.wav", 0
    soundScare3 db "laugh2.wav", 0
    soundScare4 db "scare3.wav", 0
    soundScream db "scream.wav", 0
    
    ; Array of scare sound pointers
    scareSounds dd offset soundScare1, offset soundScare2, offset soundScare3, offset soundScare4
    numScareSounds DWORD 4
    
    ; Balloon data (max 10 balloons)
    balloonX SWORD 35, 50, 65, 40, 0, 0, 0, 0, 0, 0
    balloonY SWORD 5, 7, 9, 11, 0, 0, 0, 0, 0, 0
    balloonType BYTE 0, 0, 1, 0, 0, 0, 0, 0, 0, 0  ; 0=Red(safe), 1=Yellow(trap)
    balloonActive BYTE 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
    balloonDirX SWORD 1, -1, 1, -1, 0, 0, 0, 0, 0, 0  ; Movement direction
    
    ; Arrow data
    arrowActive BYTE 0           ; Is arrow in flight?
    arrowX SWORD 0
    arrowY SWORD 0
    
    ; Frame counter for balloon movement
    frameCounter DWORD 0
    
    ; UI Strings for Game Mode
    uiMenuLabel db "MENU", 0
    uiScoreLabel db "SCORE", 0
    uiAmmoLabel db "AMMO", 0
    uiFearLabel db "FEAR LEVEL", 0
    uiBalloonsLabel db "BALLOONS", 0
    uiLogLabel db "LOG", 0
    
    ; Level display
    levelNameDisplay db "LEVEL  1: THE BARRENS", 0
    
    ; Score display (updated dynamically)
    scoreDisplay db "004450", 0
    
    ; Ammo visual (lightning bolts)
    ammoSymbol db 4, 0           ; ASCII diamond/lightning
    ammoCountDisplay db "x07", 0
    
    ; Fear percentage display
    fearPercentDisplay db "45%", 0
    fearStatusCalm db "[ CALM ]", 0
    fearStatusRising db "[ RISING ]", 0
    fearStatusHigh db "[ HIGH! ]", 0
    fearStatusPanic db "[ PANIC! ]", 0
    
    ; Balloons remaining
    balloonsDisplay db "4 Left", 0
    balloonFloating db "Floating...", 0
    balloonSymbol db 7, 0        ; ASCII bullet/circle for balloon icon
    
    ; Log messages (ring buffer of 3 messages)
    logMsg1 db "> Level Start...", 0
    logMsg2 db "> Missed Shot!", 0
    logMsg3 db "> Fear +5%", 0
    
    ; Controls display
    controlsDisplay db "[SPACE]: SHOOT   [ARROWS]: MOVE   [P]: PAUSE", 0
    
    ; Wrong balloon indicator
    wrongBalloonMsg db "@ <--- (Wrong Ball/Trap)", 0
    
    ; Arrow character
    arrowUpChar db '^', 0
    arrowChar db '|', 0
    
    ; Archer display
    archerDisplay db "A  (Archer)", 0

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

    ; Level select - NEW DESIGN
    levelSelectHeader db "BACK", 0
    levelSelectTitle db "SELECT LOCATION", 0
    levelDivider db "_____________________________________________", 0
    
    ; Level names and details
    level1Name db "1. THE BARRENS (Easy)", 0
    level1Stars db "[ * * * ]", 0
    level1Best db "BEST: 450", 0
    
    level2Name db "2. NEIBOLT STREET (Easy)", 0
    level2Stars db "[ * * * ]", 0
    level2Best db "BEST: 380", 0
    
    level3Name db "3. DERRY CARNIVAL (Med)", 0
    level3Stars db "[ * * * ]", 0
    level3Best db "BEST: 290", 0
    
    level4Name db "4. CANAL DAYS (Med)", 0
    level4Locked db "[ LOCKED ]", 0
    
    level5Name db "5. THE SEWERS (Hard)", 0
    level5Locked db "[ LOCKED ]", 0
    
    level6Name db "6. IT'S LAIR (Expert)", 0
    level6Locked db "[ LOCKED ]", 0
    
    levelPrompt db "[ PRESS ENTER TO PLAY ]", 0
    
    ; Level unlocked status (0 = locked, 1 = unlocked)
    levelUnlocked db 1, 0, 0, 0, 0, 0

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

    ; Game Over messages
    gameOverTitle db "G A M E   O V E R", 0
    outOfAmmoMsg db "OUT OF AMMO!", 0
    outOfAmmoSub db "You ran out of arrows to fight IT...", 0
    fearDeathMsg db "FEAR OVERWHELMED YOU!", 0
    fearDeathSub db "The entity consumed your sanity...", 0
    finalScoreMsg db "FINAL SCORE", 0
    returnMenuMsg db "Press ENTER to return to Main Menu", 0

    ; ==================================================
    ; SCROLLING TEXT DATA
    ; ==================================================
    scrollLine01 db "DERRY, MAINE. 2025.", 0
    scrollLine02 db " ", 0
    scrollLine03 db "Twenty-seven years have passed.", 0
    scrollLine04 db "The sewers echo once more.", 0
    scrollLine05 db "IT has awakened.", 0
    scrollLine06 db " ", 0
    scrollLine07 db "--- MISSION OBJECTIVES ---", 0
    scrollLine08 db " ", 0
    scrollLine09 db "1. SURVIVE THE CARNIVAL", 0
    scrollLine10 db "Use Arrow Keys to move.", 0
    scrollLine11 db "Press SPACE to shoot.", 0
    scrollLine12 db " ", 0
    scrollLine13 db "2. MANAGE YOUR FEAR", 0
    scrollLine14 db "Pop RED balloons for points.", 0
    scrollLine15 db "If fear reaches 100%... YOU DIE.", 0
    scrollLine16 db " ", 0
    scrollLine17 db "3. AVOID THE TRAP", 0
    scrollLine18 db "Do NOT shoot the blinking anomaly.", 0
    scrollLine19 db "If you do... You will float too.", 0
    scrollLine20 db " ", 0
    scrollLine21 db "GOOD LUCK, ARCHER.", 0

    ; Pointers for the loop
    scrollPtrs dd offset scrollLine01, offset scrollLine02, offset scrollLine03, offset scrollLine04
               dd offset scrollLine05, offset scrollLine06, offset scrollLine07, offset scrollLine08
               dd offset scrollLine09, offset scrollLine10, offset scrollLine11, offset scrollLine12
               dd offset scrollLine13, offset scrollLine14, offset scrollLine15, offset scrollLine16
               dd offset scrollLine17, offset scrollLine18, offset scrollLine19, offset scrollLine20
               dd offset scrollLine21
    numScrollLines DWORD 21
    scrollBaseY SDWORD 22  ; Start appearing at bottom of box

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

WriteRepeatedChar PROC uses eax ecx character:BYTE, count:DWORD
    mov ecx, count
repeatLoop:
    cmp ecx, 0
    jle repeatDone
    invoke WriteChar, character
    dec ecx
    jmp repeatLoop
repeatDone:
    ret
WriteRepeatedChar ENDP

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
; CenterText - Centers a string at a given Y position
; ============================================================================

CenterText PROC uses eax ebx ecx stringOffset:DWORD, yPos:DWORD, colorAttr:WORD
    LOCAL len:DWORD
    LOCAL xPos:DWORD
    
    invoke lstrlenA, stringOffset
    mov len, eax
    
    ; Calculate X = (80 - Length) / 2
    mov eax, 80
    sub eax, len
    shr eax, 1
    mov xPos, eax
    
    mov eax, xPos
    mov ebx, yPos
    call SetCursor
    
    invoke SetConsoleTextAttribute, hConsoleOutput, colorAttr
    invoke WriteString, stringOffset
    
    ret
CenterText ENDP

; ============================================================================
; SOUND PROCEDURES
; ============================================================================

PlayRandomScareSound PROC
    push eax
    push ebx
    push ecx
    push edx
    
    ; Check if enough time has passed since last sound (prevent spam)
    invoke GetTickCount
    mov ebx, eax
    sub ebx, lastScareTime
    cmp ebx, 2000  ; At least 2 seconds between sounds
    jl skipScareSound
    
    ; Update last scare time
    mov lastScareTime, eax
    
    ; Generate pseudo-random index based on tick count
    invoke GetTickCount
    xor edx, edx
    mov ebx, numScareSounds
    div ebx
    ; EDX now contains random index (0-3)
    
    ; Get sound file pointer
    shl edx, 2  ; Multiply by 4 (DWORD size)
    lea ebx, scareSounds
    add ebx, edx
    mov eax, [ebx]
    
    ; Play sound asynchronously
    invoke PlaySoundA, eax, 0, SND_FILENAME or SND_ASYNC or SND_NODEFAULT
    
skipScareSound:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
PlayRandomScareSound ENDP

PlayScreamSound PROC
    push eax
    
    ; Play scream sound (synchronous for dramatic effect)
    invoke PlaySoundA, offset soundScream, 0, SND_FILENAME or SND_NODEFAULT
    
    pop eax
    ret
PlayScreamSound ENDP

StopAllSounds PROC
    push eax
    
    ; Stop any playing sounds
    invoke PlaySoundA, 0, 0, 0
    
    pop eax
    ret
StopAllSounds ENDP

; ============================================================================
; GAME MODE UI PROCEDURES
; ============================================================================

DrawUIBox PROC uses eax ebx ecx xPos:DWORD, yPos:DWORD, boxWidth:DWORD, boxHeight:DWORD
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL i:DWORD
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    
    ; Top-left corner
    mov eax, xPos
    mov ebx, yPos
    call SetCursor
    invoke WriteChar, 218
    
    ; Top edge
    mov i, 1
topEdge:
    mov eax, i
    cmp eax, boxWidth
    jge topEdgeDone
    
    mov eax, xPos
    add eax, i
    mov ebx, yPos
    call SetCursor
    invoke WriteChar, 196
    
    inc i
    jmp topEdge
topEdgeDone:
    
    ; Top-right corner
    mov eax, xPos
    add eax, boxWidth
    mov ebx, yPos
    call SetCursor
    invoke WriteChar, 191
    
    ; Side edges
    mov i, 1
sideEdges:
    mov eax, i
    cmp eax, boxHeight
    jge sideEdgesDone
    
    ; Left edge
    mov eax, xPos
    mov ebx, yPos
    add ebx, i
    call SetCursor
    invoke WriteChar, 179
    
    ; Right edge
    mov eax, xPos
    add eax, boxWidth
    mov ebx, yPos
    add ebx, i
    call SetCursor
    invoke WriteChar, 179
    
    inc i
    jmp sideEdges
sideEdgesDone:
    
    ; Bottom-left corner
    mov eax, xPos
    mov ebx, yPos
    add ebx, boxHeight
    call SetCursor
    invoke WriteChar, 192
    
    ; Bottom edge
    mov i, 1
bottomEdge:
    mov eax, i
    cmp eax, boxWidth
    jge bottomEdgeDone
    
    mov eax, xPos
    add eax, i
    mov ebx, yPos
    add ebx, boxHeight
    call SetCursor
    invoke WriteChar, 196
    
    inc i
    jmp bottomEdge
bottomEdgeDone:
    
    ; Bottom-right corner
    mov eax, xPos
    add eax, boxWidth
    mov ebx, yPos
    add ebx, boxHeight
    call SetCursor
    invoke WriteChar, 217
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    ret
DrawUIBox ENDP

DrawLeftPanel PROC
    ; Draw MENU box
    invoke DrawUIBox, 2, 1, 14, 3
    mov eax, 4
    mov ebx, 2
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset uiMenuLabel
    
    ; Draw SCORE box
    invoke DrawUIBox, 2, 4, 14, 3
    mov eax, 4
    mov ebx, 5
    call SetCursor
    invoke WriteString, offset uiScoreLabel
    mov eax, 4
    mov ebx, 6
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset scoreDisplay
    
    ; Draw AMMO box
    invoke DrawUIBox, 2, 7, 14, 4
    mov eax, 4
    mov ebx, 8
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset uiAmmoLabel
    call DrawAmmoDisplay
    
    ; Draw FEAR LEVEL box
    invoke DrawUIBox, 2, 11, 14, 6
    mov eax, 4
    mov ebx, 12
    call SetCursor
    invoke WriteString, offset uiFearLabel
    call DrawFearBar
    
    ; Draw BALLOONS box
    invoke DrawUIBox, 2, 17, 14, 4
    mov eax, 4
    mov ebx, 18
    call SetCursor
    invoke WriteString, offset uiBalloonsLabel
    call DrawBalloonsPanel
    
    ; Draw LOG box
    invoke DrawUIBox, 2, 21, 14, 3
    mov eax, 4
    mov ebx, 22
    call SetCursor
    invoke WriteString, offset uiLogLabel
    
    ret
DrawLeftPanel ENDP

DrawAmmoDisplay PROC
    LOCAL i:DWORD
    push eax
    push ebx
    push ecx
    
    ; Draw lightning bolt symbols (max 10 visible)
    mov eax, 4
    mov ebx, 9
    call SetCursor
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    
    mov ecx, ammoCount
    cmp ecx, 10
    jle ammoOk
    mov ecx, 10
ammoOk:
    mov i, 0
ammoLoop:
    mov eax, i
    cmp eax, ecx
    jge ammoLoopDone
    
    invoke WriteChar, 4  ; Diamond character
    invoke WriteChar, ' '
    
    inc i
    jmp ammoLoop
ammoLoopDone:
    
    ; Display count on next line
    mov eax, 4
    mov ebx, 10
    call SetCursor
    
    ; Update ammo count display
    call UpdateAmmoString
    invoke WriteString, offset ammoCountDisplay
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop ecx
    pop ebx
    pop eax
    ret
DrawAmmoDisplay ENDP

UpdateAmmoString PROC
    push eax
    push ebx
    push edx
    
    mov eax, ammoCount
    mov ebx, 10
    xor edx, edx
    div ebx
    
    ; Tens digit
    add al, '0'
    mov BYTE PTR [ammoCountDisplay + 1], al
    
    ; Ones digit
    mov eax, edx
    add al, '0'
    mov BYTE PTR [ammoCountDisplay + 2], al
    
    pop edx
    pop ebx
    pop eax
    ret
UpdateAmmoString ENDP

DrawFearBar PROC
    LOCAL blocks:DWORD
    LOCAL i:DWORD
    push eax
    push ebx
    push ecx
    
    ; Update fear percentage display
    call UpdateFearString
    
    ; Display percentage
    mov eax, 4
    mov ebx, 13
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset fearPercentDisplay
    
    ; Draw progress bar (10 blocks)
    mov eax, 4
    mov ebx, 14
    call SetCursor
    
    ; Calculate blocks: fearLevel / 10
    mov eax, fearLevel
    mov ebx, 10
    xor edx, edx
    div ebx
    mov blocks, eax
    
    mov i, 0
barLoop:
    mov eax, i
    cmp eax, 10
    jge barDone
    
    cmp eax, blocks
    jge emptyBlock
    
    ; Filled block
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteChar, 219  ; Solid block
    jmp nextBlock
    
emptyBlock:
    invoke SetConsoleTextAttribute, hConsoleOutput, DARKGRAY
    invoke WriteChar, 176  ; Light shade
    
nextBlock:
    inc i
    jmp barLoop
    
barDone:
    ; Display status
    mov eax, 4
    mov ebx, 15
    call SetCursor
    
    ; Determine status based on fear level
    mov eax, fearLevel
    cmp eax, 75
    jge panicStatus
    cmp eax, 50
    jge highStatus
    cmp eax, 25
    jge risingStatus
    
    ; Calm
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset fearStatusCalm
    jmp fearStatusDone
    
risingStatus:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset fearStatusRising
    jmp fearStatusDone
    
highStatus:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteString, offset fearStatusHigh
    jmp fearStatusDone
    
panicStatus:
    invoke SetConsoleTextAttribute, hConsoleOutput, 4Fh  ; Blinking red
    invoke WriteString, offset fearStatusPanic
    
fearStatusDone:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop ecx
    pop ebx
    pop eax
    ret
DrawFearBar ENDP

UpdateFearString PROC
    push eax
    push ebx
    push edx
    
    mov eax, fearLevel
    
    ; Handle 100%
    cmp eax, 100
    jne notHundred
    mov BYTE PTR [fearPercentDisplay], '1'
    mov BYTE PTR [fearPercentDisplay + 1], '0'
    mov BYTE PTR [fearPercentDisplay + 2], '0'
    jmp fearStringDone
    
notHundred:
    ; Tens digit
    mov ebx, 10
    xor edx, edx
    div ebx
    
    cmp eax, 0
    je noTens
    add al, '0'
    mov BYTE PTR [fearPercentDisplay], al
    jmp getOnes
    
noTens:
    mov BYTE PTR [fearPercentDisplay], ' '
    
getOnes:
    mov eax, edx
    add al, '0'
    mov BYTE PTR [fearPercentDisplay + 1], al
    mov BYTE PTR [fearPercentDisplay + 2], '%'
    
fearStringDone:
    pop edx
    pop ebx
    pop eax
    ret
UpdateFearString ENDP

DrawBalloonsPanel PROC
    push eax
    push ebx
    
    mov eax, 4
    mov ebx, 19
    call SetCursor
    
    ; Update balloons left string
    call UpdateBalloonsString
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset balloonsDisplay
    
    mov eax, 4
    mov ebx, 20
    call SetCursor
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_SAFE
    invoke WriteChar, 7  ; Bullet/circle
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteChar, ' '
    invoke WriteString, offset balloonFloating
    
    pop ebx
    pop eax
    ret
DrawBalloonsPanel ENDP

UpdateBalloonsString PROC
    push eax
    
    mov eax, balloonsLeft
    add al, '0'
    mov BYTE PTR [balloonsDisplay], al
    
    pop eax
    ret
UpdateBalloonsString ENDP

UpdateScoreDisplay PROC
    push eax
    push ebx
    push ecx
    push edx
    push edi
    
    mov eax, score
    mov ebx, 10
    mov ecx, 5  ; 6 digits, process from right to left
    
    lea edi, scoreDisplay
    add edi, 5  ; Start from last digit
    
scoreDigitLoop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    dec ecx
    cmp ecx, 0
    jge scoreDigitLoop
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateScoreDisplay ENDP

DrawLogMessages PROC
    push eax
    push ebx
    
    mov eax, 3
    mov ebx, 22
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteChar, '>';
    
    mov eax, 4
    call SetCursor
    invoke WriteString, offset logMsg1
    
    pop ebx
    pop eax
    ret
DrawLogMessages ENDP

DrawGamePlayArea PROC
    ; Draw main game box (right side)
    invoke DrawUIBox, 17, 1, 61, 21
    
    ; Draw level name at top
    mov eax, 19
    mov ebx, 2
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset levelNameDisplay
    
    ; Draw controls at bottom
    mov eax, 19
    mov ebx, 22
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset controlsDisplay
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    ret
DrawGamePlayArea ENDP

DrawGameBalloons PROC
    LOCAL i:DWORD
    push eax
    push ebx
    push ecx
    push esi
    
    mov i, 0
balloonLoop:
    mov eax, i
    cmp eax, 10
    jge balloonsDone
    
    ; Check if balloon is active
    lea esi, balloonActive
    add esi, i
    movzx ecx, BYTE PTR [esi]
    cmp ecx, 0
    je nextBalloon
    
    ; Get balloon position
    mov eax, i
    shl eax, 1  ; Multiply by 2 for SWORD
    lea esi, balloonX
    add esi, eax
    movsx ebx, SWORD PTR [esi]
    
    lea esi, balloonY
    add esi, eax
    movsx eax, SWORD PTR [esi]
    
    ; Draw at position
    push eax
    mov eax, ebx
    pop ebx
    call SetCursor
    
    ; Determine color based on type
    push eax
    mov eax, i
    lea esi, balloonType
    add esi, eax
    movzx eax, BYTE PTR [esi]
    pop ecx
    
    cmp eax, 0
    je redBalloon
    
    ; Yellow/trap balloon
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_TRAP
    invoke WriteChar, '('
    invoke WriteChar, 'O'
    invoke WriteChar, ')'
    jmp balloonDrawn
    
redBalloon:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_SAFE
    invoke WriteChar, '('
    invoke WriteChar, 'O'
    invoke WriteChar, ')'
    
balloonDrawn:
    ; Draw label below balloon
    push ebx
    mov eax, ecx
    inc ebx
    call SetCursor
    
    push eax
    mov eax, i
    lea esi, balloonType
    add esi, eax
    movzx eax, BYTE PTR [esi]
    pop ecx
    
    cmp eax, 0
    je redLabel
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset wrongBalloonMsg
    jmp labelDrawn
    
redLabel:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BALLOON_SAFE
    invoke WriteString, offset balloonChar
    
labelDrawn:
    pop ebx
    
nextBalloon:
    inc i
    jmp balloonLoop
    
balloonsDone:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
DrawGameBalloons ENDP

DrawArcher PROC
    push eax
    push ebx
    
    ; Draw archer position
    movsx eax, playerX
    movsx ebx, playerY
    call SetCursor
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_PLAYER
    invoke WriteString, offset archerDisplay
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
    pop ebx
    pop eax
    ret
DrawArcher ENDP

DrawArrow PROC
    push eax
    push ebx
    
    ; Check if arrow is active
    cmp arrowActive, 0
    je noArrow
    
    movsx eax, arrowX
    movsx ebx, arrowY
    call SetCursor
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_PLAYER
    invoke WriteChar, '^'
    
    ; Draw tail
    inc ebx
    call SetCursor
    invoke WriteChar, '|'
    
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    
noArrow:
    pop ebx
    pop eax
    ret
DrawArrow ENDP

UpdateBalloons PROC
    LOCAL i:DWORD
    push eax
    push ebx
    push ecx
    push esi
    
    mov i, 0
updateLoop:
    mov eax, i
    cmp eax, 10
    jge updateDone
    
    ; Check if balloon is active
    lea esi, balloonActive
    add esi, i
    movzx ecx, BYTE PTR [esi]
    cmp ecx, 0
    je nextUpdate
    
    ; Get balloon X position
    mov eax, i
    shl eax, 1
    lea esi, balloonX
    add esi, eax
    movsx ebx, SWORD PTR [esi]
    
    ; Get direction
    lea esi, balloonDirX
    add esi, eax
    movsx ecx, SWORD PTR [esi]
    
    ; Update position
    add ebx, ecx
    
    ; Check boundaries (20-75 for game area)
    cmp ebx, 20
    jle reverseBalloon
    cmp ebx, 75
    jge reverseBalloon
    jmp saveBalloonX
    
reverseBalloon:
    neg ecx
    mov eax, i
    shl eax, 1
    lea esi, balloonDirX
    add esi, eax
    mov SWORD PTR [esi], cx
    
saveBalloonX:
    mov eax, i
    shl eax, 1
    lea esi, balloonX
    add esi, eax
    mov SWORD PTR [esi], bx
    
nextUpdate:
    inc i
    jmp updateLoop
    
updateDone:
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
UpdateBalloons ENDP

UpdateArrow PROC
    push eax
    push ebx
    
    cmp arrowActive, 0
    je arrowDone
    
    ; Move arrow up
    movsx ebx, arrowY
    dec ebx
    
    ; Check if out of bounds
    cmp ebx, 3
    jle arrowMissed
    
    mov arrowY, bx
    
    ; Check collision with balloons
    call CheckArrowCollision
    jmp arrowDone
    
arrowMissed:
    ; Arrow went out of bounds (missed)
    mov arrowActive, 0
    
    ; Increase fear
    mov eax, fearLevel
    add eax, 5
    cmp eax, 100
    jle saveFearMiss
    mov eax, 100
saveFearMiss:
    mov fearLevel, eax
    
    ; Play scare sound for miss
    call PlayRandomScareSound
    
arrowDone:
    pop ebx
    pop eax
    ret
UpdateArrow ENDP

CheckArrowCollision PROC
    LOCAL i:DWORD
    LOCAL balloonXPos:DWORD
    LOCAL balloonYPos:DWORD
    LOCAL arrowXPos:DWORD
    LOCAL arrowYPos:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    movsx eax, arrowX
    movsx ebx, arrowY
    mov arrowXPos, eax
    mov arrowYPos, ebx
    
    mov i, 0
collisionLoop:
    mov ecx, i
    cmp ecx, 10
    jge collisionDone
    
    ; Check if balloon is active
    lea esi, balloonActive
    add esi, i
    movzx eax, BYTE PTR [esi]
    cmp eax, 0
    je nextCollision
    
    ; Get balloon position
    mov eax, i
    shl eax, 1
    lea esi, balloonX
    add esi, eax
    movsx ebx, SWORD PTR [esi]
    mov balloonXPos, ebx
    
    lea esi, balloonY
    add esi, eax
    movsx ebx, SWORD PTR [esi]
    mov balloonYPos, ebx
    
    ; Check collision: Y must match exactly, X must be within 1 of balloon center
    mov eax, arrowYPos
    cmp eax, balloonYPos
    jne nextCollision
    
    ; Check X collision (arrow must be within 1 unit of balloon X)
    mov eax, arrowXPos
    sub eax, balloonXPos
    
    ; If difference is more than 1 in either direction, no hit
    cmp eax, -1
    jl nextCollision
    cmp eax, 1
    jg nextCollision
    
    ; HIT! Deactivate arrow
    mov arrowActive, 0
    
    ; Deactivate balloon
    mov eax, i
    lea esi, balloonActive
    add esi, eax
    mov BYTE PTR [esi], 0
    
    ; Check balloon type
    lea esi, balloonType
    add esi, eax
    movzx eax, BYTE PTR [esi]
    
    cmp eax, 0
    je hitRedBalloon
    
    ; Hit yellow (trap) - increase fear and play scare sound
    mov eax, fearLevel
    add eax, 20
    cmp eax, 100
    jle saveFear
    mov eax, 100
saveFear:
    mov fearLevel, eax
    
    ; Play random scare sound when hitting trap balloon
    call PlayRandomScareSound
    jmp collisionDone
    
hitRedBalloon:
    ; Hit red (safe) - add score, decrease fear
    mov eax, score
    add eax, 10
    mov score, eax
    
    mov eax, fearLevel
    sub eax, 5
    cmp eax, 0
    jge saveFear2
    mov eax, 0
saveFear2:
    mov fearLevel, eax
    
    dec balloonsLeft
    jmp collisionDone
    
nextCollision:
    inc i
    jmp collisionLoop
    
collisionDone:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckArrowCollision ENDP

; ============================================================================

; ClearInnerBox - Clears the area inside the border
; ============================================================================

ClearInnerBox PROC
    LOCAL row:DWORD
    LOCAL coord:DWORD
    
    push eax
    push ebx
    push ecx
    
    mov row, 2
clearLoop:
    cmp row, 23
    jge clearDone
    
    ; Create COORD structure (Y << 16 | X)
    mov eax, row
    shl eax, 16
    mov ax, 2
    mov coord, eax
    
    ; Fill with spaces
    invoke FillConsoleOutputCharacterA, hConsoleOutput, ' ', 76, coord, offset bytesWritten
    invoke FillConsoleOutputAttribute, hConsoleOutput, THEME_BG, 76, coord, offset bytesWritten
    
    inc row
    jmp clearLoop
    
clearDone:
    pop ecx
    pop ebx
    pop eax
    ret
ClearInnerBox ENDP

; ============================================================================

; RunScrollAnimation - Star Wars-style scrolling text
; ============================================================================

RunScrollAnimation PROC
    LOCAL i:DWORD
    LOCAL currentY:SDWORD
    LOCAL frameCount:DWORD
    
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    mov frameCount, 0

animLoop:
    ; Non-blocking input check
    invoke ReadConsoleInputA, hConsoleInput, offset inputRecord, 1, offset eventsRead
    cmp eventsRead, 0
    jz noInput
    
    ; Check if it's a key event and key is down
    mov ax, WORD PTR inputRecord.EventType
    cmp ax, 1
    jne noInput
    
    mov eax, inputRecord.Event.bKeyDown
    cmp eax, 0
    je noInput

    ; Any key pressed - exit animation
    jmp animExit

noInput:
    call ClearInnerBox
    
    ; Loop through all lines
    mov i, 0

drawLinesLoop:
    mov eax, i
    cmp eax, numScrollLines
    jge drawLinesDone
    
    ; Calculate Y position for this line: BaseY - (i * 2)
    mov eax, i
    shl eax, 1     ; Multiply by 2 (double spacing)
    mov ecx, scrollBaseY
    sub ecx, eax
    mov currentY, ecx
    
    ; Check if inside visible area (Y >= 2 AND Y <= 22)
    cmp currentY, 2
    jl nextLine
    cmp currentY, 22
    jg nextLine
    
    ; Get string pointer
    mov esi, i
    shl esi, 2
    mov edx, scrollPtrs[esi]
    
    ; Simple color logic: Headers (lines starting with '-') are Yellow
    movzx eax, byte ptr [edx]
    cmp al, '-'
    je colorYellow
    
    invoke CenterText, edx, currentY, THEME_TEXT_MAIN
    jmp nextLine

colorYellow:
    invoke CenterText, edx, currentY, THEME_TEXT_ACCENT

nextLine:
    inc i
    jmp drawLinesLoop

drawLinesDone:
    ; Update Scroll Position - move up
    dec scrollBaseY
    
    ; If all text scrolled off top (BaseY < -50), exit
    cmp scrollBaseY, -50
    jl animExit
    
    invoke Sleep, 200  ; Scroll speed (200ms per frame)
    jmp animLoop

animExit:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
RunScrollAnimation ENDP

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

    cmp eax, STATE_GAME_OVER
    je doGameOver

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
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
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
    call DrawASCIIBorder

    ; Header: "BACK ========= SELECT LOCATION ========="
    mov eax, 3
    mov ebx, 2
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteChar, 'B'
    invoke WriteChar, 'A'
    invoke WriteChar, 'C'
    invoke WriteChar, 'K'
    
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    
    invoke WriteString, offset levelSelectTitle
    
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '
    invoke WriteChar, ' '


    ; Draw divider under header
    mov eax, 3
    mov ebx, 3
    call SetCursor
    invoke WriteString, offset levelDivider

    ; Level 1 - THE BARRENS (Unlocked)
    mov eax, 6
    mov ebx, 5
    call SetCursor
    mov eax, levelSelection
    cmp eax, 0
    jne level1_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
    jmp level1_draw
level1_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
level1_draw:
    invoke WriteString, offset level1Name
    
    mov eax, 33
    mov ebx, 5
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level1Stars
    
    mov eax, 48
    mov ebx, 5
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level1Best
    
    ; Divider after level 1
    mov eax, 6
    mov ebx, 6
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Level 2 - NEIBOLT STREET (Unlocked)
    mov eax, 6
    mov ebx, 8
    call SetCursor
    mov eax, levelSelection
    cmp eax, 1
    jne level2_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
    jmp level2_draw
level2_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
level2_draw:
    invoke WriteString, offset level2Name
    
    mov eax, 33
    mov ebx, 8
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level2Stars
    
    mov eax, 48
    mov ebx, 8
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level2Best
    
    ; Divider after level 2
    mov eax, 6
    mov ebx, 9
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Level 3 - DERRY CARNIVAL (Unlocked)
    mov eax, 6
    mov ebx, 11
    call SetCursor
    mov eax, levelSelection
    cmp eax, 2
    jne level3_normal
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_HOVER
    jmp level3_draw
level3_normal:
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
level3_draw:
    invoke WriteString, offset level3Name
    
    mov eax, 33
    mov ebx, 11
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level3Stars
    
    mov eax, 48
    mov ebx, 11
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset level3Best
    
    ; Divider after level 3
    mov eax, 6
    mov ebx, 12
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Level 4 - CANAL DAYS (LOCKED)
    mov eax, 6
    mov ebx, 14
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, DARKGRAY
    invoke WriteString, offset level4Name
    
    mov eax, 33
    mov ebx, 14
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteString, offset level4Locked
    
    ; Divider after level 4
    mov eax, 6
    mov ebx, 15
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Level 5 - THE SEWERS (LOCKED)
    mov eax, 6
    mov ebx, 17
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, DARKGRAY
    invoke WriteString, offset level5Name
    
    mov eax, 33
    mov ebx, 17
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteString, offset level5Locked
    
    ; Divider after level 5
    mov eax, 6
    mov ebx, 18
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Level 6 - IT'S LAIR (LOCKED)
    mov eax, 6
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, DARKGRAY
    invoke WriteString, offset level6Name
    
    mov eax, 33
    mov ebx, 20
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_WARNING
    invoke WriteString, offset level6Locked
    
    ; Divider after level 6
    mov eax, 6
    mov ebx, 21
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN
    invoke WriteString, offset levelDivider

    ; Bottom prompt
    mov eax, 27
    mov ebx, 22
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset levelPrompt
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN

    invoke Sleep, 50
    call GetLevelInput
    jmp gameLoop

; ============================================================================

; GAME MODE STATE
; ============================================================================

doGameMode:
    call ClearScreen
    
    ; Update displays
    call UpdateScoreDisplay
    call UpdateAmmoString
    call UpdateFearString
    call UpdateBalloonsString
    
    ; Draw all UI elements
    call DrawLeftPanel
    call DrawGamePlayArea
    call DrawLogMessages
    
    ; Update and draw game objects
    call UpdateBalloons
    call UpdateArrow
    call DrawGameBalloons
    call DrawArcher
    call DrawArrow
    
    ; Check win/lose conditions
    cmp fearLevel, 100
    jge gameLostFear
    
    cmp balloonsLeft, 0
    jle gameWon
    
    ; Get player input FIRST (before checking ammo game over)
    call GetGameInput
    
    ; Check if ammo just became 0 (was > 0 last frame, now is 0)
    mov eax, lastAmmoCount
    cmp eax, 0
    jle stillOutOfAmmo
    
    ; We had ammo last frame, check if we ran out this frame
    cmp ammoCount, 0
    jne stillHaveAmmo
    
    ; We just ran out of ammo - end game after this frame renders
    mov lastAmmoCount, 0
    jmp gameLoop
    
stillHaveAmmo:
    ; Still have ammo - update tracking and continue
    mov eax, ammoCount
    mov lastAmmoCount, eax
    jmp gameLoop

stillOutOfAmmo:
    ; Already out of ammo - trigger game over
    mov gameOverReason, 0
    mov gameState, STATE_GAME_OVER
    jmp gameLoop

gameLostFear:
    ; Fear reached 100
    mov gameOverReason, 1
    mov gameState, STATE_GAME_OVER
    jmp gameLoop

gameWon:
    ; Stop all sounds on victory
    call StopAllSounds
    
    ; TODO: Show victory screen
    mov gameState, STATE_MAIN_MENU
    jmp gameLoop

; ============================================================================

; INSTRUCTIONS STATE
; ============================================================================

doInstructions:
    call ClearScreen
    call DrawBorder

    mov eax, 28
    mov ebx, 1
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BORDER
    invoke WriteString, offset instrTitle
    
    ; Reset scroll position to start at bottom
    mov scrollBaseY, 22
    
    ; Run the scrolling animation
    call RunScrollAnimation
    
    ; After animation completes, return to main menu
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

; GAME OVER STATE
; ============================================================================

doGameOver:
    call ClearScreen
    call DrawASCIIBorder
    
    ; Draw game over title
    invoke CenterText, offset gameOverTitle, 3, THEME_BORDER
    
    ; Check reason for game over
    mov eax, gameOverReason
    cmp eax, 0
    je showOutOfAmmo
    
    ; Fear death screen
    invoke CenterText, offset fearDeathMsg, 6, THEME_WARNING
    invoke CenterText, offset fearDeathSub, 7, THEME_TEXT_MAIN
    jmp showScore
    
showOutOfAmmo:
    invoke CenterText, offset outOfAmmoMsg, 6, THEME_WARNING
    invoke CenterText, offset outOfAmmoSub, 7, THEME_TEXT_MAIN
    
showScore:
    mov eax, 30
    mov ebx, 10
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_ACCENT
    invoke WriteString, offset finalScoreMsg
    
    ; Update and display final score
    mov eax, 30
    mov ebx, 11
    call SetCursor
    call UpdateScoreDisplay
    invoke WriteString, offset scoreDisplay
    
    ; Return to menu prompt
    mov eax, 15
    mov ebx, 15
    call SetCursor
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_BTN_NORMAL
    invoke WriteString, offset returnMenuMsg
    invoke SetConsoleTextAttribute, hConsoleOutput, THEME_TEXT_MAIN    
    invoke Sleep, 500
    call WaitForKey
    
    ; Delay before returning to menu
    invoke Sleep, 50
    mov gameState, STATE_MAIN_MENU
    mov menuSelection, 0
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
    jmp waitMenuKey

selectStart:
    ; Go to level select instead of directly to game
    mov gameState, STATE_LEVEL_SELECT
    mov levelSelection, 0
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
    cmp eax, 2  ; Can only select unlocked levels (0-2)
    jge waitLevelKey
    inc levelSelection
    jmp levelInputDone

levelSelect:
    ; Check if selected level is unlocked
    mov eax, levelSelection
    cmp eax, 2
    jg waitLevelKey  ; Locked levels can't be selected
    
    ; Set balloon count based on level
    cmp eax, 0
    je setLevel1
    cmp eax, 1
    je setLevel2
    cmp eax, 2
    je setLevel3
    jmp waitLevelKey

setLevel1:
    mov balloonCount, 5
    ; Initialize level 1 balloons
    mov balloonsLeft, 4
    mov currentLevel, 1
    
    ; Setup balloons
    mov SWORD PTR [balloonX + 0], 35
    mov SWORD PTR [balloonX + 2], 50
    mov SWORD PTR [balloonX + 4], 65
    mov SWORD PTR [balloonX + 6], 40
    
    mov SWORD PTR [balloonY + 0], 5
    mov SWORD PTR [balloonY + 2], 7
    mov SWORD PTR [balloonY + 4], 9
    mov SWORD PTR [balloonY + 6], 11
    
    mov BYTE PTR [balloonType + 0], 0
    mov BYTE PTR [balloonType + 1], 0
    mov BYTE PTR [balloonType + 2], 1
    mov BYTE PTR [balloonType + 3], 0
    
    mov BYTE PTR [balloonActive + 0], 1
    mov BYTE PTR [balloonActive + 1], 1
    mov BYTE PTR [balloonActive + 2], 1
    mov BYTE PTR [balloonActive + 3], 1
    
    mov SWORD PTR [balloonDirX + 0], 1
    mov SWORD PTR [balloonDirX + 2], -1
    mov SWORD PTR [balloonDirX + 4], 1
    mov SWORD PTR [balloonDirX + 6], -1
    
    jmp startGame

setLevel2:
    mov balloonCount, 8
    mov balloonsLeft, 6
    mov currentLevel, 2
    ; Similar initialization for level 2
    jmp startGame
    
setLevel3:
    mov balloonCount, 10
    mov balloonsLeft, 8
    mov currentLevel,  3
    ; Similar initialization for level 3

startGame:
    mov score, 0
    mov playerX, 40
    mov playerY, 20
    mov fearLevel, 45
    mov ammoCount, 7
    mov lastAmmoCount, 7
    mov arrowActive, 0
    
    ; Reset sound variables
    mov lastFearLevel, 45
    mov lastScareTime, 0
    
    ; Stop any previous sounds
    call StopAllSounds
    
    ; Update level name display
    mov eax, currentLevel
    add al, '0'
    mov BYTE PTR [levelNameDisplay + 7], al
    
    mov gameState, STATE_GAME_MODE
    jmp levelInputDone

levelBack:
    mov gameState, STATE_MAIN_MENU
    mov levelSelection, 0

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

    cmp eax, 20h
    je shootArrow

    cmp eax, 50h
    je gamePause

    cmp eax, 1Bh
    je gameExit

    jmp gameInputDone

moveUp:
    movsx ebx, playerY
    cmp ebx, 5
    jle gameInputDone
    dec playerY
    jmp gameInputDone

moveDown:
    movsx ebx, playerY
    cmp ebx, 20
    jge gameInputDone
    inc playerY
    jmp gameInputDone

moveLeft:
    movsx eax, playerX
    cmp eax, 20
    jle gameInputDone
    sub playerX, 2
    jmp gameInputDone

moveRight:
    movsx eax, playerX
    cmp eax, 65
    jge gameInputDone
    add playerX, 2
    jmp gameInputDone

shootArrow:
    ; Check if arrow is already active
    cmp arrowActive, 1
    je gameInputDone
    
    ; Check if we have ammo BEFORE firing
    cmp ammoCount, 0
    jle gameInputDone
    
    ; Fire arrow
    mov arrowActive, 1
    movsx eax, playerX
    mov arrowX, ax
    movsx eax, playerY
    dec eax
    mov arrowY, ax
    dec ammoCount
    
    ; Check if we JUST ran out of ammo (now at 0)
    cmp ammoCount, 0
    jle ammoZero
    jmp gameInputDone

ammoZero:
    ; Out of ammo - play scream sound
    call PlayScreamSound
    jmp gameInputDone

gamePause:
    mov gameState, STATE_PAUSED
    jmp gameInputDone

gameExit:
    ; Stop all sounds when exiting to main menu
    call StopAllSounds
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
    ; Stop all sounds when exiting to main menu
    call StopAllSounds
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