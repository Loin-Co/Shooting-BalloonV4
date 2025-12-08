# Level Selection Screen Implementation

## Overview
Successfully implemented a level selection screen that appears after selecting "START GAME" from the main menu and before entering actual gameplay. The screen shows up to 6 levels with unlock status, star ratings, and best scores.

## Files Modified

### 1. **Src/Include/common.inc**
- Added `STATE_LEVEL_SELECT` constant (value 2)
- Renumbered subsequent states:
  - STATE_GAME = 3
  - STATE_PAUSE = 4
  - STATE_GAMEOVER = 5
  - STATE_VICTORY = 6

### 2. **Src/Levels/levels.asm**
**New Data Structures:**
- `levelUnlocked` - BYTE array tracking which levels are unlocked (first 3 unlocked by default)
- `levelBestScores` - DWORD array storing best score for each level
- `selectedLevel` - Current selection in level select menu (0-based index)

**Updated Level Names:**
```asm
level1Name: "THE BARRENS (Easy)"
level2Name: "NEIBOLT STREET (Easy)"
level3Name: "DERRY CARNIVAL (Med)"
level4Name: "CANAL DAYS (Med)"
level5Name: "THE SEWERS (Hard)"
level6Name: "IT'S LAIR (Expert)"
```

**New Functions:**
- `IsLevelUnlocked` - Check if level is unlocked
- `UnlockLevel` - Unlock a specific level
- `UpdateBestScore` - Update best score if new score is higher
- `GetBestScore` - Get best score for a level

### 3. **Src/States/states.asm**
**New Strings:**
```asm
levelSelectTitle: "SELECT LOCATION"
levelSelectFooter: "[W/S]: Navigate   [ENTER]: Play   [ESC]: Back"
levelStarFilled: filled block (219)
levelStarEmpty: light shade (176)
levelBestLabel: "BEST: "
levelLockedLabel: "[ LOCKED ]"
```

**New Procedure: `RenderLevelSelect`**
- Displays level selection UI with:
  - Title at top
  - 6 levels listed vertically
  - Star rating (3 stars max based on score thresholds):
    - ??? = Score > 100
    - ??? = Score > 250
    - ??? = Score > 400
  - Best score display
  - Locked/Unlocked status
  - Highlighted selection
  - Footer with controls

### 4. **Src/Input/input_mgr.asm**
**Modified `HandleMenuInput`:**
- Changed "START GAME" action to transition to `STATE_LEVEL_SELECT` instead of `STATE_GAME`
- Resets `selectedLevel` to 0 when entering level select

**New Procedure: `HandleLevelSelectInput`**
- **W key**: Move selection up (min 0)
- **S key**: Move selection down (max 5 for 6 levels)
- **ENTER**: Start selected level if unlocked
  - Sets `currentLevel` to selected level number (1-based)
  - Calls `InitGame`
  - Transitions to `STATE_GAME`
- **ESC**: Return to main menu

**Updated `HandleInput` dispatcher:**
- Added case for `STATE_LEVEL_SELECT` ? calls `HandleLevelSelectInput`

### 5. **Src/Core/main.asm**
**Updated `StateMachine`:**
- Added `HandleLevelSelect` case:
  ```asm
  HandleLevelSelect:
      call HandleInput
      call RenderLevelSelect
      jmp EndStateCheck
  ```

### 6. **Src/Include/protos.inc**
**New Prototypes:**
```asm
; States
RenderLevelSelect PROTO

; Levels
IsLevelUnlocked PROTO :DWORD
UnlockLevel PROTO :DWORD
UpdateBestScore PROTO :DWORD, :DWORD
GetBestScore PROTO :DWORD
```

## Level Selection Screen Layout

```
???????????????????????????????????????????????????????????????????????????
?                         SELECT LOCATION                                  ?
?                                                                          ?
?   1. THE BARRENS (Easy)         [ ? ? ? ]   BEST: 450                  ?
?                                                                          ?
?   2. NEIBOLT STREET (Easy)      [ ? ? ? ]   BEST: 380                  ?
?                                                                          ?
?   3. DERRY CARNIVAL (Med)       [ ? ? ? ]   BEST: 290                  ?
?                                                                          ?
?   4. CANAL DAYS (Med)           [ LOCKED ]                              ?
?                                                                          ?
?   5. THE SEWERS (Hard)          [ LOCKED ]                              ?
?                                                                          ?
?   6. IT'S LAIR (Expert)         [ LOCKED ]                              ?
?                                                                          ?
?                                                                          ?
?         [W/S]: Navigate   [ENTER]: Play   [ESC]: Back                   ?
???????????????????????????????????????????????????????????????????????????
```

## Star Rating System

The star rating is purely cosmetic and based on best score thresholds:

| Stars | Score Required |
|-------|----------------|
| ???   | > 100          |
| ???   | > 250          |
| ???   | > 400          |

## Level Unlock Progression

By default:
- Levels 1-3 are unlocked
- Levels 4-6 are locked

To unlock levels during gameplay, call:
```asm
invoke UnlockLevel, levelNum  ; levelNum = 1-9
```

## Demo Best Scores

For demonstration purposes, the first 3 levels have pre-filled best scores:
- Level 1: 450
- Level 2: 380
- Level 3: 290

## Game Flow

```
SPLASH SCREEN
     ?
MAIN MENU
     ? (Select "START GAME")
LEVEL SELECT ????
     ? (Select Level + ENTER)
GAME STATE
     ? (ESC or Game Over)
MAIN MENU ???????
```

## Integration Notes

1. **currentLevel Variable**: Ensure this is properly exported from physics.asm and imported where needed
2. **Score Tracking**: After completing a level, call `UpdateBestScore` with the level number and final score
3. **Level Unlocking**: After beating a level, call `UnlockLevel` for the next level
4. **State Machine**: All state transitions handled automatically through `nextState` variable

## Testing

? Build successful - all files compile without errors
? State machine updated to handle level select
? Input handling for navigation implemented
? Rendering displays 6 levels with proper formatting
? Locked levels prevent entry when ENTER is pressed

## Future Enhancements

- [ ] Save/load level progress and best scores to file
- [ ] Add difficulty indicators with different colors
- [ ] Animate star fills
- [ ] Add level preview/description text
- [ ] Sound effects for navigation and selection
- [ ] Unlocking animation/effect

---

**Status**: ? COMPLETE - Ready for testing
**Date**: December 2024
**Build**: PASSING
