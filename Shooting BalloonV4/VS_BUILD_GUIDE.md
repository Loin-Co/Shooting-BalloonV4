# VISUAL STUDIO BUILD - QUICK START

## ? ZERO-DEPENDENCY BUILD IN VISUAL STUDIO

No winmm.lib required! Just 3 simple libraries.

---

## METHOD 1: Use Property Sheet (FASTEST!)

### Steps:

1. **Open** Visual Studio with your solution

2. In **Solution Explorer**, **right-click** on **"Shooting BalloonV4"** project

3. Select: **Add ? Existing Property Sheet...**

4. Browse to and select: **`asm_libs.props`**

5. Click **Open**

6. Press **Ctrl+Shift+B** to build

**That's it!** ?

The property sheet contains:
```xml
<AdditionalDependencies>kernel32.lib;user32.lib;gdi32.lib</AdditionalDependencies>
<EntryPointSymbol>main</EntryPointSymbol>
<UseSafeExceptionHandlers>false</UseSafeExceptionHandlers>
```

---

## METHOD 2: Manual Configuration

If you prefer to configure manually:

### Step 1: Open Project Properties
- **Menu**: Project ? Shooting BalloonV4 Properties
- **OR**: Right-click project ? Properties

### Step 2: Configure All Platforms
At the **top** of Properties window:
- **Configuration**: Select **"All Configurations"**
- **Platform**: Select **"Win32"**

### Step 3: Set Linker Options

**Navigate to:** Linker ? Input

- **Additional Dependencies**:
  ```
  kernel32.lib;user32.lib;gdi32.lib
  ```
  ?? **Note:** DO NOT add winmm.lib!

**Navigate to:** Linker ? Advanced

- **Entry Point**: `main`

### Step 4: Configure MASM

**Navigate to:** Microsoft Macro Assembler ? General

- **Include Paths**: `$(ProjectDir)`
- **Preserve Identifier Case**: Yes

**For Win32 Platform ONLY:**
- **Use Safe Exception Handlers**: No

### Step 5: Apply and Build

1. Click **Apply**
2. Click **OK**
3. **Build ? Rebuild Solution** (Ctrl+Shift+B)

---

## Expected Build Output

### Successful Build:
```
1>------ Build started: Project: Shooting BalloonV4, Configuration: Debug Win32 ------
1>  Assembling: main.asm
1>  Assembling: utils.asm
1>  Assembling: render.asm
1>  Assembling: states.asm
1>  Assembling: physics.asm
1>  Assembling: levels.asm
1>  Linking...
1>  Shooting BalloonV4.vcxproj -> D:\...\Debug\ShootingBalloon.exe
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

### If You See LNK2019:
```
Error LNK2019: unresolved external symbol _timeGetTime@0
```

**This means:** You haven't rebuilt yet!

**Solution:**
1. Make sure you **saved** the property changes
2. Do **Rebuild Solution** (not just Build)
3. Clean solution first if needed: Build ? Clean Solution

---

## Verify It Worked

### Check Output Window:
Should show all 6 .asm files assembling successfully with **no errors**.

### Check Error List:
Should be **0 Errors**.

### Check Debug Folder:
- File: `Debug\ShootingBalloon.exe`
- Size: ~20-21 KB
- Should exist!

### Run the Game:
Press **F5** or click **Debug ? Start Debugging**

The game should launch! ??

---

## Troubleshooting

### "Can't find Additional Dependencies"
- Make sure you're in: **Linker ? Input** (not Linker ? General)

### "Use Safe Exception Handlers is grayed out"
- This is normal for x64 platform
- Only change it for **Win32** platform

### "Property sheet didn't apply"
- Check Property Manager (View ? Property Manager)
- Make sure `asm_libs.props` is listed
- Try closing and reopening Visual Studio

### "Still getting LNK2019"
- Did you do **Rebuild** (not just Build)?
- Check that you have the latest `utils.asm` with custom timeGetTime
- Make sure **all** .asm files are included in the project

---

## Project File Checklist

Make sure these files are in your project:

### Assembly Files (.asm)
- [x] main.asm
- [x] utils.asm ? **Must have custom timeGetTime!**
- [x] render.asm
- [x] states.asm
- [x] physics.asm
- [x] levels.asm

### Include Files (.inc)
- [x] bindings.inc
- [x] common.inc

### Build Files
- [x] build.bat
- [x] asm_libs.props

---

## Libraries Explained

### ? kernel32.lib (REQUIRED)
**What it provides:**
- GetTickCount (used by our custom timeGetTime)
- GetStdHandle, WriteConsoleA
- Sleep, ExitProcess
- All core Windows functions

### ? user32.lib (REQUIRED)
**What it provides:**
- GetAsyncKeyState (keyboard input)
- GetSystemMetrics (screen size)
- GetConsoleWindow, SetWindowPos
- All user interface functions

### ? gdi32.lib (INCLUDED)
**What it provides:**
- Reserved for future graphics effects
- Not currently used heavily
- Included for potential enhancements

### ? winmm.lib (NOT NEEDED!)
**What it used to provide:**
- ~~timeGetTime~~ ? Now custom implementation!

**Why we don't need it:**
- We implemented timeGetTime ourselves
- Uses GetTickCount from kernel32.lib
- One less dependency!

---

## Custom Implementation Details

### Our timeGetTime (in utils.asm)

```asm
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
```

**Why this works:**
- GetTickCount returns milliseconds (same as timeGetTime)
- Same calling convention (STDCALL)
- Same return type (DWORD in EAX)
- Resolution is fine for 60 FPS gaming

---

## Summary

### To Build in Visual Studio:

**Quick Way:**
1. Add `asm_libs.props` property sheet
2. Build (Ctrl+Shift+B)

**Manual Way:**
1. Set libraries: kernel32.lib, user32.lib, gdi32.lib
2. Set entry point: main
3. Configure MASM settings
4. Build (Ctrl+Shift+B)

### Result:
? Successful build  
? No LNK2019 errors  
? No winmm.lib required  
? True zero-dependency!  

---

**Ready to build and play!** ??
