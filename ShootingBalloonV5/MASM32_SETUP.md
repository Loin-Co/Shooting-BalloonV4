# MASM32 Setup Guide for Visual Studio

## Error Fix: "cannot open file: \masm32\include\windows.inc"

This error occurs because Visual Studio doesn't know where to find the MASM32 include files. Follow these steps to fix it:

## Option 1: Configure Visual Studio Include Paths (Recommended)

1. **Right-click on your project** in Solution Explorer
2. Select **Build Dependencies > Build Customizations...**
3. Check the box for **masm (.targets, .props)**
4. Click **OK**

5. **Right-click on your project** again and select **Properties**
6. Navigate to: **Configuration Properties > Microsoft Macro Assembler > General**
7. In **Include Paths**, add your MASM32 include directory:
   ```
   C:\masm32\include
   ```
   (Adjust the path if your MASM32 is installed elsewhere)

8. Navigate to: **Configuration Properties > Linker > General**
9. In **Additional Library Directories**, add:
   ```
   C:\masm32\lib
   ```

10. Click **Apply** and **OK**

## Option 2: Set Environment Variable

1. Open **System Properties > Advanced > Environment Variables**
2. Add a new **System Variable**:
   - Variable name: `INCLUDE`
   - Variable value: `C:\masm32\include`
3. Add another variable:
   - Variable name: `LIB`
   - Variable value: `C:\masm32\lib`
4. **Restart Visual Studio** for changes to take effect

## Option 3: Use Full Paths (Not Recommended)

If MASM32 is not installed at `C:\masm32`, you can modify each .asm file to use the full path:

```assembly
include C:\YourPath\masm32\include\windows.inc
```

## Verify MASM32 Installation

1. Check if MASM32 is installed at: `C:\masm32`
2. Verify these folders exist:
   - `C:\masm32\include` (should contain windows.inc, kernel32.inc, etc.)
   - `C:\masm32\lib` (should contain kernel32.lib, user32.lib, etc.)
   - `C:\masm32\bin` (should contain ml.exe)

3. If MASM32 is not installed, download it from:
   - http://www.masm32.com/

## Project Configuration Settings

For this project, you should configure:

### MASM Settings:
- **Include Paths**: `C:\masm32\include`
- **Command Line**: `/c /coff /Cp /Zi`

### Linker Settings:
- **Additional Library Directories**: `C:\masm32\lib`
- **Entry Point**: `start`
- **Subsystem**: Console
- **Additional Dependencies**: `kernel32.lib user32.lib msvcrt.lib`

## Testing the Fix

After configuration:
1. **Clean** the solution (Build > Clean Solution)
2. **Rebuild** the solution (Build > Rebuild Solution)
3. Check the Output window for any remaining errors

## Common Issues

### Issue: "ml.exe not found"
**Solution**: Add `C:\masm32\bin` to your system PATH

### Issue: "unresolved external symbol"
**Solution**: Make sure all .asm files are added to the project and set to compile as MASM files

### Issue: Still getting include errors
**Solution**: 
1. Check that all .asm files use the corrected include statements (without `\masm32\` prefix)
2. Verify MASM32 is properly installed
3. Restart Visual Studio after setting environment variables

## Current File Status

All assembly files have been updated to use relative include paths:
- ? main.asm
- ? Src/Renderer/render_core.asm
- ? Src/Renderer/draw_shapes.asm
- ? Src/Initializer/sys_init.asm
- ? Src/Input/input_mgr.asm
- ? Src/GameLogic/player.asm
- ? Src/GameLogic/collision.asm

Now you just need to configure Visual Studio to find the MASM32 directories.
