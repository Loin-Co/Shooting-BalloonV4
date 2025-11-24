# VISUAL STUDIO BUILD ERROR - DETAILED EXPLANATION

## Your Current Error

```
Error LNK2019: unresolved external symbol _timeGetTime@0 referenced in function _StateMachine@0
Error LNK2001: unresolved external symbol _timeGetTime@0
Error LNK1120: 1 unresolved externals
```

## What This Means

### The Problem
Visual Studio's **linker** cannot find the `timeGetTime` function because the library file (`winmm.lib`) that contains it is NOT included in the link step.

### Why It Happens
Your `bindings.inc` correctly declares:
```asm
timeGetTime PROTO STDCALL
```

Your `main.asm` correctly calls it:
```asm
invoke timeGetTime
```

BUT... when Visual Studio **links** all the `.obj` files together, it needs the **library files** (`.lib`) to resolve external symbols.

## The Assembly ? Linking Process

```
Step 1: ASSEMBLE
main.asm ? ml.exe ? main.obj ? (This works!)
utils.asm ? ml.exe ? utils.obj ?
render.asm ? ml.exe ? render.obj ?
states.asm ? ml.exe ? states.obj ?
physics.asm ? ml.exe ? physics.obj ?
levels.asm ? ml.exe ? levels.obj ?

Step 2: LINK
main.obj + utils.obj + render.obj + ... ? link.exe ? ShootingBalloon.exe

During linking, link.exe sees:
- A call to _timeGetTime@0 in main.obj
- No definition of _timeGetTime@0 in any .obj file
- Looks in kernel32.lib ? Not there
- Looks in user32.lib ? Not there
- Looks in gdi32.lib ? Not there
- Doesn't look in winmm.lib ? BECAUSE IT'S NOT IN THE PROJECT!

ERROR: Unresolved external symbol!
```

## The Fix - Add winmm.lib to Visual Studio Project

### Why winmm.lib?
Windows Multimedia library contains timing and sound functions:
- `timeGetTime` - Get system time in milliseconds
- `PlaySound` - Play audio
- `mciSendCommand` - Control multimedia devices
- etc.

### What Your Project Currently Has

Looking at your project file structure, it's likely missing the library specification.

Current (BROKEN):
```xml
<Link>
  <SubSystem>Console</SubSystem>
  <GenerateDebugInformation>true</GenerateDebugInformation>
  <!-- NO AdditionalDependencies! -->
</Link>
```

Needed (FIXED):
```xml
<Link>
  <SubSystem>Console</SubSystem>
  <GenerateDebugInformation>true</GenerateDebugInformation>
  <EntryPointSymbol>main</EntryPointSymbol>
  <AdditionalDependencies>kernel32.lib;user32.lib;gdi32.lib;winmm.lib;%(AdditionalDependencies)</AdditionalDependencies>
</Link>
```

---

## SOLUTION OPTIONS

### Option A: Manual Fix in Visual Studio UI (RECOMMENDED)

**Step-by-step with exact menu locations:**

1. **Open Project Properties**
   - Menu: Project ? Shooting BalloonV4 Properties
   - OR: Right-click project in Solution Explorer ? Properties

2. **Select Configuration**
   - Top dropdown: Configuration = **All Configurations**
   - Top dropdown: Platform = **Win32**

3. **Add Libraries**
   - Left tree: Configuration Properties
   - Expand: Linker
   - Click: **Input**
   - Right panel: Find "Additional Dependencies"
   - Click the dropdown (?) on the right
   - Click: **<Edit...>**
   - In text box, type or paste:
     ```
     kernel32.lib
     user32.lib
     gdi32.lib
     winmm.lib
     ```
   - Click OK

4. **Set Entry Point**
   - Left tree: Linker ? **Advanced**
   - Right panel: Entry Point = `main`

5. **Configure MASM**
   - Left tree: Microsoft Macro Assembler ? **General**
   - Right panel: Include Paths = `$(ProjectDir)`
   - Right panel: Preserve Identifier Case = **Yes**

6. **For Win32 Platform ONLY:**
   - Still in MASM ? General
   - Right panel: Use Safe Exception Handlers = **No**

7. **Apply and Build**
   - Click: **Apply**
   - Click: **OK**
   - Menu: Build ? Rebuild Solution
   - OR: Press **Ctrl+Shift+B**

### Option B: Use Property Sheet (QUICK!)

1. In Solution Explorer, right-click "Shooting BalloonV4" project
2. Click: **Add ? Existing Property Sheet...**
3. Browse to: `asm_libs.props` (in your project folder)
4. Click: **Open**
5. Press: **Ctrl+Shift+B** to rebuild

The property sheet now includes:
- All required libraries (kernel32, user32, gdi32, **winmm**)
- Entry point set to `main`
- MASM configuration (SafeSEH disabled, include paths)

---

## Verification

### Before Fix - Error List Shows:
```
Error  LNK2019  unresolved external symbol _timeGetTime@0 referenced in function _StateMachine@0  main.obj
Error  LNK2001  unresolved external symbol _timeGetTime@0  physics.obj
Error  LNK1120  1 unresolved externals  ShootingBalloon.exe
```

### After Fix - Build Output Shows:
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

**Success!** ?

---

## Common Issues

### "I added winmm.lib but still get the error"
- Make sure you selected **"All Configurations"** not just Debug or Release
- Make sure you selected the correct **Platform** (Win32)
- Click **Apply** before clicking OK

### "I can't find 'Additional Dependencies'"
- You must be in: Linker ? **Input** (not Linker ? General)

### "Use Safe Exception Handlers is grayed out"
- This setting only applies to Win32 (x86) platform
- For x64, it's automatically handled

### "Property sheet didn't work"
- Make sure the property sheet is listed in the project
- Right-click project ? Properties ? Property Manager
- The sheet should appear under each configuration

---

## Why This Happens in Assembly Projects

In C/C++ projects, Visual Studio automatically adds common libraries. 

In Assembly projects, **nothing is automatic**. You must explicitly specify:
- Entry point (`main`)
- All libraries needed (`kernel32.lib`, `user32.lib`, `gdi32.lib`, **`winmm.lib`**)
- MASM settings (SafeSEH, include paths)

Your project uses `timeGetTime` from `winmm.lib`, so it MUST be added to the link step.

---

## Quick Reference

| Function | Required Library |
|----------|------------------|
| GetStdHandle | kernel32.lib ? |
| WriteConsoleA | kernel32.lib ? |
| Sleep | kernel32.lib ? |
| ExitProcess | kernel32.lib ? |
| **timeGetTime** | **winmm.lib ? MISSING!** |
| GetAsyncKeyState | user32.lib ? |
| GetSystemMetrics | user32.lib ? |
| GetConsoleWindow | user32.lib ? |
| SetWindowPos | user32.lib ? |

The ? shows the missing library!

---

**Bottom line:** Add `winmm.lib` to Additional Dependencies in Visual Studio and the error will disappear! ?
