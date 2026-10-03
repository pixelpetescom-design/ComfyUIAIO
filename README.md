# ComfyUI AIO

One `ComfyUIAIO-Setup.exe` that installs ComfyUI (Windows portable, NVIDIA) plus every custom node
needed for AI video green-screen matting, in a single run.

## What it installs
Defined in `manifest.json`: ComfyUI portable, ComfyUI-Manager, VideoHelperSuite, KJNodes, RMBG,
segment-anything-2 (each node's pip requirements are installed into the portable Python).
Matting models (BiRefNet, SAM2) are auto-downloaded by those nodes on first run; to pre-bundle
them add entries to `models` (`{"url": "...", "dest": "models/..."}`) and workflow JSONs to `workflows`.

## Build
Push to GitHub: the `Build installer` workflow compiles the exe (Inno Setup) and uploads it as an artifact.
The exe is a small bootstrapper; ComfyUI, nodes and models are downloaded at install time
(models are many GB, so embedding them in one exe is impractical).

## Not yet tested
Written without a Windows machine. Run the workflow, test the exe on a clean Windows box, and adjust
`manifest.json` to match the exact nodes/workflow from the video.
