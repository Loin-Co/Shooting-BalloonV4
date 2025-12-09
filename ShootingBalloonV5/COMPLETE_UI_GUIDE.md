# ? COMPLETE SETUP GUIDE - Loading Screen & UI System

## ? Quick Start (30 seconds)

1. **Close Visual Studio** (if open)
2. **Double-click** `ADD_UI_FILES.bat`
3. **Reopen** Visual Studio solution
4. **Press F5** to run!

---

## ? What You Get

Your game now has a professional retro terminal UI with:

### 1?? **Loading Screen** (Exactly like your image!)
```
??????????????????????????????????????????????????????????????????????????
? >_ DERRY MAINFRAME - v1958                              [ SYSTEM ]     ?
?                                                                         ?
?         W E L C O M E   T O   D E R R Y   2 0 2 5                      ?
?                                                                         ?
?         [ BALLOON SHOOTER PROTOCOL INITIATED ]                         ?
?                                                                         ?
?                                                                         ?
? > Loading Memory Modules...       OK                                   ?
? > Checking Fear Sensors...        WARNING: HIGH LEVELS                 ?
? > Pennywise AI...                 ACTIVE                               ?
? > Loading Render.asm...           OK                                   ?
?                                                                         ?
?                                                                         ?
? LOADING RESOURCES:                                                     ?
?                                                                         ?
? [??????????????????????????????????????????????????????] 64%          ?
?                                                                         ?
? "They all float down here..."                                          ?
??????????????????????????????????????????????????????????????????????????
```

**Features:**
- ? Animated ASCII border with corners (??????)
- ? Dynamic header text
- ? System initialization messages with status
- ? Animated progress bar (0% ? 100%)
- ? Progress bar changes from medium blocks (?) to full blocks (?)
- ? Percentage counter updates in real-time
- ? Creepy Pennywise quote
- ? Auto-transitions to main menu after loading

### 2?? **Main Menu**
```
??????????????????????????????????????????????????????????????????????
?                                                                     ?
?         W E L C O M E   T O   D E R R Y   2 0 2 5                  ?
?                                                                     ?
?               [ BALLOON SHOOTER PROTOCOL ]                          ?
?                                                                     ?
? ????????????????????????????????????????????????????????????????   ?
?                                                                     ?
?                     >  START GAME  <                               ?
?                        SELECT LEVEL                                 ?
?                        HOW TO PLAY                                  ?
?                        EXIT TO REALITY                              ?
?                                                                     ?
?                                                                     ?
?     Arrow Keys: Navigate  |  ENTER: Select  |  ESC: Exit          ?
?           WARNING: They're waiting for you...                       ?
??????????????????????????????????????????????????????????????????????
```

**Features:**
- ? 4 menu options with hover effects
- ? Visual selection indicators (> <)
- ? Color changes on hover (orange ? red on white)
- ? Keyboard navigation (UP/DOWN arrows)
- ? Controls help at bottom
- ? Themed border and text

### 3?? **Level Selection**
```
????????????????????????????????????????????????????????????????????
?                                                                   ?
?         S E L E C T   Y O U R   F A T E                          ?
?               Choose your nightmare level                         ?
? ??????????????????????????????????????????????????????????????   ?
?                                                                   ?
?   ????????????  ????????????  ????????????  ????????????       ?
?   ?    01    ?  ?    02    ?  ?    03    ?  ?    04    ?       ?
?   ?          ?  ?          ?  ?          ?  ?          ?       ?
?   ? NEIBOLT  ?  ?  DERRY   ?  ? FUNHOUSE ?  ?DEADLIGHTS?       ?
?   ?  HOUSE   ?  ?  SEWERS  ?  ?   MAZE   ?  ?          ?       ?
?   ?   EASY   ?  ?  NORMAL  ?  ? [LOCKED] ?  ? [LOCKED] ?       ?
?   ????????????  ????????????  ????????????  ????????????       ?
?                                                                   ?
? ???????????????????????????????????????????????????????????????? ?
? ?     A good place to start...                                 ? ?
? ?     HIGH SCORE: 12500                                        ? ?
? ???????????????????????????????????????????????????????????????? ?
?                                                                   ?
?   LEFT/RIGHT: Select  |  ENTER: Begin  |  ESC: Back             ?
?               Fear feeds the beast...                             ?
????????????????????????????????????????????????????????????????????
```

