# ?? QUICK FIX - 3 Simple Steps for Visual Studio Debugger

---

## ? FASTEST FIX (Do This First!)

### Step 1: Right-click Project ? Properties
In **Solution Explorer**, right-click **"ShootingBalloonV5"** ? **Properties**

### Step 2: Add Include Path
1. Navigate to: **Configuration Properties** ? **Microsoft Macro Assembler** ? **General**
2. Set **Configuration** dropdown to: **All Configurations**
3. Find **Include Paths** property
4. Click the dropdown ? **<Edit...>**
5. Add this line:
   ```
   $(ProjectDir)Src\Include
   ```
6. Click **OK**
7. Click **Apply**
8. Click **OK**

### Step 3: Clean and Rebuild
1. **Build** ? **Clean Solution**
2. **Build** ? **Rebuild Solution**

### Step 4: Run with Debugger
Press **F5** or click the green **? Local Windows Debugger** button

---

## ? What This Does

This adds the `/I"Src\Include"` flag to the ml.exe command, allowing the assembler to find:
- `windows.inc`
- `kernel32.inc`
- `msvcrt.inc`
- `user32.inc`
- `common.inc`
- `protos.inc`

---

## ?? Verify It Worked

After rebuilding, check the **Output** window. You should see:
```
1>Assembling main.asm...
1>Assembling global_data.asm...
1>Assembling sys_init.asm...
[...]
========== Build: 1 succeeded, 0 failed ==========
```

**No more `A1000: cannot open file` errors!**

---

## ?? If It Still Doesn't Work

### Alternative: Import the Property Sheet

1. In **Solution Explorer**, right-click the project
2. Select **Add** ? **Existing Property Sheet...**
3. Browse to and select **MASM32.props**
4. Click **Open**
5. **Clean and Rebuild**

This automatically configures all the settings!

---

## ?? What's Fixed

Your project now has:
- ? Correct include paths for MASM
- ? Linker configured for console app
- ? Entry point set to `start`
- ? All required libraries linked
- ? Debug symbols enabled

---

## ?? Using the Debugger

Once built successfully:

### Set Breakpoints
- Click in the left margin of any `.asm` file
- Red dot appears = breakpoint set

### Start Debugging
- Press **F5** or click **? Local Windows Debugger**

### Debug Controls
- **F10** - Step Over
- **F11** - Step Into
- **Shift+F11** - Step Out
- **F5** - Continue
- **Shift+F5** - Stop Debugging

### Watch Variables
- In **Locals** window, you can see register values (eax, ebx, etc.)
- Add variables to **Watch** window

---

## ?? You're Done!

Your Visual Studio is now configured for MASM development with full debugger support!

**Just press F5 and start coding! ??**
