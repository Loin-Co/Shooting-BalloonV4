; ============================================================================
; draw_shapes.asm - Drawing Primitives
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

.686
.model flat, stdcall
option casemap :none

include windows.inc
include kernel32.inc
include msvcrt.inc

includelib kernel32.lib
includelib msvcrt.lib

include common.inc
include protos.inc

; ============================================================================
; EXTERNAL REFERENCES
; ============================================================================
EXTERN g_ConsoleBuffer:CHAR_INFO
EXTERN g_hConsoleOut:DWORD

; ============================================================================
; PUBLIC DECLARATIONS
; ============================================================================
PUBLIC DrawPixel
PUBLIC DrawChar
PUBLIC DrawString
PUBLIC DrawRect
PUBLIC FlashScreen

; ============================================================================
; CODE SECTION
; ============================================================================
.code

; ============================================================================
; DrawPixel - Draw a single character at x, y with color (OPTIMIZED)
; Parameters: x, y, color, character
; ============================================================================
DrawPixel PROC uses ebx esi edi dwX:DWORD, dwY:DWORD, dwColor:DWORD, dwChar:DWORD
    ; Bounds check - combined single comparison
    mov eax, dwX
    cmp eax, SCREEN_WIDTH
    jae DrawPixel_Exit      ; Unsigned compare handles < 0 and >= WIDTH
    
    mov eax, dwY
    cmp eax, SCREEN_HEIGHT
    jae DrawPixel_Exit
    
    ; Calculate offset: (y * SCREEN_WIDTH + x) * sizeof(CHAR_INFO)
    ; Optimized: use LEA and shifts where possible
    mov eax, dwY
    shl eax, 6              ; * 64 (close to 80)
    mov ebx, dwY
    shl ebx, 4              ; * 16
    add eax, ebx            ; eax = y * 80
    add eax, dwX            ; eax = y * 80 + x
    shl eax, 2              ; * 4 (sizeof CHAR_INFO)
    
    ; Get buffer address and write both values at once
    lea ebx, g_ConsoleBuffer
    add ebx, eax
    
    ; Set character
    mov ax, WORD PTR dwChar
    mov [ebx], ax
    
    ; Set color attribute  
    mov ax, WORD PTR dwColor
    mov [ebx+2], ax
    
DrawPixel_Exit:
    ret
DrawPixel ENDP

; ============================================================================
; DrawChar - Draw a single character (alias for DrawPixel for clarity)
; Parameters: x, y, color, character
; ============================================================================
DrawChar PROC dwX:DWORD, dwY:DWORD, dwColor:DWORD, dwChar:DWORD
    invoke DrawPixel, dwX, dwY, dwColor, dwChar
    ret
DrawChar ENDP

; ============================================================================
; DrawString - Draw a string at x, y with color
; Parameters: x, y, color, stringAddress
; ============================================================================
DrawString PROC uses ebx esi edi dwX:DWORD, dwY:DWORD, dwColor:DWORD, lpString:DWORD
    LOCAL currentX:DWORD
    
    mov eax, dwX
    mov currentX, eax
    
    mov esi, lpString
    
DrawString_Loop:
    ; Load character
    movzx eax, BYTE PTR [esi]
    
    ; Check for null terminator
    test eax, eax
    jz DrawString_Done
    
    ; Draw the character
    invoke DrawPixel, currentX, dwY, dwColor, eax
    
    ; Move to next character
    inc esi
    inc currentX
    
    ; Check if we've reached screen edge
    mov eax, currentX
    cmp eax, SCREEN_WIDTH
    jge DrawString_Done
    
    jmp DrawString_Loop
    
DrawString_Done:
    ret
DrawString ENDP

; ============================================================================
; DrawRect - Draw a rectangle border
; Parameters: left, top, right, bottom, color
; ============================================================================
DrawRect PROC uses ebx esi edi dwLeft:DWORD, dwTop:DWORD, dwRight:DWORD, dwBottom:DWORD, dwColor:DWORD
    LOCAL x:DWORD
    LOCAL y:DWORD
    
    ; Draw top and bottom borders
    mov eax, dwLeft
    mov x, eax
    
DrawRect_TopBottom:
    mov eax, x
    cmp eax, dwRight
    jg DrawRect_TopBottom_Done
    
    ; Top border
    invoke DrawPixel, x, dwTop, dwColor, '-'
    
    ; Bottom border
    invoke DrawPixel, x, dwBottom, dwColor, '-'
    
    inc x
    jmp DrawRect_TopBottom
    
DrawRect_TopBottom_Done:
    
    ; Draw left and right borders
    mov eax, dwTop
    mov y, eax
    
DrawRect_LeftRight:
    mov eax, y
    cmp eax, dwBottom
    jg DrawRect_LeftRight_Done
    
    ; Left border
    invoke DrawPixel, dwLeft, y, dwColor, '|'
    
    ; Right border
    invoke DrawPixel, dwRight, y, dwColor, '|'
    
    inc y
    jmp DrawRect_LeftRight
    
DrawRect_LeftRight_Done:
    
    ; Draw corners
    invoke DrawPixel, dwLeft, dwTop, dwColor, '+'
    invoke DrawPixel, dwRight, dwTop, dwColor, '+'
    invoke DrawPixel, dwLeft, dwBottom, dwColor, '+'
    invoke DrawPixel, dwRight, dwBottom, dwColor, '+'
    
    ret
DrawRect ENDP

; ============================================================================
; FlashScreen - Flash screen for jumpscare effect
; ============================================================================
FlashScreen PROC
    LOCAL i:DWORD
    LOCAL flashCount:DWORD
    
    mov flashCount, 6
    mov i, 0
    
FlashScreen_Loop:
    mov eax, i
    cmp eax, flashCount
    jge FlashScreen_Done
    
    ; Flash red
    invoke SetConsoleTextAttribute, g_hConsoleOut, 4Fh  ; White on Red
    call ClearScreen
    call PresentFrame
    invoke Sleep, 100
    
    ; Flash black
    invoke SetConsoleTextAttribute, g_hConsoleOut, 00h
    call ClearScreen
    call PresentFrame
    invoke Sleep, 100
    
    inc i
    jmp FlashScreen_Loop
    
FlashScreen_Done:
    ; Restore default
    invoke SetConsoleTextAttribute, g_hConsoleOut, THEME_TEXT_MAIN
    ret
FlashScreen ENDP

end
