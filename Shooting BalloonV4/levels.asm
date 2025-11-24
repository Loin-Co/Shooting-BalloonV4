; ============================================================================
; levels.asm - Level Progression Data and Mechanics
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include common.inc

; ============================= DATA SECTION =================================
.data
    ; Level definitions array
    PUBLIC levelData
    levelData       LEVEL_STRUCT 10 dup(<>)
    
    ; Level 1-2: The Sewers (Fog of War)
    level1Data      LEVEL_STRUCT <1, 5, 1, 5000, 1>
    level2Data      LEVEL_STRUCT <2, 7, 1, 4500, 1>
    
    ; Level 3-4: The Barrens (Wind mechanic)
    level3Data      LEVEL_STRUCT <3, 8, 2, 4000, 2>
    level4Data      LEVEL_STRUCT <4, 10, 2, 3500, 2>
    
    ; Level 5-6: Neibolt House (Flicker effect)
    level5Data      LEVEL_STRUCT <5, 12, 3, 3000, 3>
    level6Data      LEVEL_STRUCT <6, 14, 3, 2500, 3>
    
    ; Level 7-8: The Festival (High speed)
    level7Data      LEVEL_STRUCT <7, 16, 4, 2000, 0>
    level8Data      LEVEL_STRUCT <8, 18, 4, 1500, 0>
    
    ; Level 9: The Deadlights (Inverted controls)
    level9Data      LEVEL_STRUCT <9, 20, 5, 1000, 4>
    
    ; Level 10: The Spider (Boss battle)
    level10Data     LEVEL_STRUCT <10, 25, 6, 500, 5>
    
; Level names
levelNames      DWORD OFFSET level1Name, OFFSET level2Name, OFFSET level3Name
                DWORD OFFSET level4Name, OFFSET level5Name, OFFSET level6Name
                DWORD OFFSET level7Name, OFFSET level8Name, OFFSET level9Name
                DWORD OFFSET level10Name

level1Name      db "THE SEWERS I", 0
level2Name      db "THE SEWERS II", 0
level3Name      db "THE BARRENS I", 0
level4Name      db "THE BARRENS II", 0
level5Name      db "NEIBOLT HOUSE I", 0
level6Name      db "NEIBOLT HOUSE II", 0
level7Name      db "THE FESTIVAL I", 0
level8Name      db "THE FESTIVAL II", 0
level9Name      db "THE DEADLIGHTS", 0
level10Name     db "THE SPIDER", 0

; ============================= CODE SECTION =================================
.code

; ----------------------------------------------------------------------------
; Procedure: InitLevels
; Description: Initialize level data array
; ----------------------------------------------------------------------------
PUBLIC InitLevels
InitLevels PROC
    push esi
    push edi
    push ecx
    
    ; Copy level data to array
    lea esi, level1Data
    lea edi, levelData
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level2Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level3Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level4Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level5Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level6Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level7Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level8Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level9Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    lea esi, level10Data
    mov ecx, SIZEOF LEVEL_STRUCT
    rep movsb
    
    pop ecx
    pop edi
    pop esi
    ret
InitLevels ENDP

; ----------------------------------------------------------------------------
; Procedure: GetLevelData
; Description: Get level data for specific level
; Parameters: levelNum (1-10)
; Returns: EAX = pointer to LEVEL_STRUCT
; ----------------------------------------------------------------------------
PUBLIC GetLevelData
GetLevelData PROC levelNum:DWORD
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, MAX_LEVELS
    jge InvalidLevel
    
    ; Calculate offset: index * SIZEOF LEVEL_STRUCT
    mov edx, SIZEOF LEVEL_STRUCT
    imul eax, edx
    
    ; Return pointer
    lea edx, levelData
    add eax, edx
    jmp Done
    
InvalidLevel:
    xor eax, eax                ; Return NULL
    
Done:
    ret
GetLevelData ENDP

; ----------------------------------------------------------------------------
; Procedure: GetLevelName
; Description: Get level name string
; Parameters: levelNum (1-10)
; Returns: EAX = pointer to level name string
; ----------------------------------------------------------------------------
PUBLIC GetLevelName
GetLevelName PROC levelNum:DWORD
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, MAX_LEVELS
    jge InvalidLevelName
    
    ; Get pointer from array
    mov edx, 4                  ; DWORD size
    imul eax, edx
    lea edx, levelNames
    add eax, edx
    mov eax, [eax]              ; Dereference to get string pointer
    jmp DoneName
    
InvalidLevelName:
    xor eax, eax                ; Return NULL
    
DoneName:
    ret
GetLevelName ENDP

END
