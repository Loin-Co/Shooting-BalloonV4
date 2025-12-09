# Build Instructions - IT: Welcome to Derry 2025

## ? Quick Build (Recommended)

### Option 1: Using the Build Script
1. Open a **Visual Studio Developer Command Prompt** (x86)
2. Navigate to the project directory:
   ```cmd
   cd "D:\Computer aRCHITECTURE\fINALS\Shooting Ballon V5\ShootingBalloonV5"
   ```
3. Run the build script:
   ```cmd
   build.bat
   ```
4. If successful, run the game:
   ```cmd
   Debug\ShootingBalloonV5.exe
   ```

### Option 2: Using Visual Studio

#### Prerequisites
1. **Enable MASM Build Customizations:**
   - Right-click project ? Build Dependencies ? Build Customizations
   - Check ? **masm(.targets, .props)**
   - Click OK

2. **Import the Property Sheet:**
   - Right-click project in Solution Explorer
   - Add ? Existing Property Sheet
   - Select `MASM32.props`
   - Click Open

3. **Build:**
   - Build ? Rebuild Solution (Ctrl+Shift+B)

---

## ?? Manual Build (Advanced)

If the above methods don't work, manually build from command line:

```cmd
@echo off
set INC=Src\Include

REM Assemble
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\main.obj" main.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\global_data.obj" Src\Core\global_data.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\sys_init.obj" Src\Initializer\sys_init.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\render_core.obj" Src\Renderer\render_core.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\draw_shapes.obj" Src\Renderer\draw_shapes.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\input_mgr.obj" Src\Input\input_mgr.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\player.obj" Src\GameLogic\player.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\enemies.obj" Src\GameLogic\enemies.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\collision.obj" Src\GameLogic\collision.asm
ml.exe /c /coff /Cp /Zi /I"%INC%" /Fo"Debug\audio_mgr.obj" Src\Audio\audio_mgr.asm

REM Link
link.exe /SUBSYSTEM:CONSOLE /ENTRY:start /OUT:"Debug\ShootingBalloonV5.exe" ^
    Debug\main.obj Debug\global_data.obj Debug\sys_init.obj ^
    Debug\render_core.obj Debug\draw_shapes.obj Debug\input_mgr.obj ^
    Debug\player.obj Debug\enemies.obj Debug\collision.obj ^
    Debug\audio_mgr.obj ^
    kernel32.lib user32.lib msvcrt.lib
```

---

## ? Fixed Issues

The following issues have been resolved:

### 1. **Include Path Resolution**
   - **Problem:** `A1000: cannot open file : windows.inc`
   - **Fix:** All include files now use short names (e.g., `include windows.inc`)
   - **Path:** Set via MASM32.props ? `$(ProjectDir)Src\Include`

### 2. **TYPEDEF Syntax Error**
   - **Problem:** `error A2008: syntax error : TYPEDEF`
   - **Fix:** Changed from `TYPEDEF DWORD HANDLE` to `HANDLE TYPEDEF DWORD`

### 3. **Structure Redefinitions**
   - **Problem:** Multiple definitions of `CHAR_INFO`, `COORD`, `SMALL_RECT`
   - **Fix:** Added `IFNDEF` guards and removed duplicates

### 4. **Missing Dependencies**
   - **Fix:** Added `user32.lib` to linker dependencies in MASM32.props

---

## ?? Project Structure

```
ShootingBalloonV5/
??? main.asm                    # Entry point & game loop
??? build.bat                   # Automated build script
??? MASM32.props                # Visual Studio property sheet
??? Src/
?   ??? Include/                # Header files
?   ?   ??? windows.inc         # Windows API declarations
?   ?   ??? kernel32.inc        # Kernel32 prototypes
?   ?   ??? user32.inc          # User32 prototypes
?   ?   ??? msvcrt.inc          # C runtime prototypes
?   ?   ??? common.inc          # Game constants & structures
?   ?   ??? protos.inc          # Function prototypes
?   ??? Core/
?   ?   ??? global_data.asm     # Global variables
?   ??? Initializer/
?   ?   ??? sys_init.asm        # System initialization
?   ??? Renderer/
?   ?   ??? render_core.asm     # Double-buffered rendering
?   ?   ??? draw_shapes.asm     # Drawing primitives
?   ??? Input/
?   ?   ??? input_mgr.asm       # Input handling
?   ??? GameLogic/
?   ?   ??? player.asm          # Player logic
?   ?   ??? enemies.asm         # Balloon logic
?   ?   ??? collision.asm       # Collision detection
?   ??? Audio/
?       ??? audio_mgr.asm       # Audio system
??? Debug/                      # Output directory
```

---

## ?? Controls

- **Arrow Keys**: Move archer left/right
- **SPACE**: Shoot arrow
- **ENTER**: Select menu item
- **ESC**: Pause game / Exit to menu

---

## ?? Troubleshooting

### "ml.exe not found"
**Solution:** Open a **Visual Studio Developer Command Prompt** instead of regular CMD

### "Cannot open file"
**Solution:** Make sure you're running from the project root directory where `main.asm` is located

### "Unresolved external symbol"
**Solution:** Make sure all `.obj` files are included in the link command

### Still having issues?
1. Clean the solution: `Build ? Clean Solution`
2. Delete the `Debug` folder
3. Run `build.bat` again

---

## ?? Notes

- **Target:** x86 (32-bit)
- **Assembler:** MASM 6.14+ (included with Visual Studio)
- **OS:** Windows (Console Application)
- **Frame Rate:** ~60 FPS

---

**Built with ?? for Computer Architecture Finals**
