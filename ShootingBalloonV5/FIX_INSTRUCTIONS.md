# Quick Fix for MASM32 Include Path Error

## The Problem
You're getting error **A1000: cannot open file: windows.inc** because Visual Studio can't find the MASM32 include files.

## ? SOLUTION (Choose ONE method below)

---

### Method 1: Import the MASM32.props File (EASIEST)

1. **Right-click** on your project in Solution Explorer
2. Select **Add > Existing Property Sheet...**
3. Browse to and select `MASM32.props` (located in your project root)
4. Click **Open**
5. **Clean and Rebuild** your solution

**This automatically configures all the necessary paths!**

---

### Method 2: Manual Configuration in Visual Studio

#### Step 1: Enable MASM Build Customizations
1. Right-click your project ? **Build Dependencies** ? **Build Customizations...**
2. Check ? **masm(.targets, .props)**
3. Click **OK**

#### Step 2: Add Include Paths
1. Right-click your project ? **Properties**
2. Go to: **Configuration Properties** ? **Microsoft Macro Assembler** ? **General**
3. In **Include Paths**, add:
   ```
   C:\masm32\include
   ```
4. Click **Apply**

#### Step 3: Add Library Paths
1. Still in Properties, go to: **Configuration Properties** ? **Linker** ? **General**
2. In **Additional Library Directories**, add:
   ```
   C:\masm32\lib
   ```

#### Step 4: Configure Linker
1. Go to: **Configuration Properties** ? **Linker** ? **Input**
2. In **Additional Dependencies**, add:
   ```
   kernel32.lib
   user32.lib
   msvcrt.lib
   ```

3. Go to: **Configuration Properties** ? **Linker** ? **System**
4. Set **SubSystem** to: **Console (/SUBSYSTEM:CONSOLE)**

5. Go to: **Configuration Properties** ? **Linker** ? **Advanced**
6. Set **Entry Point** to: **start**

7. Click **OK** to close Properties

#### Step 5: Clean and Rebuild
1. **Build** ? **Clean Solution**
2. **Build** ? **Rebuild Solution**

---

### Method 3: Environment Variables (Alternative)

**If MASM32 is installed** but Visual Studio can't find it:

1. Press **Win + X** ? **System** ? **Advanced system settings**
2. Click **Environment Variables**
3. Under **System Variables**, find **Path** and click **Edit**
4. Add these entries:
   ```
   C:\masm32\bin
   C:\masm32\include
   C:\masm32\lib
   ```
5. Click **OK** on all windows
6. **Restart Visual Studio**
7. Clean and rebuild your project

---

## ?? If MASM32 is Not Installed

If you don't have MASM32 installed at all:

1. **Download MASM32**: http://www.masm32.com/download.htm
2. Run the installer - it will install to `C:\masm32` by default
3. Verify installation by checking these folders exist:
   - `C:\masm32\include` (contains windows.inc, kernel32.inc, etc.)
   - `C:\masm32\lib` (contains kernel32.lib, user32.lib, etc.)
   - `C:\masm32\bin` (contains ml.exe)
4. Follow **Method 1** or **Method 2** above

---

## ?? Quick Test

After configuration, try building. You should see:

? **Success**: Build will complete without A1000 errors

? **Still Failing**: 
- Verify MASM32 is installed at `C:\masm32`
- Check that the paths in your configuration match your MASM32 installation
- Make sure **all** .asm files are added to your project
- Restart Visual Studio

---

## Files Already Fixed

All these files have been updated with correct include statements:
- ? main.asm
- ? Src/Core/global_data.asm  
- ? Src/Renderer/render_core.asm
- ? Src/Renderer/draw_shapes.asm
- ? Src/Initializer/sys_init.asm
- ? Src/Input/input_mgr.asm
- ? Src/GameLogic/player.asm
- ? Src/GameLogic/enemies.asm
- ? Src/GameLogic/collision.asm
- ? Src/Audio/audio_mgr.asm

No code changes needed - just configure the paths!

---

## Need Help?

If you're still stuck, check:
1. Is MASM32 installed? ? Check if `C:\masm32` exists
2. Did you add Build Customizations? ? Project ? Build Dependencies ? MASM
3. Did you restart VS after environment changes? ? Close and reopen Visual Studio
4. Are all .asm files in your project? ? Check Solution Explorer

**Recommended**: Use **Method 1** (Import MASM32.props) - it's the fastest!
