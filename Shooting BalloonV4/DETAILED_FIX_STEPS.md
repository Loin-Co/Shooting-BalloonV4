# STEP-BY-STEP FIX FOR VISUAL STUDIO LINKER ERROR

## Current Error
```
LNK2019: unresolved external symbol _timeGetTime@0 referenced in function _StateMachine@0
LNK2001: unresolved external symbol _timeGetTime@0
LNK1120: 1 unresolved externals
```

## Root Cause
Visual Studio is not linking `winmm.lib` (Windows Multimedia library).

---

## SOLUTION 1: Fix in Visual Studio (RECOMMENDED)

### Step 1: Open Project Properties
1. In Visual Studio, **right-click** on **"Shooting BalloonV4"** project in Solution Explorer
2. Click **"Properties"** at the bottom of the menu

### Step 2: Configure for All Configurations
At the top of the Properties window:
- Set **Configuration:** to **"All Configurations"**
- Set **Platform:** to **"Win32"** (or "All Platforms" if available)

### Step 3: Navigate to Linker Settings
In the left panel:
1. Expand **"Linker"**
2. Click on **"Input"**

### Step 4: Add Libraries
In the right panel:
1. Find **"Additional Dependencies"**
2. Click on the dropdown arrow on the right
3. Click **"Edit..."**
4. In the text box that appears, add these libraries (one per line or separated by semicolons):
   ```
   kernel32.lib
   user32.lib
   gdi32.lib
   winmm.lib
   ```
   
   OR paste this single line:
   ```
   kernel32.lib;user32.lib;gdi32.lib;winmm.lib
   ```

5. Click **"OK"**

### Step 5: Also Configure MASM Settings (Important!)

While still in Properties:

1. In left panel, expand **"Microsoft Macro Assembler"**
2. Click on **"General"**
3. Set the following:
   - **Include Paths:** `$(ProjectDir)`
   - **Preserve Identifier Case:** `Yes` or `true`

4. For **Win32 ONLY** (not x64):
   - Find **"Use Safe Exception Handlers"**
   - Set it to **"No"** or **"false"**

### Step 6: Set Entry Point

1. In left panel, go to **"Linker" ? "Advanced"**
2. Find **"Entry Point"**
3. Set it to: `main`

### Step 7: Apply and Build

1. Click **"Apply"** at the bottom
2. Click **"OK"** to close
3. In Visual Studio menu: **Build ? Rebuild Solution** (or press Ctrl+Shift+B)

---

## SOLUTION 2: Use the Fixed Project File

1. **Close Visual Studio completely**

2. **Open File Explorer**, navigate to your project folder:
   ```
   D:\Computer aRCHITECTURE\fINALS\Shooting Balloon Assembly\Shooting BalloonV4\Shooting BalloonV4\
   ```

3. **Rename the current project file** (create backup):
   - Find: `Shooting BalloonV4.vcxproj`
   - Rename to: `Shooting BalloonV4.vcxproj.OLD`

4. **Rename the fixed project file**:
   - Find: `Shooting BalloonV4_FIXED.vcxproj`
   - Rename to: `Shooting BalloonV4.vcxproj`

5. **Reopen Visual Studio**
   - Open the solution
   - Build the project (Ctrl+Shift+B)

---

## SOLUTION 3: Use build.bat (QUICKEST!)

The `build.bat` script already has all the correct settings and works perfectly:

1. Open **Command Prompt** (not PowerShell)

2. Navigate to project folder:
   ```cmd
   cd /d "D:\Computer aRCHITECTURE\fINALS\Shooting Balloon Assembly\Shooting BalloonV4\Shooting BalloonV4"
   ```

3. Run build script:
   ```cmd
   build.bat
   ```

4. Run the game:
   ```cmd
   Debug\ShootingBalloon.exe
   ```

This will compile and link everything correctly!

---

## SOLUTION 4: Manual Property Sheet Import

1. In Visual Studio, right-click on project ? **Add ? Existing Property Sheet**
2. Browse to and select: `asm_libs.props`
3. This will add the required libraries
4. Rebuild the project

---

## Verification

After applying any solution, you should see in the Build Output:

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

**NO MORE LNK2019 ERRORS!**

---

## Why This Happens

The `timeGetTime` function is defined in `winmm.dll` and requires `winmm.lib` at link time.

**Where it's used:**
- `main.asm` line 145: `invoke timeGetTime`
- `physics.asm`: In `InitGame` and `UpdateGame` procedures

Even though `bindings.inc` has the correct PROTO:
```asm
timeGetTime PROTO STDCALL
```

The **linker** needs the `.lib` file to resolve the actual function address.

---

## Quick Reference

| Function | Library Required |
|----------|------------------|
| GetStdHandle | kernel32.lib |
| WriteConsoleA | kernel32.lib |
| Sleep | kernel32.lib |
| **timeGetTime** | **winmm.lib** ? This is missing! |
| GetAsyncKeyState | user32.lib |
| GetSystemMetrics | user32.lib |
| SetWindowPos | user32.lib |

---

## Recommended Solution

**Use SOLUTION 1** if you want to keep using Visual Studio.

**Use SOLUTION 3** if you just want to build and run quickly.

Both will work perfectly!
