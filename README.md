# OpenInPS-Darktable-PlugIn
Lua Plugin for Darktable to add the ability to open selected files in Photoshop

Requires darktable lua scripts supporting file to be installed: https://github.com/darktable-org/lua-scripts
Install this script by copying to your lua/contrib folder and requiring it in your luarc file (as with any other plug-in for darktable). Once installed open darktable>settings>lua Options. Set the path to photoshop executable. Restart Darktable. 

Known Issues:
When selecting multiple RAW files, only the first one opens in PS (suspected due to ACR behavior). This is unlikely to change in the future.

Tested on:
Windows 10, Photoshop CC 2015
