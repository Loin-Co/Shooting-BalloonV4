# Input Carry-Over Fix

## Problem
When pressing ENTER in the main menu to select "START GAME", the game would immediately skip the level selection screen and start playing the game. This happened because:

1. User presses ENTER in main menu
2. State transitions from `STATE_MENU` to `STATE_LEVEL_SELECT`
3. On the **same frame**, the state machine calls `HandleInput` again
4. Since the state is now `STATE_LEVEL_SELECT`, it calls `HandleLevelSelectInput`
5. The ENTER key is still pressed, so `IsKeyPressed(VK_RETURN)` returns true
6. The game immediately starts level 1

## Root Cause
The `keyStates[]` array that tracks which keys were "just pressed" (for edge detection) was not being cleared when transitioning between game states. This allowed a key press in one state to be detected again in the next state within the same frame.

## Solution
Added a `ClearKeyStates` procedure that clears all key state tracking when transitioning between game states.

### Files Modified

#### 1. `Src/Input/input_mgr.asm`
**Added:**
```asm
PUBLIC ClearKeyStates

ClearKeyStates PROC
    push edi
    push ecx
    
    ; Clear keyStates array
    mov edi, OFFSET keyStates
    mov ecx, 256
    xor eax, eax
    rep stosb
    
    pop ecx
    pop edi
    ret
ClearKeyStates ENDP
```

#### 2. `Src/Core/main.asm`
**Modified `StateTransition` procedure:**
```asm
StateTransition PROC
    ; Check if state changed
    mov eax, currentState
    cmp eax, nextState
    je @F
    
    ; Clear screen buffer before transition
    call ClearScreen
    
    ; Clear key states to prevent input carry-over  ? NEW
    call ClearKeyStates                            ? NEW
    
    ; Update state
    mov eax, nextState
    mov currentState, eax
    
@@:
    ret
StateTransition ENDP
```

#### 3. `Src/Include/protos.inc`
**Added prototype:**
```asm
ClearKeyStates PROTO
```

## How It Works

1. User presses ENTER in main menu
2. `HandleMenuInput` detects the key press and sets `nextState = STATE_LEVEL_SELECT`
3. State machine's `StateTransition` procedure detects the state change
4. **NEW**: `ClearKeyStates` is called, clearing all key press tracking
5. State updates to `STATE_LEVEL_SELECT`
6. Next frame, `HandleLevelSelectInput` is called
7. Since key states were cleared, ENTER is no longer considered "just pressed"
8. User must release and press ENTER again to select a level

## Benefits

- ? Prevents input from bleeding across state transitions
- ? Works for all keys (W, S, ENTER, ESC, etc.)
- ? Applies to all state transitions (not just menu ? level select)
- ? No artificial delays needed
- ? Clean, maintainable solution

## Testing

**Before Fix:**
```
Main Menu ? Press ENTER ? Level Select ? (Immediately) Game Start
```

**After Fix:**
```
Main Menu ? Press ENTER ? Level Select ? (Wait) ? Press ENTER ? Game Start
```

---

**Status**: ? FIXED
**Build**: ? PASSING
**Date**: December 2024
