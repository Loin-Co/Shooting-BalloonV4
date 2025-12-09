# ? IMMEDIATE FIX - Do This Right Now in Visual Studio

## The Current Error
```
A1000: cannot open file : common.inc
```

**Reason:** The `/I"Src\Include"` flag is NOT in the ml.exe command.

---

## ?? THE FIX (Follow These Exact Steps)

### 1. Open Project Properties
- Right-click **"ShootingBalloonV5"** in Solution Explorer
- Click **"Properties"** (at the very bottom)

### 2. Navigate to MASM Settings
In the Property Pages window:
- Left panel: expand **"Configuration Properties"**
- Expand **"Microsoft Macro Assembler"**
- Click on **"General"**

**?? IMPORTANT:** At the top of the window, set **Configuration** to **"All Configurations"**

### 3. Add Include Path
On the right side:
- Find the property called **"Include Paths"**
- Click in the value field (right column)
- Type this EXACT text:
```
$(ProjectDir)Src\Include
```

### 4. Apply and Close
- Click **"Apply"** button (bottom of window)
- Click **"OK"** button

### 5. Clean and Rebuild
- Menu: **Build** ? **Clean Solution**
- Menu: **Build** ? **Rebuild Solution**

---

## ? Success Check

After rebuild, the **Output** window should show:
```
1>Assembling main.asm...
1>Assembling global_data.asm...
[more files...]
========== Build: 1 succeeded, 0 failed ==========
```

If you see **"1 succeeded"** ? YOU'RE DONE! ?

---

## ?? If You Don't See "Microsoft Macro Assembler" in Properties

This means MASM build customizations aren't enabled. Do this:

1. Right-click project ? **Build Dependencies** ? **Build Customizations...**
2. Check the box: **? masm(.targets, .props)**
3. Click **OK**
4. Now try the steps above again

---

## ?? After Successful Build

Press **F5** or click the green **? Local Windows Debugger** button to run your game!

---

## ?? Visual Guide

### Where is "Solution Explorer"?
- Usually on the right side of Visual Studio
- If you don't see it: Menu ? **View** ? **Solution Explorer**

### Where is "Properties"?
- Right-click your project name in Solution Explorer
- It's at the very bottom of the context menu (looks like a wrench icon)

### Where is "Microsoft Macro Assembler"?
- It's in the left tree view of the Property Pages
- Under "Configuration Properties"
- If you don't see it, you need to enable MASM build customizations first

---

## ?? This Should Take 30 Seconds

1. Right-click project ? Properties (5 sec)
2. Navigate to MASM ? General (5 sec)
3. Add Include Path (10 sec)
4. Apply ? OK (5 sec)
5. Clean ? Rebuild (5 sec)

**Total: 30 seconds ? Fixed!** ??

---

Need help? Check **VS_DEBUGGER_FIX.md** for detailed screenshots descriptions.
