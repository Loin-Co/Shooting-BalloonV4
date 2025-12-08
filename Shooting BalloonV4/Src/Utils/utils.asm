; ============================================================================
; utils.asm - Utility Functions (Math, Strings, RNG)
; Location: Src/Utils/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc

; Public exports
PUBLIC InitRandom
PUBLIC Random
PUBLIC RandomRange
PUBLIC Abs
PUBLIC Min
PUBLIC Max
PUBLIC Clamp
PUBLIC StrLen
PUBLIC IntToStr
PUBLIC Distance
PUBLIC timeGetTime

; ============================= DATA SECTION =================================
.data
    randSeed    DWORD 12345678h
    
; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: timeGetTime
; Description: Custom implementation of timeGetTime (replaces winmm.lib)
;              Uses GetTickCount from kernel32.lib instead
; Returns: EAX = milliseconds since system start
; ----------------------------------------------------------------------------
timeGetTime PROC
    invoke GetTickCount
    ret
timeGetTime ENDP

; ----------------------------------------------------------------------------
; Procedure: InitRandom
; Description: Initialize random number generator with current time
; ----------------------------------------------------------------------------
InitRandom PROC
    invoke GetTickCount
    mov randSeed, eax
    ret
InitRandom ENDP

; ----------------------------------------------------------------------------
; Procedure: Random
; Description: Generate a random number
; Returns: EAX = random number
; ----------------------------------------------------------------------------
Random PROC
    mov eax, randSeed
    imul eax, 1103515245
    add eax, 12345
    mov randSeed, eax
    shr eax, 16
    and eax, 7FFFh
    ret
Random ENDP

; ----------------------------------------------------------------------------
; Procedure: RandomRange
; Description: Generate random number in range [0, max)
; Parameters: max value
; Returns: EAX = random number in range
; ----------------------------------------------------------------------------
RandomRange PROC maxVal:DWORD
    push ebx
    mov ebx, maxVal
    
    call Random
    xor edx, edx
    div ebx
    mov eax, edx        ; Return remainder
    
    pop ebx
    ret
RandomRange ENDP

; ----------------------------------------------------------------------------
; Procedure: Abs
; Description: Absolute value
; Parameters: value in EAX
; Returns: EAX = |value|
; ----------------------------------------------------------------------------
Abs PROC
    test eax, eax
    jns @F
    neg eax
@@:
    ret
Abs ENDP

; ----------------------------------------------------------------------------
; Procedure: Min
; Description: Return minimum of two values
; Parameters: val1, val2
; Returns: EAX = min(val1, val2)
; ----------------------------------------------------------------------------
Min PROC val1:DWORD, val2:DWORD
    mov eax, val1
    mov edx, val2
    cmp eax, edx
    jle @F
    mov eax, edx
@@:
    ret
Min ENDP

; ----------------------------------------------------------------------------
; Procedure: Max
; Description: Return maximum of two values
; Parameters: val1, val2
; Returns: EAX = max(val1, val2)
; ----------------------------------------------------------------------------
Max PROC val1:DWORD, val2:DWORD
    mov eax, val1
    mov edx, val2
    cmp eax, edx
    jge @F
    mov eax, edx
@@:
    ret
Max ENDP

; ----------------------------------------------------------------------------
; Procedure: Clamp
; Description: Clamp value between min and max
; Parameters: val, minVal, maxVal
; Returns: EAX = clamped value
; ----------------------------------------------------------------------------
Clamp PROC val:DWORD, minVal:DWORD, maxVal:DWORD
    mov eax, val
    mov edx, minVal
    mov ecx, maxVal
    
    ; if (value < min) value = min
    cmp eax, edx
    jge @F
    mov eax, edx
@@:
    ; if (value > max) value = max
    cmp eax, ecx
    jle @F
    mov eax, ecx
@@:
    ret
Clamp ENDP

; ----------------------------------------------------------------------------
; Procedure: StrLen
; Description: Get string length
; Parameters: string pointer
; Returns: EAX = length
; ----------------------------------------------------------------------------
StrLen PROC strPtr:DWORD
    push edi
    mov edi, strPtr
    xor eax, eax
    xor ecx, ecx
    dec ecx
    repne scasb
    not ecx
    dec ecx
    mov eax, ecx
    pop edi
    ret
StrLen ENDP

; ----------------------------------------------------------------------------
; Procedure: IntToStr
; Description: Convert integer to string
; Parameters: val, buffer pointer
; Returns: Buffer filled with string
; ----------------------------------------------------------------------------
IntToStr PROC val:DWORD, buffer:DWORD
    push ebx
    push esi
    push edi
    
    mov eax, val
    mov edi, buffer
    mov esi, edi
    mov ebx, 10
    
    ; Handle negative
    test eax, eax
    jns Positive
    neg eax
    mov byte ptr [edi], '-'
    inc edi
    
Positive:
    ; Convert digits (reverse order)
    mov ecx, edi
ConvertLoop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    inc edi
    test eax, eax
    jnz ConvertLoop
    
    ; Null terminate
    mov byte ptr [edi], 0
    
    ; Reverse the digits
    dec edi
ReverseLoop:
    cmp ecx, edi
    jge ReverseDone
    mov al, [ecx]
    mov ah, [edi]
    mov [ecx], ah
    mov [edi], al
    inc ecx
    dec edi
    jmp ReverseLoop
    
ReverseDone:
    pop edi
    pop esi
    pop ebx
    ret
IntToStr ENDP

; ----------------------------------------------------------------------------
; Procedure: Distance
; Description: Calculate Manhattan distance between two points
; Parameters: x1, y1, x2, y2
; Returns: EAX = |x1-x2| + |y1-y2|
; ----------------------------------------------------------------------------
Distance PROC x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
    mov eax, x1
    sub eax, x2
    call Abs
    mov ecx, eax
    
    mov eax, y1
    sub eax, y2
    call Abs
    
    add eax, ecx
    ret
Distance ENDP

END
