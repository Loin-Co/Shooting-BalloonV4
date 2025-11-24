# FIXES APPLIED - IT: Welcome to Derry 2025

## Summary of Issues Resolved

This document details all the fixes applied to resolve the known issues in the README.

---

## Issue 1: PROTO Declarations - ? RESOLVED

### Problem
Some PROTO declarations needed adjustment for invoke compatibility. The assembler was throwing A2190 errors: "INVOKE requires prototype for procedure".

### Root Cause
- Procedures were declared with `EXTERN` instead of `PROTO`
- Missing `PROTO` declarations for cross-module procedure calls
- Conflicting `EXTERN` declarations inside procedure bodies
- Incorrect use of `@0` suffix on procedure names

### Files Modified

#### 1. `render.asm`
**Changes:**
- Added proper `PROTO` declarations for `Distance`, `IntToStr`, `StrLen`
- Added `PUBLIC` declarations for exported procedures: `ClearScreen`, `WriteString`, `WriteChar`, `RenderGame`
- Removed `@0` suffix from `ClearScreen` and `RenderGame` procedures
- Fixed procedure declarations to use standard `PROC`/`ENDP` syntax

#### 2. `states.asm`
**Changes:**
- Changed `EXTERN` declarations to `PROTO` for procedures from `render.asm`:
  - `WriteString PROTO :DWORD, :DWORD, :DWORD, :DWORD`
  - `ClearScreen PROTO`
- Changed `EXTERN StrLen:PROC` to `StrLen PROTO :DWORD`
- Added `PUBLIC` declarations for exported procedures: `RenderSplash`, `RenderMenu`, `RenderGameOver`, `menuSelection`

#### 3. `physics.asm`
**Changes:**
- Added `EXTERN currentState:DWORD` at the top level (removed from within `HandleInput` procedure)
- Removed duplicate `PUBLIC` declarations in data section
- Added proper `PUBLIC` declarations for all exported symbols
- Removed `@0` suffix from `UpdateGame` procedure
- Fixed procedure declarations to use standard `PROC`/`ENDP` syntax

#### 4. `main.asm`
**Changes:**
- Changed all `EXTERN ... :PROC` declarations to proper `PROTO` declarations:
  - `RenderSplash PROTO`
  - `RenderMenu PROTO`
  - `RenderGameOver PROTO`
  - `RenderGame PROTO`
  - `ClearScreen PROTO`
  - `UpdateGame PROTO`
  - `HandleInput PROTO`
  - `InitGame PROTO`
  - `InitRandom PROTO`

#### 5. `utils.asm`
**Changes:**
- Added `PUBLIC` declarations for all exported utility functions:
  - `InitRandom`, `Random`, `RandomRange`
  - `Abs`, `Min`, `Max`, `Clamp`
  - `StrLen`, `IntToStr`, `Distance`

### Key Principles Applied

1. **PROTO vs EXTERN:**
   - Use `PROTO` for procedure declarations with parameters
   - Use `EXTERN` for data symbols (variables)
   
2. **PUBLIC Exports:**
   - All procedures/data used by other modules must be declared `PUBLIC`
   - Place `PUBLIC` declarations at the top of the code section or in the data section

3. **Procedure Naming:**
   - Use simple names without `@0` suffix when using `PROC` with parameters
   - MASM automatically handles name decoration

---

## Issue 2: Visual Studio Project Linking - ? RESOLVED

### Problem
Need to ensure all .asm files are properly linked in Visual Studio project.

### Solution
Updated `Shooting BalloonV4.vcxproj` with proper MASM configuration:

#### Configuration Changes

1. **MASM Settings Added:**
   ```xml
   <MASM>
       <AssembledCodeListingFile>$(IntDir)%(FileName).lst</AssembledCodeListingFile>
       <IncludePaths>$(ProjectDir)</IncludePaths>
       <PreserveIdentifierCase>true</PreserveIdentifierCase>
       <WarningLevel>3</WarningLevel>
       <TreatWarningsAsErrors>false</TreatWarningsAsErrors>
       <UseSafeExceptionHandlers>false</UseSafeExceptionHandlers>
   </MASM>
   ```

