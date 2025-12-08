# ?? Project Reorganization Guide
## IT: Welcome to Derry 2025 - Modular Structure

### ? Status: Partially Reorganized
**Current Phase**: Creating modular structure alongside existing flat structure

---

## ?? New Directory Structure

```
Shooting BalloonV4/
??? Src/
?   ??? Core/
?   ?   ??? main.asm                 ? CREATED - Entry point & state machine
?   ?   ??? global_data.asm          ? CREATED - Global variables
?   ??? Renderer/
?   ?   ??? render_core.asm          ? CREATED - Double buffering engine
?   ?   ??? draw_shapes.asm          ? CREATED - Drawing primitives & game rendering
?   ??? GameLogic/
?   ?   ??? player.asm               ? TO DO - Extract from physics.asm
?   ?   ??? enemies.asm              ? TO DO - Extract from physics.asm
?   ?   ??? collision.asm            ? TO DO - Extract from physics.asm
?   ??? Input/
?   ?   ??? input_mgr.asm            ? TO DO - Extract from physics.asm
?   ??? Utils/
?   ?   ??? utils.asm                ? TO DO - Copy from root
?   ??? States/
?   ?   ??? states.asm               ? TO DO - Copy from root
?   ??? Levels/
?   ?   ??? levels.asm               ? TO DO - Copy from root
?   ??? Include/
?       ??? common.inc               ? CREATED - Constants & structures
?       ??? bindings.inc             ? CREATED - Windows API bindings
?       ??? protos.inc               ? CREATED - Function prototypes
??? Assets/
?   ??? (Future: audio files)        ? TO DO
??? (Root - legacy files remain)
```

---

## ?? Files Created

### ? Include Files
- **Src/Include/common.inc** - Game constants, structures, colors
- **Src/Include/bindings.inc** - Windows API prototypes
- **Src/Include/protos.inc** - All function prototypes (NEW)

### ? Core Module
- **Src/Core/main.asm** - Clean entry point, state machine loop
- **Src/Core/global_data.asm** - Separated global variables

### ? Renderer Module
- **Src/Renderer/render_core.asm** - Double buffer system (InitRenderer, ClearBuffer, DrawPixel, PresentFrame)
- **Src/Renderer/draw_shapes.asm** - Drawing functions (WriteString, RenderGame, RenderHUD)

---

## ? Next Steps to Complete Reorganization

### 1. GameLogic Module

**Create Src/GameLogic/player.asm**
- Extract from `physics.asm`:
  - `HandleGameInput` procedure
  - `FireProjectile` procedure
  - Player movement logic

**Create Src/GameLogic/enemies.asm**
- Extract from `physics.asm`:
  - `SpawnBalloon` procedure
  - `UpdateBalloons` procedure
  - Balloon movement/AI logic

**Create Src/GameLogic/collision.asm**
- Extract from `physics.asm`:
  - `CheckCollisions` procedure
  - Collision detection logic
  - Score/fear updates on collision

### 2. Input Module

**Create Src/Input/input_mgr.asm**
- Extract from `physics.asm`:
  - `IsKeyPressed` procedure
  - `IsKeyDown` procedure
  - `HandleInput` procedure (dispatcher)
  - `HandleMenuInput` procedure
  - `HandleGameOverInput` procedure

### 3. States Module

**Copy and update states.asm**
```bash
Copy-Item states.asm Src\States\
# Update include paths in Src\States\states.asm
```

### 4. Levels Module

**Copy and update levels.asm**
```bash
Copy-Item levels.asm Src\Levels\
# Update include paths in Src\Levels\levels.asm
```

### 5. Utils Module

**Copy utils.asm**
```bash
Copy-Item utils.asm Src\Utils\
# Update include paths in Src\Utils\utils.asm
```

---

## ?? Update Project File

After creating all modular files, update **Shooting BalloonV4_FIXED.vcxproj**:

### Change MASM Include Paths
```xml
<MASM>
  <IncludePaths>$(ProjectDir);$(ProjectDir)Src\Include</IncludePaths>
</MASM>
```

### Update File References
Replace:
```xml
<MASM Include="main.asm" />
<MASM Include="physics.asm" />
<MASM Include="render.asm" />
<MASM Include="states.asm" />
<MASM Include="utils.asm" />
<MASM Include="levels.asm" />
```

With:
```xml
<!-- Core -->
<MASM Include="Src\Core\main.asm" />
<MASM Include="Src\Core\global_data.asm" />

<!-- Renderer -->
<MASM Include="Src\Renderer\render_core.asm" />
<MASM Include="Src\Renderer\draw_shapes.asm" />

<!-- GameLogic -->
<MASM Include="Src\GameLogic\player.asm" />
<MASM Include="Src\GameLogic\enemies.asm" />
<MASM Include="Src\GameLogic\collision.asm" />

<!-- Input -->
<MASM Include="Src\Input\input_mgr.asm" />

<!-- States -->
<MASM Include="Src\States\states.asm" />

<!-- Levels -->
<MASM Include="Src\Levels\levels.asm" />

<!-- Utils -->
<MASM Include="Src\Utils\utils.asm" />
```

---

## ?? Benefits of Modular Structure

### ? Organization
- **Logical grouping** by functionality
- **Easy navigation** for developers
- **Clear responsibilities** per module

### ? Maintainability
- **Isolated changes** - modify one module without affecting others
- **Easier debugging** - know where to look for issues
- **Better version control** - cleaner diffs

### ? Scalability
- **Add features** easily (new enemy types ? enemies.asm)
- **Extend rendering** (new effects ? draw_shapes.asm)
- **New game modes** (new states ? states.asm)

### ? Build Performance
- **Incremental compilation** - only changed modules rebuild
- **Parallel builds** - multiple .asm files compile simultaneously

---

## ?? Migration Strategy

### Option A: Gradual Migration (Recommended)
1. Keep both old and new files during development
2. Test new modular structure thoroughly
3. Once verified, remove old files
4. Update project to use only Src/ folder

### Option B: Clean Break
1. Create all modular files at once
2. Update project file immediately
3. Remove old flat structure
4. Single commit migration

---

## ?? Include Pattern in All Files

All new .asm files should use:
```asm
include Src\Include\common.inc
include Src\Include\protos.inc
```

This ensures:
- ? Access to all constants
- ? Access to all structures
- ? Access to all function prototypes
- ? No need for individual PROTO declarations

---

## ?? Current Build Status

**Working**: ? Original flat structure still builds
**In Progress**: ? New modular structure (partial)
**Next**: Create remaining GameLogic/Input/States modules

---

## ?? How to Complete

Would you like me to:
1. **Complete all remaining modular files** (player.asm, enemies.asm, etc.)
2. **Update the project file** to use new structure
3. **Create a build script** for both structures
4. **Generate comparison documentation**

Let me know which approach you prefer!