**Features:**
- ? 4 level cards with names and difficulty
- ? Lock/unlock status display
- ? High score tracking per level
- ? Level descriptions
- ? LEFT/RIGHT navigation
- ? Visual selection highlight
- ? Can only start unlocked levels

---

## ? File Structure

```
ShootingBalloonV5/
??? main.asm                          [UPDATED]
??? Src/
?   ??? UI/                           [NEW FOLDER]
?   ?   ??? loading_screen.asm        [NEW] 
?   ?   ??? menu.asm                  [NEW]
?   ?   ??? level_select.asm          [NEW]
?   ??? Renderer/
?   ?   ??? render_core.asm
?   ?   ??? draw_shapes.asm           [UPDATED]
?   ??? Include/
?   ?   ??? protos.inc                [UPDATED]
?   ??? ... (other existing files)
??? ADD_UI_FILES.bat                  [NEW - Helper script]
??? ADD_UI_FILES.ps1                  [NEW - Helper script]
??? UI_IMPLEMENTATION_COMPLETE.md     [NEW - This guide]
```

---

## ?? Installation Steps

### **Method 1: Automatic (Recommended)**

1. **Close Visual Studio** completely
2. **Run** `ADD_UI_FILES.bat` (double-click it)
3. **Wait** for "SUCCESS!" message
4. **Reopen** Visual Studio
5. **Build** ? **Rebuild Solution**
6. **Press F5** to run!

### **Method 2: Manual**

If the script doesn't work, add files manually:

1. In **Solution Explorer**, right-click **ShootingBalloonV5** project
2. **Add** ? **Existing Item**
3. Navigate to `Src\UI\` folder
4. **Select all 3 files**:
   - `loading_screen.asm`
   - `menu.asm`  
   - `level_select.asm`
5. Click **Add**
6. **Build** ? **Rebuild Solution**

---

## ? Game Flow

```
START
  ?
? LOADING SCREEN
  • Shows system initialization
  • Progress bar 0% ? 100%
  • Auto-advances after ~3 seconds
  ?
? MAIN MENU
  • Select: Start, Levels, Help, Exit
  • Navigate with UP/DOWN
  • Press ENTER to select
  ?
? LEVEL SELECT (if chosen)
  • 4 levels to choose from
  • Navigate with LEFT/RIGHT
  • Shows high scores
  • Locked levels can't be started
  ?
? GAME MODE
  • Actual gameplay
  • (Your existing game logic runs here)
```

---

## ?? Controls

### Loading Screen
- **None** - Automatic progression

### Main Menu
- **? UP** - Move selection up
- **? DOWN** - Move selection down
- **ENTER** - Select menu item
- **ESC** - Exit game

### Level Select
- **? LEFT** - Previous level
- **? RIGHT** - Next level
- **ENTER** - Start level (if unlocked)
- **ESC** - Back to main menu

### In-Game (Existing)
- **? LEFT** - Move player left
- **? RIGHT** - Move player right
- **SPACE** - Shoot arrow
- **ESC** - Pause game

---

## ? Customization Guide

### **Change Loading Messages**

Edit `Src/UI/loading_screen.asm`:

```asm
; Find these lines in the .data section:
szLoadMem       db "> Loading Memory Modules...", 0
szLoadSensor    db "> Checking Fear Sensors...", 0
szLoadAI        db "> Pennywise AI...", 0
szLoadRender    db "> Loading Render.asm...", 0

; Change to whatever you want:
szLoadMem       db "> Initializing Game Engine...", 0
```

### **Change Menu Options**

Edit `Src/UI/menu.asm`:

```asm
; Find these in .data section:
szMenuPlay      db " START GAME ", 0
szMenuLevels    db " SELECT LEVEL ", 0
szMenuHelp      db " HOW TO PLAY ", 0
szMenuExit      db " EXIT TO REALITY ", 0

