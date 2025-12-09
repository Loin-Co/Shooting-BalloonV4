# ?? FIX FOR VISUAL STUDIO DEBUGGER - Step by Step

## The Problem
You're getting this error when building in Visual Studio:
```
A1000: cannot open file : common.inc
MSB3721: The command "ml.exe /c /nologo /Zi /Fo"Debug\main.obj" /W3 /errorReport:prompt /Tamain.asm" exited with code 1.
```

**Root Cause:** The `/I` (include path) flag is missing from the ml.exe command.

---

## ? SOLUTION - Configure Visual Studio Project

### Step 1: Ensure MASM Build Customizations are Enabled

1. In **Solution Explorer**, **right-click** on the **"ShootingBalloonV5"** project (not the solution)
2. Select **Build Dependencies** ? **Build Customizations...**
3. In the dialog that appears, check the box next to **masm(.targets, .props)**
4. Click **OK**

---

### Step 2: Add Include Paths to MASM Configuration

1. **Right-click** on the **"ShootingBalloonV5"** project
2. Select **Properties** (at the very bottom of the context menu)
3. In the **Property Pages** window:
   - Make sure **Configuration** is set to **"All Configurations"** (top-left dropdown)
   - Make sure **Platform** is set to **"Win32"** (top-right dropdown)

4. In the left tree view, navigate to:
   ```
   Configuration Properties
     ?? Microsoft Macro Assembler
          ?? General
   ```

5. On the right side, find the property **"Include Paths"**

6. Click in the **Include Paths** field (on the right side of the row)

7. A dropdown arrow will appear - click it and select **<Edit...>**

8. In the **Include Paths** dialog, add this line:
   ```
   $(ProjectDir)Src\Include
   ```

9. Click **OK** to close the Include Paths dialog

10. Click **Apply** at the bottom of the Property Pages

---

### Step 3: Verify Linker Settings (should already be correct from MASM32.props)

While still in the **Property Pages**:

1. Navigate to:
   ```
   Configuration Properties
     ?? Linker
          ?? Input
   ```

2. Verify **Additional Dependencies** includes:
   ```
   kernel32.lib;user32.lib;msvcrt.lib
   ```
   (If not, add them separated by semicolons)

3. Navigate to:
   ```
   Configuration Properties
     ?? Linker
          ?? System
   ```

4. Verify **SubSystem** is set to: **Console (/SUBSYSTEM:CONSOLE)**

5. Navigate to:
   ```
   Configuration Properties
     ?? Linker
          ?? Advanced
   ```

6. Verify **Entry Point** is set to: **start**

7. Click **OK** to close the Property Pages

---

### Step 4: Clean and Rebuild

1. Go to **Build** menu ? **Clean Solution**
2. Go to **Build** menu ? **Rebuild Solution**

You should now see output like:
```
1>------ Build started: Project: ShootingBalloonV5, Configuration: Debug Win32 ------
1>Assembling main.asm...
1>Assembling global_data.asm...
[etc...]
1>ShootingBalloonV5.vcxproj -> D:\Computer aRCHITECTURE\...\Debug\ShootingBalloonV5.exe
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

---

### Step 5: Run with Local Windows Debugger

1. Make sure **Debug** and **x86** are selected in the toolbar dropdowns
2. Press **F5** or click the green **"Local Windows Debugger"** button
3. Your game should launch in a console window!

---

## ?? Alternative: Import Property Sheet (If Above Doesn't Work)

If the manual configuration doesn't work, try importing the property sheet:

1. In **Solution Explorer**, expand your project
2. Right-click on **"Property Sheets"** (under your project)
   - If you don't see it, go to **View** ? **Other Windows** ? **Property Manager**
3. Right-click on **Debug | Win32** ? **Add Existing Property Sheet...**
4. Browse to your project folder and select **MASM32.props**
5. Click **Open**
6. Repeat for **Release | Win32** if you want to build in Release mode
7. **Clean and Rebuild**

---

## ?? Troubleshooting

### Error: "MASM property page not found"
**Solution:** Make sure you completed **Step 1** (Build Customizations)

### Error: "Still cannot open file"
**Solution:** 
1. Check that the path `$(ProjectDir)Src\Include` resolves correctly
2. Try using the absolute path: `D:\Computer aRCHITECTURE\fINALS\Shooting Ballon V5\ShootingBalloonV5\Src\Include`

### Error: "Unresolved external symbols"
**Solution:** Make sure all `.asm` files are added to your project in Solution Explorer

### Property Sheet not applying
**Solution:**
1. Close Visual Studio
2. Open the `.vcxproj` file in a text editor
3. Find `<Import Project="MASM32.props" />` and make sure it exists
4. If not, add it before the final `</Project>` tag
5. Save and reopen in Visual Studio

---

## ? Success Criteria

After following these steps, you should be able to:

? Build the project with **Ctrl+Shift+B** (no errors)  
? Run with **F5** (launches in debugger)  
? Set breakpoints in `.asm` files  
? Step through code with **F10/F11**  
? See the splash screen ? menu ? game states  

---

## ?? Expected Behavior

When you run with the debugger:
1. Console window opens
2. "WELCOME TO DERRY 2025" appears with a border
3. After 2 seconds, transitions to menu
4. Press ESC to see exit message
5. Program closes after 1.5 seconds

---

**Now you can use the Visual Studio debugger!** ??
