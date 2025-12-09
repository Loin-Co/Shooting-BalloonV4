# IT: Welcome to Derry 2025 - The 8086 Arcade Edition

A horror-themed balloon shooting game written in x86 Assembly (MASM32).

## Project Structure

```
ShootingBalloonV5/
??? main.asm                    # Entry point and main game loop
??? Src/
?   ??? Include/
?   ?   ??? common.inc         # Constants, structures, and color definitions
?   ?   ??? protos.inc         # Function prototypes
?   ??? Core/
?   ?   ??? global_data.asm    # Global game state variables
?   ??? Initializer/
?   ?   ??? sys_init.asm       # System initialization (console, audio, memory)
?   ??? Renderer/
?   ?   ??? render_core.asm    # Double-buffered graphics engine
?   ?   ??? draw_shapes.asm    # Drawing primitives (pixel, string, rect, flash)
?   ??? GameLogic/
?   ?   ??? player.asm         # Player movement and shooting
?   ?   ??? enemies.asm        # Balloon movement and spawning
?   ?   ??? collision.asm      # Collision detection and jumpscare trigger
?   ??? Input/
?   ?   ??? input_mgr.asm      # Keyboard input handling
?   ??? Audio/
?       ??? audio_mgr.asm      # Sound effect management
??? Assets/
    ??? shoot.wav              # (To be added) Arrow shooting sound
    ??? pop.wav                # (To be added) Balloon pop sound
    ??? scream.wav             # (To be added) Jumpscare scream
```

## Game States

- **STATE_SPLASH** (0): Splash screen with game title
- **STATE_MENU** (1): Main menu
- **STATE_LEVEL_SELECT** (2): Level selection screen
- **STATE_PLAYING** (3): Active gameplay
- **STATE_PAUSED** (4): Paused game
- **STATE_GAME_OVER** (5): Game over screen
- **STATE_JUMPSCARE** (6): Jumpscare sequence (triggered by wrong balloon)
- **STATE_EXIT** (7): Exit game

## Color Theme

The game uses a retro horror aesthetic with red and black high contrast:

- **THEME_BG** (00h): Black background
- **THEME_BORDER** (0Ch): Light Red (neon look for borders)
- **THEME_TEXT_MAIN** (07h): Light Gray (standard text)
- **THEME_TEXT_ACCENT** (0Eh): Yellow (scores, player stats)
- **THEME_WARNING** (04h): Dark Red (danger indicators)
- **THEME_PLAYER** (0Eh): Yellow (player archer/arrow)
- **THEME_BALLOON_SAFE** (0Ch): Light Red (safe balloons)
- **THEME_BALLOON_TRAP** (0Fh): White (Pennywise/trap balloon)

## Controls

- **Arrow Keys**: Move player / Navigate menus
- **SPACE**: Shoot arrow
- **ENTER**: Select menu item
- **ESC**: Pause game / Exit to menu

## Game Mechanics

### Player
- Fixed vertical position at Y=23 (bottom of screen)
- Horizontal movement (X: 1 to SCREEN_WIDTH-2)
- Can shoot vertical projectiles (arrows)

### Balloons
- **Safe Balloons** (Red): Award points when hit
- **Bonus Balloons** (Yellow): Award extra points
- **Trap Balloons** (White): Trigger jumpscare when hit ? Game Over

### Rendering
- Double-buffered using CHAR_INFO array
- Target 60 FPS with frame timing
- Uses WriteConsoleOutput for presentation

## Building the Project

This is a MASM32 assembly project. To build:

1. Ensure MASM32 is installed (typically at `C:\masm32`)
2. Use the Visual Studio project file or command line:
   ```
   ml /c /coff /Cp main.asm
   ml /c /coff /Cp Src\Core\global_data.asm
   ml /c /coff /Cp Src\Renderer\render_core.asm
   ... (repeat for all .asm files)
   link /SUBSYSTEM:CONSOLE /OUT:game.exe *.obj
   ```

## Current Implementation Status

### ? Completed
- Main game loop with state machine
- Double-buffered rendering system
- Basic drawing primitives (pixel, string, rectangle)
- Console initialization
- Input handling framework
- Global game state management
- Frame timing for 60 FPS

### ?? To Be Implemented
- Arrow entity management
- Balloon entity management with horizontal movement
- Full collision detection system
- Sound playback integration
- Complete menu UI rendering
- Level progression system
- Score tracking and display
- Lives and fear meter mechanics
- Loading screen with progress bar
- High score persistence

## Technical Notes

- **Architecture**: x86 (32-bit)
- **Assembler**: MASM32
- **Target**: Windows Console Application
- **Buffer Size**: 80x25 characters (CHAR_INFO array)
- **Frame Rate**: ~60 FPS (16ms per frame)

## Theme: IT (2025)

The game is themed after Stephen King's "IT" set in Derry, Maine. Players must shoot balloons at a carnival, but beware - hitting the wrong balloon triggers a Pennywise jumpscare!

---

**Version**: 1.0  
**Developer**: Architecture Finals Project  
**"They all float down here..."**
