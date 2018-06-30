--[[	OpenInPS plugin for darktable

  copyright (c) 2018  Kevin Ertel
  
  darktable is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  darktable is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with darktable.  If not, see <http://www.gnu.org/licenses/>.
]]

--[[	Version 1.0.0     6/30/2018

This plugin adds the module "OpenInPS" to darktable's lighttable view

****Dependencies****
OS: Windows (tested), Linux (not verified), MacOS (not verified)
Photoshop

****How to use****
Require this file from your luarc file, as with any other dt plug-in.
On initial run, setup the Photoshop executable path via the settings > lua options dialog. Restart may be required.
Select the photo you wish to open in Photoshop and press Open
	RAW files will open in ACR inside Photoshop
	JPG, Tif, etc will open as a new file inside PS
	Since this is opening the file, not exporting and then opening, it will NOT have any of your Darktable edits
]]

local dt = require "darktable"
local df = require "lib/dtutils.file"
require "official/yield"

--Detect OS and modify accordingly--	
op_sys = dt.configuration.running_os
if op_sys == "windows" then
	os_path_seperator = "\\"
else
	os_path_seperator = "/"
end

-- READ PREFERENCES --

local function build_execute_command(cmd, args, file_list)
	local result = false

	if dt.configuration.running_os == "macos" then
		cmd = string.gsub(cmd, "open", "", 1)
		cmd = string.gsub(cmd, "-W", "", 1)
		cmd = string.gsub(cmd, "-a", "", 1)
	end
	result = cmd.." "..args.." "..file_list
	return result
end

-- FUNCTION --
local function OpenInPS()
	dt.print_log("Opening in Photoshop")
	dt.print("Opening In Photoshop")
	df.set_executable_path_preference("openinps", dt.preferences.read("module_OpenInPS", "bin_path", "string"))
	dt.print_log("Executable Path Preference: "..df.get_executable_path_preference("openinps"))
	local PS_Path = df.check_if_bin_exists("openinps")
	if not PS_Path then
		dt.print_error("Photoshop not found")
		dt.print("ERROR - Photoshop not found")
		return
	end
	
	--Inits--
	local images = dt.gui.selection()
	local curr_image = ""
	local images_to_open = ""
	
	for _,image in pairs(images) do 
		curr_image = image.path..os_path_seperator..image.filename
		images_to_open = images_to_open.." "..curr_image
	end
	run_cmd = build_execute_command(PS_Path, "" , images_to_open)
	dt.print_log("OpenInPS run_cmd = "..run_cmd)
	dt.print("Opening in Photoshop")
	resp = dt.control.execute(run_cmd)
end

-- GUI --
local executables = {"openinps"}
if dt.configuration.running_os ~= "linux" then
  path_widget = df.executable_path_widget(executables)
end
OpenInPS_btn_run = dt.new_widget("button"){
	label = "Open",
	tooltip = "Opens selected image in Photoshop",
	clicked_callback = function() OpenInPS() end
	}
dt.register_lib(
	"OpenInPS_Lib",	-- Module name
	"Open In Photoshop",	-- name
	true,	-- expandable
	false,	-- resetable
	{[dt.gui.views.lighttable] = {"DT_UI_CONTAINER_PANEL_RIGHT_CENTER", 99}},	-- containers
	dt.new_widget("box"){
		orientation = "vertical",
		OpenInPS_btn_run
	}
)

-- PREFERENCES --
executable = "hdrmerge"
bin_path = df.get_executable_path_preference(executable)
if not bin_path then 
	bin_path = ""
end
path_widget = dt.new_widget("file_chooser_button"){
	title = "Select Photoshop executable",
	value = bin_path,
	is_directory = false,
}
dt.preferences.register("module_OpenInPS", "bin_path",	-- name
	"file",	-- type
	'OpenInPS: Photoshop exe location',	-- label
	'Location of Photoshop executable. Requires restart to take effect.',	-- tooltip
	"Please Select",	-- default
	path_widget
)