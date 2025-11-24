# FIX FOR LNK2019 ERROR - timeGetTime

## Problem
Linker errors:
- LNK2019: unresolved external symbol _timeGetTime@0 referenced in function _StateMachine@0
- LNK2001: unresolved external symbol _timeGetTime@0  
- LNK1120: 1 unresolved externals

## Root Cause
The Visual Studio project file is missing the `winmm.lib` library dependency in the linker settings.

## Solution

### OPTION 1: Quick Fix via Visual Studio UI (Recommended)

1. **Close and Reopen Solution**
   - Close Visual Studio
   - Reopen the solution

2. **Update Project Properties**
   - Right-click on "Shooting BalloonV4" project ? Properties
   - Configuration: "All Configurations"
   - Platform: "All Platforms"
   - Navigate to: **Linker ? Input**
   - In **Additional Dependencies**, add:
     ```
     kernel32.lib;user32.lib;gdi32.lib;winmm.lib;%(AdditionalDependencies)
     ```

3. **Also Configure MASM Settings**
   - Navigate to: **Microsoft Macro Assembler ? General**
   - Set **Use Safe Exception Handlers**: No (for Win32 only)
   - Set **Include Paths**: `$(ProjectDir)`

4. **Set Entry Point**
   - Navigate to: **Linker ? Advanced**
   - Set **Entry Point**: `main`

5. **Apply and Rebuild**
   - Click OK
   - Build ? Rebuild Solution (Ctrl+Shift+B)

---

### OPTION 2: Replace Project File

1. **Close Visual Studio**

2. **Backup Current Project**
   ```cmd
   copy "Shooting BalloonV4.vcxproj" "Shooting BalloonV4.vcxproj.backup"
   ```

3. **Replace with Fixed Version**
   ```cmd
   copy "Shooting BalloonV4_FIXED.vcxproj" "Shooting BalloonV4.vcxproj"
   ```

4. **Reopen Visual Studio**
   - Open the solution
   - Build (Ctrl+Shift+B)

---

### OPTION 3: Use build.bat (Already Working)

The `build.bat` script already includes `winmm.lib` and works correctly:

```cmd
cd "Shooting BalloonV4"
build.bat
```

This will produce `Debug\ShootingBalloon.exe` successfully.

---

## Verification

After applying the fix, you should see:

```
1>------ Build started: Project: Shooting BalloonV4, Configuration: Debug Win32 ------
1>Assembling: main.asm
1>Assembling: utils.asm
1>Assembling: render.asm
1>Assembling: states.asm
1>Assembling: physics.asm
1>Assembling: levels.asm
1>Linking...
1>Shooting BalloonV4.vcxproj -> ...\Debug\ShootingBalloon.exe
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

---

## Why This Happened

The `timeGetTime` function is part of the Windows Multimedia API (`winmm.lib`). The function is used in:
- `main.asm` - StateMachine procedure (line ~140)
- `physics.asm` - InitGame, UpdateGame procedures

Even though the PROTO is correctly declared in `bindings.inc`:
```asm
timeGetTime PROTO STDCALL
```

The linker needs the actual library file to resolve the symbol at link time.

---

## Files That Use timeGetTime

### main.asm
```asm
invoke timeGetTime
```

### physics.asm
```asm
invoke timeGetTime
mov lastFearUpdate, eax
mov balloonSpawnTimer, eax
```

All these calls require `winmm.lib` to be linked.

---

## Summary

? **Root Cause**: Missing `winmm.lib` in Visual Studio linker settings
? **Solution**: Add `winmm.lib` to Additional Dependencies
? **Alternative**: Use `build.bat` which already works correctly
? **Verification**: Build succeeds with no LNK2019 errors

Choose Option 1 for the cleanest fix, or use Option 3 if you prefer command-line building.