; Modify as needed
```

### **Change Level Names**

Edit `Src/UI/level_select.asm`:

```asm
; Level names
szLevel1        db "NEIBOLT HOUSE", 0
szLevel2        db "DERRY SEWERS", 0
szLevel3        db "FUNHOUSE MAZE", 0
szLevel4        db "DEADLIGHTS", 0

; Unlock status (1=unlocked, 0=locked)
bLevelUnlocked  db 1, 1, 0, 0

; High scores
dwHighScores    dd 12500, 8900, 0, 0
```

### **Change Colors**

Colors are defined in `Src/Include/common.inc`:

```asm
THEME_BG           EQU 00h  ; Black Background
THEME_BORDER       EQU 0Ch  ; Light Red (Neon look)
THEME_TEXT_MAIN    EQU 07h  ; Light Gray
THEME_TEXT_ACCENT  EQU 0Eh  ; Yellow
THEME_WARNING      EQU 04h  ; Dark Red
THEME_BTN_HOVER    EQU 4Fh  ; White on Red
```

Change the values to customize your color scheme!

---

## ? Testing Checklist

After building, test these:

- [ ] Loading screen appears first
- [ ] Progress bar animates from 0% to 100%
- [ ] Loading messages appear one by one
- [ ] Auto-transitions to menu after loading
- [ ] Menu appears with 4 options
- [ ] UP/DOWN arrows navigate menu
- [ ] Menu items highlight on hover
- [ ] ENTER selects menu option
- [ ] Level select shows 4 level cards
- [ ] LEFT/RIGHT navigate levels
- [ ] Locked levels show [LOCKED]
- [ ] High scores display correctly
- [ ] ESC returns to previous screen
- [ ] Can start unlocked levels

---

## ? Troubleshooting

### **Build Errors: "Cannot open file: common.inc"**

This means MASM include path isn't set. Fix:

1. Right-click project ? **Properties**
2. Expand **Microsoft Macro Assembler** ? **General**
3. Set **Include Paths** to: `$(ProjectDir)Src\Include`
4. Click **Apply** ? **OK**
5. Rebuild solution

### **"Unresolved external symbol ShowLoadingScreen"**

The UI files aren't added to the project:

1. Check if `Src\UI\` files are in **Solution Explorer**
2. If not, use **Add Existing Item** to add them
3. Rebuild solution

### **Progress bar doesn't animate**

Check if `Sleep` function is working:

```asm
; In loading_screen.asm, these control timing:
invoke Sleep, 400   ; 400 milliseconds pause
```

Increase values if it's too fast.

### **Menu doesn't respond to keyboard**

Ensure `user32.lib` is linked:

1. Right-click project ? **Properties**
2. **Linker** ? **Input** ? **Additional Dependencies**
3. Add: `user32.lib kernel32.lib msvcrt.lib`

### **Crash on startup**

Check the Output window for specific errors:

1. Menu: **View** ? **Output**
2. Look for assembly or linker errors
3. Ensure all `.asm` files compile successfully

---

## ? Performance Notes

- Loading screen takes ~3 seconds total
- Progress bar animation: ~1.5 seconds
- Menu rendering: < 16ms per frame
- All UI runs at 60 FPS target

---

## ? Credits

- **Theme**: IT (Stephen King) / Pennywise aesthetic
- **Graphics**: Retro ASCII terminal UI
- **Architecture**: x86 Assembly (MASM)
- **Platform**: Windows Console API

---

## ? Next Development Steps

1. ? Loading screen - **DONE**
2. ? Main menu - **DONE**
3. ? Level select - **DONE**
4. ? Gameplay implementation - **Your next task**
5. ? Pause menu
6. ? Game over screen
7. ? High score persistence
8. ? Sound effects
9. ? Jumpscare animations

---

**Enjoy your retro terminal game! ??**

For questions or issues, check the troubleshooting section or review the inline comments in the `.asm` files.