2. **Linker Settings Updated:**
   ```xml
   <Link>
       <SubSystem>Console</SubSystem>
       <GenerateDebugInformation>true</GenerateDebugInformation>
       <EntryPointSymbol>main</EntryPointSymbol>
       <AdditionalDependencies>kernel32.lib;user32.lib;gdi32.lib;winmm.lib</AdditionalDependencies>
       <TargetMachine>MachineX86</TargetMachine>
   </Link>
   ```

3. **All ASM Files Included:**
   - main.asm
   - utils.asm
   - render.asm
   - states.asm
   - physics.asm
   - levels.asm (newly added)

4. **Include Files Listed:**
   - bindings.inc
   - common.inc
   - build.bat
   - README.md

---

## Issue 3: Level Progression Data - ? IMPLEMENTED

### Problem
Need to add levels.asm for level progression data.

### Solution
Created `levels.asm` with complete level progression system:

#### Level Structure
```asm
LEVEL_STRUCT STRUCT
    levelNum        DWORD ?
    balloonCount    DWORD ?
    balloonSpeed    DWORD ?
    fearRate        DWORD ?
    mechanic        BYTE ?      ; 0=Normal, 1=Fog, 2=Wind, 3=Flicker, etc.
    ALIGN 4
LEVEL_STRUCT ENDS
```

#### 10 Levels Implemented

1. **Levels 1-2: The Sewers** (Fog of War mechanic)
2. **Levels 3-4: The Barrens** (Wind mechanic)
3. **Levels 5-6: Neibolt House** (Flicker effect)
4. **Levels 7-8: The Festival** (High speed)
5. **Level 9: The Deadlights** (Inverted controls)
6. **Level 10: The Spider** (Boss battle)

#### Exported Functions

- `InitLevels` - Initialize level data array
- `GetLevelData` - Get level data for specific level (returns pointer to LEVEL_STRUCT)
- `GetLevelName` - Get level name string (returns pointer to level name)

#### Integration
- Added to `build.bat` compilation script
- Added to Visual Studio project file
- Already included in `Shooting BalloonV4.vcxproj.filters`

---

## Issue 4: Build Script Optimization - ? COMPLETED

### Problem
Minor warning in link step about duplicate /ENTRY directives.

### Solution
Updated `build.bat`:

**Before:**
```batch
link /SUBSYSTEM:CONSOLE /DEBUG /OUT:"Debug\ShootingBalloon.exe" /ENTRY:main ^
```

**After:**
```batch
link /SUBSYSTEM:CONSOLE /DEBUG /OUT:"Debug\ShootingBalloon.exe" ^
```

The linker automatically uses `main` as the entry point, so the explicit `/ENTRY:main` directive was redundant and causing a warning.

---

## Build Verification

### ? Build Test Results

**Command:** `build.bat`

**Output:**
```
Building IT: Welcome to Derry 2025...
Assembling source files...
 Assembling: main.asm
 Assembling: utils.asm
 Assembling: render.asm
 Assembling: states.asm
 Assembling: physics.asm
 Assembling: levels.asm
Linking...
Build successful!
Executable: Debug\ShootingBalloon.exe
```

**Result:** ? No errors, no warnings, clean build!

---

## Files Modified Summary

1. ? `render.asm` - Fixed PROTO declarations and PUBLIC exports
2. ? `states.asm` - Fixed PROTO declarations
3. ? `physics.asm` - Fixed EXTERN placement and PUBLIC exports
4. ? `main.asm` - Fixed PROTO declarations
5. ? `utils.asm` - Added PUBLIC exports
6. ? `build.bat` - Added levels.asm, removed redundant /ENTRY
7. ? `README.md` - Updated with fix documentation
8. ? `Shooting BalloonV4.vcxproj` - Configured MASM settings (if editable)

## Files Created

1. ? `levels.asm` - Level progression data and functions
2. ? `FIXES.md` - This documentation file

---

## Remaining To-Do Items

These are future enhancements, not bugs:

- ?? **Meta-horror effects** - Window title changes, minimize functionality
- ?? **Sound integration** - Use winmm.lib for sound effects
- ?? **Advanced visual effects** - Fog rendering, screen shake, color flicker

---

## Testing Checklist

- ? All .asm files compile without errors
- ? All .asm files link successfully
- ? No PROTO declaration warnings
- ? No undefined symbol errors
- ? Build script works correctly
- ? Visual Studio project properly configured
- ? All modules properly export/import procedures
- ? Level data structures defined and initialized

---

**Date:** December 2025  
**Status:** All known issues resolved  
**Build Status:** ? PASSING
