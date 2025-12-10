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

; Internal prototypes
ClearBuffers PROTO
SetBufferChar PROTO :DWORD, :DWORD, :DWORD, :DWORD
RenderPlayer PROTO
RenderBalloons PROTO
RenderProjectiles PROTO
FlushBuffer PROTO
RenderHUD PROTO
RenderFooter PROTO

; ============================= DATA SECTION =================================
.data
    screenBuffer    db SCREEN_WIDTH * SCREEN_HEIGHT dup(CHAR_EMPTY)
    colorBuffer     db SCREEN_WIDTH * SCREEN_HEIGHT dup(COLOR_BLACK)
    
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
; Description: Clear the console screen buffer
; ----------------------------------------------------------------------------
ClearScreen PROC
    LOCAL coord:DWORD
    LOCAL charsWritten:DWORD
    
    ; Create COORD at (0,0)
    mov coord, 0    ; X=0, Y=0
    
    invoke FillConsoleOutputAttribute, hStdOut, COLOR_BLACK, SCREEN_WIDTH * SCREEN_HEIGHT, coord, ADDR charsWritten
    invoke FillConsoleOutputCharacterA, hStdOut, CHAR_EMPTY, SCREEN_WIDTH * SCREEN_HEIGHT, coord, ADDR charsWritten
    
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
; Description: Write character at position with color
; Parameters: x, y, char, color
; ----------------------------------------------------------------------------
WriteChar PROC x:DWORD, y:DWORD, chr:DWORD, color:DWORD
    LOCAL coord:DWORD
    LOCAL charsWritten:DWORD
    LOCAL buffer:BYTE
    
    ; Pack coordinates
    movzx eax, WORD PTR y
    shl eax, 16
    movzx ebx, WORD PTR x
    or eax, ebx
    mov coord, eax
    
    mov al, BYTE PTR chr
    mov buffer, al
    
    ; Set position
    invoke SetConsoleCursorPosition, hStdOut, coord
    
    ; Set color
    movzx eax, BYTE PTR color
    invoke SetConsoleTextAttribute, hStdOut, eax
    
    ; Write character
    invoke WriteConsoleA, hStdOut, ADDR buffer, 1, ADDR charsWritten, 0
    
    ret
WriteChar ENDP

; ----------------------------------------------------------------------------
; Procedure: WriteString
; Description: Write string at position with color
; Parameters: x, y, string ptr, color on stack
; ----------------------------------------------------------------------------
WriteString PROC x:DWORD, y:DWORD, strPtr:DWORD, color:DWORD
    LOCAL coord:DWORD
    LOCAL strLen:DWORD
    
    ; Pack coordinates
    movzx eax, WORD PTR y
    shl eax, 16
    movzx ebx, WORD PTR x
    or eax, ebx
    mov coord, eax
    
    ; Set position
    invoke SetConsoleCursorPosition, hStdOut, coord
    
    ; Set color
    movzx eax, BYTE PTR color
    invoke SetConsoleTextAttribute, hStdOut, eax
    
    ; Get string length
    invoke StrLen, strPtr
    mov strLen, eax
    
    ; Write string
    invoke WriteConsoleA, hStdOut, strPtr, strLen, ADDR bytesWritten, 0
    
    ret
WriteString ENDP

; ----------------------------------------------------------------------------
; Procedure: ClearBuffers
; Description: Clear screen and color buffers
; ----------------------------------------------------------------------------
ClearBuffers PROC
    push edi
    
    ; Clear screen buffer
    mov edi, OFFSET screenBuffer
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov al, CHAR_EMPTY
    rep stosb
    
    ; Clear color buffer
    mov edi, OFFSET colorBuffer
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov al, COLOR_BLACK
    rep stosb
    
    pop edi
    ret
ClearBuffers ENDP

; ----------------------------------------------------------------------------
; Procedure: SetBufferChar
; Description: Set character in buffer at position
; Parameters: x, y, char, color
; ----------------------------------------------------------------------------
SetBufferChar PROC x:DWORD, y:DWORD, chr:DWORD, color:DWORD
    push ebx
    
    mov eax, y
    cmp eax, GAME_HEIGHT
    jge OutOfBounds
    
    mov ebx, x
    cmp ebx, SCREEN_WIDTH
    jge OutOfBounds
    
    ; Calculate offset: y * SCREEN_WIDTH + x
    imul eax, SCREEN_WIDTH
    add eax, ebx
    
    ; Set character
    mov bl, BYTE PTR chr
    mov screenBuffer[eax], bl
    
    ; Set color
    mov bl, BYTE PTR color
    mov colorBuffer[eax], bl
    
OutOfBounds:
    pop ebx
    ret
SetBufferChar ENDP

; ----------------------------------------------------------------------------
; Procedure: FlushBuffer
; Description: Render buffer to console
; ----------------------------------------------------------------------------
FlushBuffer PROC
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL bufOffset:DWORD
    
    mov y, 0
YLoop:
    mov eax, y
    cmp eax, GAME_HEIGHT
    jge YDone
    
    mov x, 0
XLoop:
    mov eax, x
    cmp eax, SCREEN_WIDTH
    jge XDone
    
    ; Calculate offset
    mov eax, y
    imul eax, SCREEN_WIDTH
    add eax, x
    mov bufOffset, eax
    
    ; Write character
    movzx ecx, colorBuffer[eax]
    movzx edx, screenBuffer[eax]
    invoke WriteChar, x, y, edx, ecx
    
    inc x
    jmp XLoop
    
XDone:
    inc y
    jmp YLoop
    
YDone:
    ret
FlushBuffer ENDP

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
; Description: Render player character
; ----------------------------------------------------------------------------
RenderPlayer PROC
    invoke SetBufferChar, player.x, player.y, CHAR_PLAYER, COLOR_PLAYER
    ret
RenderPlayer ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderBalloons
; Description: Render all active balloons
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
    invoke SetBufferChar, [ebx].ENTITY.x, [ebx].ENTITY.y, CHAR_BALLOON, balloonColor
    
NextBalloon:
    add balloonPtr, SIZEOF ENTITY
    inc i
    jmp BalloonLoop
    
BalloonDone:
    ret
RenderBalloons ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderProjectiles
; Description: Render all active projectiles
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
    invoke SetBufferChar, [ebx].ENTITY.x, [ebx].ENTITY.y, CHAR_ARROW, COLOR_ARROW
    
NextProj:
    add projPtr, SIZEOF ENTITY
    inc i
    jmp ProjLoop
    
ProjDone:
    ret
RenderProjectiles ENDP

; ----------------------------------------------------------------------------
; Procedure: RenderGame
; Description: Main game rendering procedure
; ----------------------------------------------------------------------------
RenderGame PROC
    call ClearBuffers
    
    call RenderBalloons
    call RenderProjectiles
    call RenderPlayer
    
    call FlushBuffer
    
    call RenderHUD
    call RenderFooter
    
    ret
RenderGame ENDP

END
