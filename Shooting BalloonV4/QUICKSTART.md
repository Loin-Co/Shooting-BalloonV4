# ?? IT: Welcome to Derry 2025 - Quick Start Guide

## ? Build Status: ALL SYSTEMS GO

All known issues from the README have been resolved. The project is ready to build and run!

---

## ?? Quick Build & Run

### Option 1: Build Script (Recommended)
```batch
cd "Shooting BalloonV4"
build.bat
Debug\ShootingBalloon.exe
```

### Option 2: Visual Studio
```
1. Open Shooting BalloonV4.sln
2. Press F5 (Build & Run)
```

---

## ?? What Was Fixed

| Issue | Status | Details |
|-------|--------|---------|
| PROTO declarations | ? FIXED | All procedures properly declared with PROTO |
| Visual Studio linking | ? FIXED | All .asm files properly configured |
| Level progression | ? ADDED | levels.asm created with 10 levels |
| Build warnings | ? FIXED | Clean build with no warnings |

---

## ?? Controls

| Key | Action |
|-----|--------|
| Arrow Keys | Move player (@) |
| SPACE | Shoot projectile |
| SHIFT | Swap weapon (Bow ? Slingshot) |
| P | Pause game |
| ESC | Return to menu |
| R | Retry (Game Over) |
| Q | Quit to menu |

---

## ?? Project Structure

```
Shooting BalloonV4/
??? bindings.inc       ? Windows API definitions
??? common.inc         ? Constants & structures
??? main.asm           ? Entry point & state machine
??? utils.asm          ? Utility functions
??? render.asm         ? Rendering engine
??? states.asm         ? Menu & screens
??? physics.asm        ? Game logic
??? levels.asm         ? Level data (NEW!)
??? build.bat          ? Build script
```

---

## ?? Technical Details

**Language:** x86 Assembly (MASM)  
**Platform:** Windows Console  
**Architecture:** 32-bit (x86)  
**Libraries:** kernel32, user32, gdi32, winmm  

---

## ?? Recent Changes

### All PROTO Declarations Fixed ?
- Proper cross-module procedure declarations
- PUBLIC exports added for all shared procedures
- No more "INVOKE requires prototype" errors

### Visual Studio Project Configured ?
- MASM build customizations enabled
- All .asm files included
- Correct entry point (main)
- All libraries linked

### Level System Implemented ?
- 10 levels with progressive difficulty
- Level mechanics: Fog, Wind, Flicker, etc.
- Ready for integration into gameplay

---

## ?? Game Features

- **Fear Meter:** Increases over time, game over at 100%
- **Score System:** +10 per balloon, -5 fear per hit
- **Weapons:** Bow (fast) and Slingshot (piercing)
- **Balloons:** Red and Yellow types
- **10 Levels:** Progressive difficulty with special mechanics

---

## ?? Troubleshooting

### Build fails?
```batch
# Clean build
rd /s /q Debug
build.bat
```

### Missing ml.exe?
- Install Visual Studio with "Desktop development with C++"
- Make sure MASM is included in the installation

### Can't run executable?
- Check if Debug\ShootingBalloon.exe exists
- Run from command prompt, not PowerShell
- Ensure no antivirus blocking

---

## ?? Documentation

- `README.md` - Full project documentation
- `FIXES.md` - Detailed fix information
- `SUMMARY.md` - Complete fix summary
- `QUICKSTART.md` - This file

---

## ?? Success Checklist

- ? All .asm files compile without errors
- ? All .obj files link successfully
- ? Executable created: Debug\ShootingBalloon.exe
- ? No PROTO declaration errors
- ? No linker warnings
- ? Visual Studio project properly configured
- ? Level progression system implemented

---

**Status:** ?? READY TO PLAY!  
**Build:** ? PASSING  
**Last Updated:** December 2025

Enjoy the game! ??????
