; ============================================================================
; protos.inc - Function Prototypes for All Modules
; Include this file after common.inc to access all public functions
; ============================================================================

; ============================= CORE (main.asm) ==============================
; No public functions from main - it's the entry point

; ============================= RENDERER (render_core.asm + draw_shapes.asm) =
InitRenderer PROTO
ClearBuffer PROTO
DrawPixel PROTO :DWORD, :DWORD, :DWORD, :DWORD
PresentFrame PROTO
ClearScreen PROTO
WriteString PROTO :DWORD, :DWORD, :DWORD, :DWORD
WriteChar PROTO :DWORD, :DWORD, :DWORD, :DWORD
RenderGame PROTO

; ============================= STATES (states.asm) ==========================
RenderSplash PROTO
RenderMenu PROTO
RenderGameOver PROTO

; ============================= GAME LOGIC (player.asm) ======================
InitPlayer PROTO
UpdatePlayerMovement PROTO :SDWORD, :SDWORD
FireProjectile PROTO

; ============================= GAME LOGIC (enemies.asm) =====================
InitBalloons PROTO
SpawnBalloon PROTO :DWORD
UpdateBalloons PROTO

; ============================= GAME LOGIC (collision.asm) ===================
UpdateProjectiles PROTO
CheckCollisions PROTO
UpdateGameLogic PROTO

; ============================= GAME LOGIC (Main Orchestrator) ===============
InitGame PROTO
UpdateGame PROTO

; ============================= INPUT (input_mgr.asm) ========================
HandleInput PROTO
IsKeyPressed PROTO :DWORD
IsKeyDown PROTO :DWORD

; ============================= LEVELS (levels.asm) ==========================
InitLevels PROTO
GetLevelData PROTO :DWORD
GetLevelName PROTO :DWORD

; ============================= UTILS (utils.asm) ============================
InitRandom PROTO
Random PROTO
RandomRange PROTO :DWORD
Abs PROTO
Min PROTO :DWORD, :DWORD
Max PROTO :DWORD, :DWORD
Clamp PROTO :DWORD, :DWORD, :DWORD
StrLen PROTO :DWORD
IntToStr PROTO :DWORD, :DWORD
Distance PROTO :DWORD, :DWORD, :DWORD, :DWORD
timeGetTime PROTO

; ============================================================================
