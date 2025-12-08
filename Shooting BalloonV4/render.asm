; ============================================================================
; render.asm - In-game Rendering (Fog of War, ASCII Buffer, Footer UI)
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include common.inc

; ============================= EXTERNAL DATA ================================
EXTERN hStdOut:DWORD
EXTERN bytesWritten:DWORD
EXTERN currentState:DWORD

; From physics.asm
EXTERN player:PLAYER_STRUCT
EXTERN balloons:ENTITY
EXTERN projectiles:ENTITY
EXTERN currentLevel:DWORD
EXTERN fearMeter:DWORD

; From utils.asm
Distance PROTO :DWORD, :DWORD, :DWORD, :DWORD
IntToStr PROTO :DWORD, :DWORD
StrLen PROTO :DWORD

; Public prototypes for external use
PUBLIC ClearScreen
PUBLIC WriteString
PUBLIC WriteChar
PUBLIC RenderGame
PUBLIC InitRenderer

; Internal prototypes
ClearBuffer PROTO
DrawPixel PROTO :DWORD, :DWORD, :DWORD, :DWORD
PresentFrame PROTO
RenderPlayer PROTO
RenderBalloons PROTO
RenderProjectiles PROTO
RenderHUD PROTO
RenderFooter PROTO

; ============================= DATA SECTION =================================
.data
    ; Double Buffer - CHAR_INFO array (4 bytes per cell: 2 bytes char + 2 bytes attr)
    consoleBuffer   CHAR_INFO BUFFER_SIZE dup(<0, 0>)
    
    ; WriteConsoleOutput parameters
    bufferSize      COORD <SCREEN_WIDTH, SCREEN_HEIGHT>
    bufferCoord     COORD <0, 0>
    writeRegion     SMALL_RECT <0, 0, SCREEN_WIDTH-1, SCREEN_HEIGHT-1>
    
    ; Footer strings
    footerGame      db "[ARROWS]:Move [SPACE]:Shoot [SHIFT]:Swap [P]:Pause", 0
    
    ; HUD strings
    hudLevel        db "LEVEL: ", 0
    hudScore        db " SCORE: ", 0
    hudFear         db " FEAR: ", 0
    hudLives        db " LIVES: ", 0
    
    tempBuffer      db 32 dup(0)
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: ClearScreen
; Description: Clear the console screen buffer (legacy support)
; ----------------------------------------------------------------------------
ClearScreen PROC
    call ClearBuffer
    call PresentFrame
    ret
ClearScreen ENDP

; ----------------------------------------------------------------------------
; Procedure: SetCursorPos
; Description: Set console cursor position
; Parameters: x, y on stack
; ----------------------------------------------------------------------------
SetCursorPos PROC
    LOCAL coord:DWORD
    
    ; Pack X and Y into DWORD (Y in high word, X in low word)
    movzx eax, WORD PTR [esp+8]    ; y
    shl eax, 16
    movzx ebx, WORD PTR [esp+4]    ; x
    or eax, ebx
    mov coord, eax
    
    invoke SetConsoleCursorPosition, hStdOut, coord
    
    ret 8
SetCursorPos ENDP

; ----------------------------------------------------------------------------
; Procedure: WriteChar
; Description: Write character at position with color (now using DrawPixel)
; Parameters: x, y, char, color
; ----------------------------------------------------------------------------
WriteChar PROC x:DWORD, y:DWORD, chr:DWORD, color:DWORD
    invoke DrawPixel, x, y, chr, color
    ret
WriteChar ENDP

; ----------------------------------------------------------------------------
; Procedure: WriteString
; Description: Write string at position with color using DrawPixel
; Parameters: x, y, string ptr, color
; ----------------------------------------------------------------------------
WriteString PROC x:DWORD, y:DWORD, strPtr:DWORD, color:DWORD
    LOCAL currentX:DWORD
    LOCAL strOffset:DWORD
    
    mov eax, x
    mov currentX, eax
    mov strOffset, 0
    
WriteLoop:
    mov ebx, strPtr
    add ebx, strOffset
    movzx eax, BYTE PTR [ebx]
    
    ; Check for null terminator
    test al, al
    jz WriteDone
    
    ; Draw character
    invoke DrawPixel, currentX, y, eax, color
    
    inc currentX
    inc strOffset
    jmp WriteLoop
    
WriteDone:
    ret
WriteString ENDP

