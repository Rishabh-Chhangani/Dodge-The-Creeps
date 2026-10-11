# Session 1: Godot Language Server Troubleshooting

### User

Couldn't connect to the GDScript language server at 127.0.0.1:6005. Is the Godot editor or language server running? what is this erro and how to solve it

### Assistant

That message means VS Code’s Godot/GDScript extension can’t reach Godot’s language server on your computer at `127.0.0.1:6005`. The language server provides editor features such as autocomplete, diagnostics, and navigation; it’s usually started by the Godot editor.

Try these steps:

1. Open the project in Godot and leave the editor running. In VS Code, open the same project folder.
2. In Godot, check **Editor → Editor Settings → Network → Language Server**. Make sure the language server is enabled and its port is `6005` (or make sure VS Code is configured to use the port shown there).
3. Restart Godot, then reload VS Code.
4. If it still fails, check whether another process is using port 6005. In PowerShell, run:

   ```powershell
   Get-NetTCPConnection -LocalPort 6005 -State Listen
   ```

   If nothing is listening, Godot hasn’t started the server. If another app is using it, change the language-server port in Godot and configure the VS Code extension to match.
5. If Godot isn’t detected, check the Godot Tools extension’s settings and set the path to your Godot executable.

You can still run the game without the language server, but GDScript language features in VS Code may not work properly.

### User

Check and tell me what to do. (Shared a screenshot of Godot's Language Server settings.)

### Assistant

Your screenshot shows the Godot Language Server is configured for `127.0.0.1:6005`, and the Output panel says **“GDScript language server started”** (it also appears to show an LSP connection). So the Godot-side settings look right; the error may be stale or VS Code may have tried connecting before Godot was ready.

Try this:

1. Keep this Godot project open, and make sure VS Code has opened the same project folder—the folder containing `project.godot`.
2. In VS Code, press **Ctrl+Shift+P**, run **Developer: Reload Window**, and wait a few seconds.
3. If the error returns, open PowerShell while Godot is still open and run:

   ```powershell
   Get-NetTCPConnection -LocalPort 6005 -State Listen
   ```

   - If it shows a listener, Godot is listening; check the Godot Tools/GDScript extension’s output in VS Code for its connection error.
   - If it returns nothing, restart Godot and check whether its Output panel again says **“GDScript language server started.”**

Don’t change the host or port yet—the values shown in your screenshot match the usual local setup.

### User

I ran `Get-NetTCPConnection -LocalPort 6005 -State Listen`. It returned:

```text
LocalAddress  LocalPort  RemoteAddress  RemotePort  State   AppliedSetting  OwningProcess
127.0.0.1     6005       0.0.0.0        0           Listen                  13688
```

### Assistant

This confirms that something is listening on `127.0.0.1:6005`. The next step is to check whether it’s Godot. In PowerShell, run:

```powershell
Get-Process -Id 13688 | Select-Object Id, ProcessName, Path
```

- If `ProcessName` is Godot: the server is running. In VS Code, run **Developer: Reload Window** from the Command Palette (`Ctrl+Shift+P`). If the error returns, open **View → Output**, select **Godot Tools** (or the GDScript-related entry) in the Output dropdown, and check the connection message. Make sure VS Code has the same project open and its configured port is `6005`.
- If it’s not Godot: another application is using that port. Don’t change ports yet—first identify the process, then either free the port or configure Godot and the VS Code extension to use the same unused port.

So, unlike the earlier error suggested, this result means the port is listening; now we need to confirm which program owns it.

### User

Godot is listening.

### Assistant

Great—if the listener belongs to Godot, leave the host and port as they are. The server is running; VS Code may have tried to connect before it started, or its extension may have another issue.

1. Keep Godot open with this project.
2. In VS Code, open the folder containing `project.godot`.
3. Press **Ctrl+Shift+P** and run **Developer: Reload Window**.
4. Open a `.gd` script and check whether autocomplete or diagnostics work.

If the connection error comes back, open **View → Output**, choose the Godot/GDScript-related channel from the dropdown, and share the latest error lines. That will help identify whether the extension is connecting to the wrong port or failing for another reason.

### User

I shared `project.godot` and said “this one.”

### Assistant

I checked `project.godot`. It looks like a normal Godot 4.5 project configuration; it doesn’t contain a language-server setting, so there’s nothing in this file you need to change for that connection error.

Since Godot is listening on port 6005, try this in VS Code:

1. Choose **File → Open Folder…** and open the project folder—the folder containing `project.godot`.
2. Run **Developer: Reload Window** from the Command Palette (`Ctrl+Shift+P`).
3. Open a `.gd` script and check whether the error returns.

If it does, please share the exact error from VS Code’s **View → Output** panel, selecting the Godot/GDScript extension’s output channel. The project file itself doesn’t explain a failed connection.

### User

I shared a screenshot of the VS Code Godot Tools setting for **Editor Path: Godot4**.

### Assistant

In this screenshot, the **Godot Tools → Editor Path: Godot4** setting is set to `godot`. That’s the command VS Code uses to find Godot; it works only if Godot is available on your Windows `PATH`.

Since you’ve confirmed Godot is listening, don’t change the port. The VS Code status bar also appears to say **Connected**, so the language-server connection may already be working. Close Settings, open a `.gd` script, and see whether autocomplete works.

If the connection error returns, set **Editor Path: Godot4** to the full path of the running Godot executable:

```powershell
(Get-Process -Id 13688).Path
```

Copy the returned path into that setting, then reload VS Code with **Ctrl+Shift+P → Developer: Reload Window**, while leaving Godot open.

### User

By path do you mean edit systems variable setting?

### Assistant

No—I mean the **Editor Path: Godot4** field in the VS Code screenshot, not the Windows system variables.

It currently says `godot`, which is fine if VS Code can find Godot that way. Since your VS Code status bar shows **Connected**, leave it as is for now.

If you need to enter the full path, run this in PowerShell:

```powershell
(Get-Process -Id 13688).Path
```

Copy the result—ending in Godot’s `.exe` file—into the **Editor Path: Godot4** setting. You don’t need to edit Windows’ **Path** environment variable for this.

### User

From now on, whenever I ask you anything related, store the conversation in the `docs` folder in a Markdown file named `CHAT STORE`. Do not delete anything from it.

### Assistant

I created `docs/CHAT STORE.md` and recorded this Godot language-server troubleshooting conversation. For future project-related conversations in this workspace, I’ll append the conversation to this file and preserve its existing contents.
