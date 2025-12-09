; ============================================================================
; protos.inc - Function Prototypes
; IT: Welcome to Derry 2025 - The 8086 Arcade Edition
; ============================================================================

; Core/global_data.asm
EXTERN g_Score:DWORD
EXTERN g_Lives:DWORD
EXTERN g_FearMeter:DWORD
EXTERN g_GameState:DWORD
EXTERN g_PlayerX:DWORD
EXTERN g_SelectedLevel:DWORD
EXTERN g_MenuIndex:DWORD
EXTERN g_HighScore:DWORD
EXTERN g_Deaths:DWORD
EXTERN g_CurrentLevel:DWORD

; Initializer/sys_init.asm
InitConsole PROTO
InitAudio PROTO
InitMemory PROTO

; Renderer/render_core.asm
SetupBuffer PROTO
PresentFrame PROTO
ClearScreen PROTO

; Renderer/draw_shapes.asm
DrawPixel PROTO :DWORD, :DWORD, :DWORD, :DWORD
DrawChar PROTO :DWORD, :DWORD, :DWORD, :DWORD
DrawString PROTO :DWORD, :DWORD, :DWORD, :DWORD
DrawRect PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FlashScreen PROTO

; UI (Views) prototypes
ShowLoadingScreen PROTO
UpdateLoadingProgress PROTO :DWORD
ShowMainMenu PROTO
ProcessMenuInput PROTO
ShowLevelSelect PROTO
ProcessLevelSelectInput PROTO
ShowInstructions PROTO
ProcessInstructionsInput PROTO

; GameLogic/player.asm
UpdateArcherPosition PROTO
HandleShooting PROTO

; GameLogic/enemies.asm
UpdateBalloonMovement PROTO
SpawnManager PROTO

; GameLogic/collision.asm
CheckCollision PROTO
TriggerJumpscare PROTO

; Input/input_mgr.asm
ReadKeys PROTO

; Audio/audio_mgr.asm
PlaySoundEffect PROTO :DWORD
