#define AppName "ComfyUI AIO"
[Setup]
AppName={#AppName}
AppVersion={#GetEnv("APP_VERSION")}
DefaultDirName={autopf}\ComfyUIAIO
DefaultGroupName={#AppName}
OutputBaseFilename=ComfyUIAIO-Setup
OutputDir=dist
Compression=lzma2
PrivilegesRequired=lowest
DisableProgramGroupPage=yes

[Files]
Source: "scripts\install.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "manifest.json";       DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "build\7zr.exe";       DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{tmp}\install.ps1"" -InstallDir ""{app}"""; \
  StatusMsg: "Downloading ComfyUI, custom nodes and models (this takes a while)..."; Flags: waituntilterminated

[Icons]
Name: "{group}\ComfyUI"; Filename: "{app}\ComfyUI_windows_portable\run_nvidia_gpu.bat"; WorkingDir: "{app}\ComfyUI_windows_portable"
Name: "{autodesktop}\ComfyUI"; Filename: "{app}\ComfyUI_windows_portable\run_nvidia_gpu.bat"; WorkingDir: "{app}\ComfyUI_windows_portable"
