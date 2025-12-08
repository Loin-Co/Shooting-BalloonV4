; ============================================================================
; draw_shapes.asm - Drawing Primitives (Text, Shapes, Effects)
; Location: Src/Renderer/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= EXTERNAL DATA ================================
EXTERN player:PLAYER_STRUCT
EXTERN balloons:ENTITY
EXTERN projectiles:ENTITY
EXTERN currentLevel:DWORD
EXTERN fearMeter:DWORD
EXTERN hStdOut:DWORD
EXTERN bytesWritten:DWORD
EXTERN currentState:DWORD

; ============================= PUBLIC EXPORTS ===============================
PUBLIC WriteString
PUBLIC WriteChar
PUBLIC RenderGame

; ============================= DATA SECTION =================================
.data
    ; HUD strings
    hudLevel        db "LEVEL: ", 0
    hudScore        db " SCORE: ", 0
    hudFear         db " FEAR: ", 0
    hudLives        db " LIVES: ", 0
    
    ; Footer strings
    footerGame      db "[ARROWS]:Move [SPACE]:Shoot [SHIFT]:Swap [P]:Pause", 0
    
    tempBuffer      db 32 dup(0)
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: WriteChar
; Description: Write character at position with color (using DrawPixel)
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
; Procedure: RenderHUD
; Description: Render heads-up display (top bar)
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
; Procedure: RenderFooter
; Description: Render footer UI bar (controls)
; ----------------------------------------------------------------------------
RenderFooter PROC
    LOCAL centerX:DWORD
    
    ; Calculate centered position
    invoke StrLen, ADDR footerGame
    mov ebx, SCREEN_WIDTH
    sub ebx, eax
    shr ebx, 1
    mov centerX, ebx
    
    invoke WriteString, centerX, 33, ADDR footerGame, COLOR_FOOTER
    
    ret
RenderFooter ENDP

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
; Pipeline: ClearBuffer ? Draw Everything ? PresentFrame
; ----------------------------------------------------------------------------
RenderGame PROC
    ; Clear the back buffer
    call ClearBuffer
    
    ; Draw all game elements to buffer (back to front)
    call RenderBalloons
    call RenderProjectiles
    call RenderPlayer
    call RenderHUD
    call RenderFooter
    
    ; Present the frame (flip buffer to screen - atomic!)
    call PresentFrame
    
    ret
RenderGame ENDP

END
