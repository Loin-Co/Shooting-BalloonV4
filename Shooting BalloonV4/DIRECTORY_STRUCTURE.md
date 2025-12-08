# ?? Project Directory Structure

## Complete Modular Organization

```
Shooting BalloonV4/
?
??? ?? Src/                                    # Source code root
?   ?
?   ??? ?? Core/                               # Entry point & main loop
?   ?   ??? main.asm                           # Program entry, state machine, 60 FPS loop
?   ?   ??? global_data.asm                    # Global variables (player, entities)
?   ?
?   ??? ?? Renderer/                           # Graphics engine
?   ?   ??? render_core.asm                    # Double buffering (DrawPixel, PresentFrame)
?   ?   ??? draw_shapes.asm                    # Drawing functions (WriteString, RenderGame)
?   ?
?   ??? ?? GameLogic/                          # Core game mechanics
?   ?   ??? game_orchestrator.asm              # Main coordinator (InitGame, UpdateGame)
?   ?   ??? player.asm                         # Player movement & shooting
?   ?   ??? enemies.asm                        # Balloon spawning & AI
?   ?   ??? collision.asm                      # Collision detection & scoring
?   ?
?   ??? ?? Input/                              # User input handling
?   ?   ??? input_mgr.asm                      # Keyboard input for all states
?   ?
?   ??? ?? States/                             # Game states & screens
?   ?   ??? states.asm                         # Splash, menu, game over screens
?   ?
?   ??? ?? Levels/                             # Level system
?   ?   ??? levels.asm                         # Level data & progression
?   ?
?   ??? ?? Utils/                              # Utility functions
?   ?   ??? utils.asm                          # Math, RNG, string operations
?   ?
?   ??? ?? Include/                            # Header files
?       ??? common.inc                         # Constants, structures, colors
?       ??? bindings.inc                       # Windows API prototypes
?       ??? protos.inc                         # ALL function prototypes
?
??? ?? Assets/                                 # Game assets (future)
?   ??? (audio files will go here)
?
??? ?? Debug/                                  # Build output
?   ??? *.obj, *.exe
?
??? ?? IT_WelcomeToDerry_2025.vcxproj          # NEW modular project file
??? ?? IT_WelcomeToDerry_2025.vcxproj.filters  # Visual Studio filters
?
??? ?? MODULAR_BUILD_GUIDE.md                  # How to build modular version
??? ?? REORGANIZATION_GUIDE.md                 # Reorganization documentation
??? ?? DOUBLE_BUFFERING_IMPLEMENTATION.md      # Rendering system docs
??? ?? RENDERING_API_REFERENCE.txt             # API reference guide
?
??? ?? migrate_to_modular.ps1                  # Migration helper script
?
??? ?? (Old files - can be removed after migration)
    ??? main.asm                               # OLD - now in Src/Core/
    ??? physics.asm                            # OLD - split into GameLogic/
    ??? render.asm                             # OLD - split into Renderer/
    ??? states.asm                             # OLD - now in Src/States/
    ??? levels.asm                             # OLD - now in Src/Levels/
    ??? utils.asm                              # OLD - now in Src/Utils/
    ??? common.inc                             # OLD - now in Src/Include/
    ??? bindings.inc                           # OLD - now in Src/Include/
    ??? Shooting BalloonV4_FIXED.vcxproj       # OLD project file
```

---

## ?? Module Responsibilities

### Core/ - Program Foundation
- **main.asm**: Entry point, state machine, game loop timing
- **global_data.asm**: Centralized global variables

### Renderer/ - Graphics System
- **render_core.asm**: Low-level buffer management
- **draw_shapes.asm**: High-level drawing & game rendering

### GameLogic/ - Game Mechanics
- **game_orchestrator.asm**: Coordinates all game systems
- **player.asm**: Player-specific logic
- **enemies.asm**: Enemy-specific logic
- **collision.asm**: Physics & interactions

### Input/ - User Interaction
- **input_mgr.asm**: Keyboard handling for all states

### States/ - Game Screens
- **states.asm**: Menu, splash, game over screens

### Levels/ - Progression System
- **levels.asm**: Level definitions & progression

### Utils/ - Shared Utilities
- **utils.asm**: Math, RNG, string helpers

### Include/ - Headers
- **common.inc**: Shared constants & types
- **bindings.inc**: Windows API
- **protos.inc**: Function prototypes

---

## ?? File Count by Category

| Category      | Files | Lines of Code (est.) |
|---------------|-------|----------------------|
| Core          | 2     | ~300                 |
| Renderer      | 2     | ~400                 |
| GameLogic     | 4     | ~700                 |
| Input         | 1     | ~250                 |
| States        | 1     | ~200                 |
| Levels        | 1     | ~200                 |
| Utils         | 1     | ~250                 |
| Include       | 3     | ~400                 |
| **TOTAL**     | **15**| **~2700**            |

---

## ?? Include Dependency Chain

```
All .asm files include:
  ??> Src/Include/common.inc    (constants, structures)
       ??> Src/Include/bindings.inc (Windows API)

Most .asm files also include:
  ??> Src/Include/protos.inc    (function prototypes)
```

This creates a clean, hierarchical include system where:
1. `bindings.inc` is at the bottom (pure Windows API)
2. `common.inc` builds on top (game-specific)
3. `protos.inc` declares all functions (linking layer)
4. `.asm` files implement the actual logic

---

## ?? Visual Studio Solution Explorer View

```
IT_WelcomeToDerry_2025
??? ?? Src
?   ??? ?? Core
?   ?   ??? main.asm
?   ?   ??? global_data.asm
?   ??? ?? Renderer
?   ?   ??? render_core.asm
?   ?   ??? draw_shapes.asm
?   ??? ?? GameLogic
?   ?   ??? game_orchestrator.asm
?   ?   ??? player.asm
?   ?   ??? enemies.asm
?   ?   ??? collision.asm
?   ??? ?? Input
?   ?   ??? input_mgr.asm
?   ??? ?? States
?   ?   ??? states.asm
?   ??? ?? Levels
?   ?   ??? levels.asm
?   ??? ?? Utils
?   ?   ??? utils.asm
?   ??? ?? Include
?       ??? common.inc
?       ??? bindings.inc
?       ??? protos.inc
??? ?? Documentation
    ??? README.md
    ??? DOUBLE_BUFFERING_IMPLEMENTATION.md
    ??? RENDERING_API_REFERENCE.txt
    ??? REORGANIZATION_GUIDE.md
    ??? MODULAR_BUILD_GUIDE.md
```

---

## ? Clean & Professional Structure

This modular organization follows industry best practices:
- ? Logical grouping by functionality
- ? Separation of concerns
- ? Easy to navigate and understand
- ? Scalable for future features
- ? Team-friendly development
- ? Professional project structure
