# ??? Filters-Only Project Structure

## ? Quick Start

**To convert your project to use filters only (30 seconds):**

1. **Close Visual Studio** completely
2. **Run:** `APPLY_FILTERS_ONLY.bat`
3. **Reopen Visual Studio**
4. **Done!** ?

---

## ?? What This Does

This conversion reorganizes your project to use **Virtual Filters** instead of physical folders. Your files will be in a flat structure on disk but appear organized in Visual Studio.

### Before (Current):
```
Src/
??? Audio/audio_mgr.asm
??? Core/global_data.asm
??? GameLogic/player.asm
??? Views/menu.asm
??? ...
```

### After (Filters-Only):
```
Src/
??? audio_mgr.asm
??? global_data.asm
??? player.asm
??? menu.asm
??? Include/
    ??? *.inc files
```

**But in Visual Studio, you'll see organized filters:**
- ?? Core
- ?? GameLogic
- ?? Renderer
- ?? Views ? (NEW!)
- ?? Audio
- ... and more

---

## ?? Files Created

| File | Purpose |
|------|---------|
| `APPLY_FILTERS_ONLY.bat` | **Main script** - Run this to apply all changes |
| `FILTERS_ONLY_GUIDE.txt` | Complete documentation with manual steps |
| `FILTERS_QUICK_REFERENCE.txt` | Quick lookup for common tasks |
| `BEFORE_AFTER_DIAGRAM.txt` | Visual comparison of structure |
| `FILTERS_SETUP_COMPLETE.md` | Summary and verification checklist |
| `REMOVE_FOLDERS.bat` | Standalone folder cleanup script |
| `ShootingBalloonV5.vcxproj.filters.UPDATED` | New filters configuration |

---

## ? Benefits

- ? **Cleaner structure** - No deep folder nesting
- ? **Easier navigation** - Find files faster in file explorer
- ? **Faster builds** - Shorter file paths
- ? **Still organized** - Filters provide visual organization in VS
- ? **Flexible** - Reorganize filters without moving files
- ? **Professional** - Industry-standard approach

---

## ?? What's in the Views Filter

The new **Views** filter contains your UI screens:

- `loading_screen.asm` - Startup animation
- `menu.asm` - Main menu
- `level_select.asm` - Level selection
- `instructions.asm` - Game instructions

---

## ?? Manual Steps (if needed)

If automatic script fails:

1. Close Visual Studio
2. Move all `.asm` files from subfolders to `Src\`
3. Delete empty subfolders (keep `Src\Include`)
4. Replace `.vcxproj.filters` with `.vcxproj.filters.UPDATED`
5. Update `.vcxproj` file paths to remove subfolder references
6. Reopen Visual Studio

See `FILTERS_ONLY_GUIDE.txt` for detailed instructions.

---

## ?? Important Notes

- **Src\Include** folder is kept (needed by compiler for .inc files)
- All other folders are removed
- Filters are **virtual** - they only exist in Visual Studio
- Backup is created automatically
- Close Visual Studio before running the script

---

## ?? Documentation

| Document | Description |
|----------|-------------|
| `START_FILTERS_CONVERSION.txt` | Overview and quick start |
| `FILTERS_QUICK_REFERENCE.txt` | Quick reference card |
| `BEFORE_AFTER_DIAGRAM.txt` | Visual structure comparison |
| `FILTERS_ONLY_GUIDE.txt` | Complete guide with troubleshooting |
| `FILTERS_SETUP_COMPLETE.md` | Full documentation |

---

## ?? Troubleshooting

**Build errors after conversion?**
- Rebuild solution (Ctrl+Shift+B)
- Check that files are in `Src\` folder

**Files in wrong filter?**
- Drag and drop files between filters in Solution Explorer

**Physical folders still exist?**
- Close VS, manually delete folders, reopen VS

**Include files not found?**
- Verify `Src\Include` folder exists
- Check MASM Include Path = `$(ProjectDir)Src\Include`

---

## ?? Ready to Start!

When you're ready to convert:

```batch
APPLY_FILTERS_ONLY.bat
```

Then reopen Visual Studio and enjoy your cleaner project structure! ??

---

**Questions?** Read `FILTERS_ONLY_GUIDE.txt` for comprehensive help.
