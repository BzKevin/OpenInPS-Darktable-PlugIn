# OpenInPS-Darktable-PlugIn
Lua Plugin for Darktable to add the ability to open selected files in Photoshop

Install by requiring in your luarc file (as with any other plug-in for darktable). Once installed open darktable>settings>lua Options. Set the path to photoshop executable. Restart Darktable. 

Select a single or multiple images. They will all be opened in Photoshop as a new image (not as layers). Note that this is opening the original file so that means that:
1) You CAN use this directly on your RAW images; they will open in ACR inside PS
2) Your darktable edits will NOT carry-over as this is not an export-then-open function

Future Features:
Add "Export to Photoshop" functionality

Tested on:
Windows 10, Photoshop CC 2015