; ----------------------------------------------------------------------------
; Procedure: InitRenderer
; Description: Initialize renderer and hide cursor
; ----------------------------------------------------------------------------
InitRenderer PROC
    LOCAL cursorInfo:CONSOLE_CURSOR_INFO
    
    ; Hide cursor to prevent flicker
    mov cursorInfo.dwSize, 1
    mov cursorInfo.bVisible, FALSE
    invoke SetConsoleCursorInfo, hStdOut, ADDR cursorInfo
    
    ; Clear buffer
    call ClearBuffer
    call PresentFrame
    
    ret
InitRenderer ENDP

; ----------------------------------------------------------------------------
; Procedure: ClearBuffer
; Description: Clear the console buffer (fill with spaces and black background)
; ----------------------------------------------------------------------------
ClearBuffer PROC
    push edi
    push ecx
    
    ; Clear entire consoleBuffer
    mov edi, OFFSET consoleBuffer
    mov ecx, BUFFER_SIZE
    
ClearLoop:
    mov WORD PTR [edi], ' '           ; UnicodeChar = space (ASCII in low byte)
    mov WORD PTR [edi+2], 0           ; Attributes = black on black
    add edi, 4                        ; CHAR_INFO is 4 bytes
    loop ClearLoop
    
    pop ecx
    pop edi
    ret
ClearBuffer ENDP

; ----------------------------------------------------------------------------
; Procedure: DrawPixel
; Description: Draw a character at (x, y) with color to the buffer
; Parameters: x, y, char, color
; ----------------------------------------------------------------------------
DrawPixel PROC x:DWORD, y:DWORD, chr:DWORD, color:DWORD
    push ebx
    
    ; Bounds check
    mov eax, y
    cmp eax, SCREEN_HEIGHT
    jge OutOfBounds
    
    mov ebx, x
    cmp ebx, SCREEN_WIDTH
    jge OutOfBounds
    
    ; Calculate offset: ((y * SCREEN_WIDTH) + x) * 4
    imul eax, SCREEN_WIDTH
    add eax, ebx
    shl eax, 2                        ; multiply by 4 (sizeof CHAR_INFO)
    
    ; Write to buffer
    mov ebx, eax
    mov ax, WORD PTR chr
    mov WORD PTR consoleBuffer[ebx], ax     ; UnicodeChar
    
    mov ax, WORD PTR color
    mov WORD PTR consoleBuffer[ebx+2], ax   ; Attributes
    
OutOfBounds:
    pop ebx
    ret
DrawPixel ENDP

; ----------------------------------------------------------------------------
; Procedure: PresentFrame
; Description: Flip the buffer to screen using WriteConsoleOutput
; ----------------------------------------------------------------------------
PresentFrame PROC
    LOCAL tempRegion:SMALL_RECT
    LOCAL tempCoord:COORD
    LOCAL tempSize:COORD
    
    ; Copy writeRegion to local variable (API modifies it)
    mov ax, WORD PTR writeRegion.Left
    mov WORD PTR tempRegion.Left, ax
    mov ax, WORD PTR writeRegion.Top
    mov WORD PTR tempRegion.Top, ax
    mov ax, WORD PTR writeRegion.Right
    mov WORD PTR tempRegion.Right, ax
    mov ax, WORD PTR writeRegion.Bottom
    mov WORD PTR tempRegion.Bottom, ax
    
    ; Copy bufferCoord
    mov ax, WORD PTR bufferCoord.X
    mov WORD PTR tempCoord.X, ax
    mov ax, WORD PTR bufferCoord.Y
    mov WORD PTR tempCoord.Y, ax
    
    ; Copy bufferSize
    mov ax, WORD PTR bufferSize.X
    mov WORD PTR tempSize.X, ax
    mov ax, WORD PTR bufferSize.Y
    mov WORD PTR tempSize.Y, ax
    
    ; Call WriteConsoleOutputA
    lea eax, tempRegion
    push eax
    
    ; Push COORD as DWORD (Y in high word, X in low word)
    movzx eax, WORD PTR tempCoord.Y
    shl eax, 16
    movzx ebx, WORD PTR tempCoord.X
    or eax, ebx
    push eax
    
    movzx eax, WORD PTR tempSize.Y
    shl eax, 16
    movzx ebx, WORD PTR tempSize.X
    or eax, ebx
    push eax
    
    push OFFSET consoleBuffer
    push hStdOut
    call WriteConsoleOutputA
    
    ret
PresentFrame ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderFooter
; Description: Render footer UI bar
; ----------------------------------------------------------------------------
RenderFooter PROC
    LOCAL centerX:DWORD
    
    ; Calculate centered position
    invoke StrLen, ADDR footerGame
    mov ebx, SCREEN_WIDTH
    sub ebx, eax
    shr ebx, 1
    mov centerX, ebx
    
    invoke WriteString, centerX, 24, ADDR footerGame, COLOR_FOOTER
    
    ret
