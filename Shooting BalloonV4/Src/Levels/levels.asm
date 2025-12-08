; ============================================================================
; levels.asm - Level Progression Data and Mechanics
; Location: Src/Levels/
; ============================================================================

.386
.model flat, stdcall
option casemap:none

include Src\Include\common.inc
include Src\Include\protos.inc

; ============================= DATA SECTION =================================
.data
    ; Level definitions array
    PUBLIC levelData
    levelData       LEVEL_STRUCT 10 dup(<>)
    
    ; Level 1-2: The Barrens (Easy)
    level1Data      LEVEL_STRUCT <1, 5, 1, 5000, 0>
    level2Data      LEVEL_STRUCT <2, 7, 1, 4500, 0>
    
    ; Level 3: Neibolt Street (Easy)
    level3Data      LEVEL_STRUCT <3, 8, 2, 4000, 1>
    
    ; Level 4-5: Derry Carnival (Medium)
    level4Data      LEVEL_STRUCT <4, 10, 2, 3500, 2>
    level5Data      LEVEL_STRUCT <5, 12, 3, 3000, 2>
    
    ; Level 6-7: Canal Days (Medium)
    level6Data      LEVEL_STRUCT <6, 14, 3, 2500, 2>
    level7Data      LEVEL_STRUCT <7, 16, 4, 2000, 2>
    
    ; Level 8: The Sewers (Hard)
    level8Data      LEVEL_STRUCT <8, 18, 4, 1500, 1>
    
    ; Level 9: It's Lair (Expert)
    level9Data      LEVEL_STRUCT <9, 20, 5, 1000, 4>
    
    ; Level 10: Boss (not used in standard level select)
    level10Data     LEVEL_STRUCT <10, 25, 6, 500, 5>
    
; Level names for display
levelNames      DWORD OFFSET level1Name, OFFSET level2Name, OFFSET level3Name
                DWORD OFFSET level4Name, OFFSET level5Name, OFFSET level6Name
                DWORD OFFSET level7Name, OFFSET level8Name, OFFSET level9Name

level1Name      db "THE BARRENS (Easy)", 0
level2Name      db "NEIBOLT STREET (Easy)", 0
level3Name      db "DERRY CARNIVAL (Med)", 0
level4Name      db "CANAL DAYS (Med)", 0
level5Name      db "THE SEWERS (Hard)", 0
level6Name      db "IT'S LAIR (Expert)", 0
level7Name      db "LEVEL 7 (TBD)", 0
level8Name      db "LEVEL 8 (TBD)", 0
level9Name      db "LEVEL 9 (TBD)", 0

; Level progression data (0 = locked, 1+ = unlocked with stars earned)
PUBLIC levelUnlocked
PUBLIC levelBestScores
PUBLIC selectedLevel

levelUnlocked   BYTE 1, 1, 1, 0, 0, 0, 0, 0, 0  ; First 3 levels unlocked by default
levelBestScores DWORD 450, 380, 290, 0, 0, 0, 0, 0, 0  ; Pre-filled for demo
selectedLevel   DWORD 0  ; Current selection (0-based, for levels 1-6 visible)

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
    cmp eax, 9                  ; Only 9 level names (0-8)
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

; ----------------------------------------------------------------------------
; Procedure: IsLevelUnlocked
; Description: Check if a level is unlocked
; Parameters: levelNum (1-9, for levels 1-6 shown)
; Returns: EAX = 1 if unlocked, 0 if locked
; ----------------------------------------------------------------------------
PUBLIC IsLevelUnlocked
IsLevelUnlocked PROC levelNum:DWORD
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, 9
    jge Locked
    
    ; Check unlock status
    lea edx, levelUnlocked
    add edx, eax
    movzx eax, BYTE PTR [edx]
    jmp CheckDone
    
Locked:
    xor eax, eax
    
CheckDone:
    ret
IsLevelUnlocked ENDP

; ----------------------------------------------------------------------------
; Procedure: UnlockLevel
; Description: Unlock a specific level
; Parameters: levelNum (1-9)
; ----------------------------------------------------------------------------
PUBLIC UnlockLevel
UnlockLevel PROC levelNum:DWORD
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, 9
    jge UnlockDone
    
    ; Set unlock status
    lea edx, levelUnlocked
    add edx, eax
    mov BYTE PTR [edx], 1
    
UnlockDone:
    ret
UnlockLevel ENDP

; ----------------------------------------------------------------------------
; Procedure: UpdateBestScore
; Description: Update best score for a level if new score is higher
; Parameters: levelNum (1-9), newScore
; ----------------------------------------------------------------------------
PUBLIC UpdateBestScore
UpdateBestScore PROC levelNum:DWORD, newScore:DWORD
    LOCAL levelOffset:DWORD
    
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, 9
    jge UpdateDone
    
    ; Calculate offset in DWORD array
    mov edx, 4
    imul eax, edx
    mov levelOffset, eax
    
    ; Get current best score
    lea edx, levelBestScores
    add edx, levelOffset
    mov eax, [edx]
    
    ; Compare with new score
    mov ebx, newScore
    cmp ebx, eax
    jle UpdateDone              ; If new score not higher, skip
    
    ; Update best score
    mov [edx], ebx
    
UpdateDone:
    ret
UpdateBestScore ENDP

; ----------------------------------------------------------------------------
; Procedure: GetBestScore
; Description: Get best score for a level
; Parameters: levelNum (1-9)
; Returns: EAX = best score
; ----------------------------------------------------------------------------
PUBLIC GetBestScore
GetBestScore PROC levelNum:DWORD
    mov eax, levelNum
    dec eax                     ; Convert to 0-based index
    
    ; Bounds check
    cmp eax, 9
    jge NoScore
    
    ; Calculate offset in DWORD array
    mov edx, 4
    imul eax, edx
    
    ; Get best score
    lea edx, levelBestScores
    add edx, eax
    mov eax, [edx]
    jmp GetDone
    
NoScore:
    xor eax, eax
    
GetDone:
    ret
GetBestScore ENDP

END