RenderFooter ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderHUD
; Description: Render heads-up display
; ----------------------------------------------------------------------------
RenderHUD PROC
    LOCAL hudX:DWORD
    
    mov hudX, 1
    
    ; Render "LEVEL: X"
    invoke WriteString, hudX, 0, ADDR hudLevel, COLOR_WHITE
    
    add hudX, 7
    
    invoke IntToStr, currentLevel, ADDR tempBuffer
    invoke WriteString, hudX, 0, ADDR tempBuffer, COLOR_LIGHT_YELLOW
    
    ; Render "SCORE: XXX"
    add hudX, 5
    
    invoke WriteString, hudX, 0, ADDR hudScore, COLOR_WHITE
    
    add hudX, 8
    
    invoke IntToStr, player.score, ADDR tempBuffer
    invoke WriteString, hudX, 0, ADDR tempBuffer, COLOR_LIGHT_GREEN
    
    ; Render "FEAR: XX%"
    add hudX, 10
    
    invoke WriteString, hudX, 0, ADDR hudFear, COLOR_WHITE
    
    add hudX, 7
    
    invoke IntToStr, fearMeter, ADDR tempBuffer
    
    ; Color based on fear level
    mov eax, fearMeter
    cmp eax, 75
    jge HighFear
    cmp eax, 50
    jge MediumFear
    
    invoke WriteString, hudX, 0, ADDR tempBuffer, COLOR_LIGHT_GREEN
    jmp FearDone
    
MediumFear:
    invoke WriteString, hudX, 0, ADDR tempBuffer, COLOR_LIGHT_YELLOW
    jmp FearDone
    
HighFear:
    invoke WriteString, hudX, 0, ADDR tempBuffer, COLOR_LIGHT_RED
    
FearDone:
    ret
RenderHUD ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderPlayer
; Description: Render player character to buffer
; ----------------------------------------------------------------------------
RenderPlayer PROC
    invoke DrawPixel, player.x, player.y, CHAR_PLAYER, COLOR_PLAYER
    ret
RenderPlayer ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderBalloons
; Description: Render all active balloons to buffer
; ----------------------------------------------------------------------------
RenderBalloons PROC
    LOCAL i:DWORD
    LOCAL balloonPtr:DWORD
    LOCAL balloonColor:DWORD
    
    mov i, 0
    mov balloonPtr, OFFSET balloons
    
BalloonLoop:
    mov eax, i
    cmp eax, MAX_BALLOONS
    jge BalloonDone
    
    mov ebx, balloonPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je NextBalloon
    
    ; Determine color by type
    movzx eax, BYTE PTR [ebx].ENTITY.entityType
    cmp eax, BALLOON_YELLOW
    je YellowBalloon
    
    mov balloonColor, COLOR_BALLOON_RED
    jmp RenderBalloon
    
YellowBalloon:
    mov balloonColor, COLOR_BALLOON_YELLOW
    
RenderBalloon:
    invoke DrawPixel, [ebx].ENTITY.x, [ebx].ENTITY.y, CHAR_BALLOON, balloonColor
    
NextBalloon:
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp BalloonLoop
    
BalloonDone:
    ret
RenderBalloons ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderProjectiles
; Description: Render all active projectiles to buffer
; ----------------------------------------------------------------------------
RenderProjectiles PROC
    LOCAL i:DWORD
    LOCAL projPtr:DWORD
    
    mov i, 0
    mov projPtr, OFFSET projectiles
    
ProjLoop:
    mov eax, i
    cmp eax, MAX_PROJECTILES
    jge ProjDone
    
    mov ebx, projPtr
    cmp BYTE PTR [ebx].ENTITY.active, FALSE
    je NextProj
    
    ; Render projectile
    invoke DrawPixel, [ebx].ENTITY.x, [ebx].ENTITY.y, CHAR_ARROW, COLOR_ARROW
    
NextProj:
    add projPtr, SIZEOF ENTITY
    inc i
    jmp ProjLoop
    
ProjDone:
    ret
RenderProjectiles ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderGame
; Description: Main game rendering procedure with double buffering
; ----------------------------------------------------------------------------
RenderGame PROC
    ; Clear the back buffer
    call ClearBuffer
    
    ; Draw all game elements to buffer
    call RenderBalloons
    call RenderProjectiles
    call RenderPlayer
    call RenderHUD
    call RenderFooter
    
    ; Present the frame (flip buffer to screen)
    call PresentFrame
    
    ret
RenderGame ENDP

END
