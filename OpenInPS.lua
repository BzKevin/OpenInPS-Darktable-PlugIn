--[[OpenInPS plugin for darktable

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

--[[About this Plugin
This plugin adds the module "OpenInPS" to darktable's lighttable view and "ExportToPS" to the export options

----REQUIRED SOFTWARE----
Adobe Photoshop

----USAGE----
Install: (see here for more detail: https://github.com/darktable-org/lua-scripts )
 1) Copy this file in to your "lua/contrib" folder where all other scripts reside. 
 2) Require this file in your luarc file, as with any other dt plug-in
On the initial startup go to darktable settings > lua options and set your executable paths and other preferences, then restart darktable

Open In PS:
Select the photo(s) you wish to open in Photoshop and press "Open" from the Open in Photoshop box
	RAW files will open in ACR inside Photoshop (If multiple RAW files are selected, only one will open)
	JPG, Tif, etc will open as a new file inside PS (If multiple non-RAW files are selected, they will all open as new images in PS)
	Since this is opening the file, not exporting, it will NOT have any of your darktable edits
	
Export to PS:
Select the photo(s) you wish to export to Photoshop and select the desired destination folder, set the rest of 
	the export settings as with any other export from darktable. Since this is "exporting" the selected file will
	be converted from RAW to your chosen format and darktable edits WILL carry over. Note the files created by 
	this will NOT be automatically deleted or cleaned up, you will need to handle this manually if you decide to do so.

----KNOWN ISSUES----
]]

local dt = require "darktable"
local df = require "lib/dtutils.file"
local dsys = require "lib/dtutils.system"

--Detect OS and modify accordingly--	
op_sys = dt.configuration.running_os
if op_sys == "windows" then
	os_path_seperator = "\\"
else
	os_path_seperator = "/"
end

-- READ PREFERENCES --
not_installed = 0
dt.print_log("OpenInPS - Executable Path Preference: "..df.get_executable_path_preference("photoshop"))
bin_path = df.check_if_bin_exists("photoshop")
if not bin_path then
	dt.print_error("Photoshop not found")
	dt.print("ERROR - Photoshop not found")
	not_installed = 1
end
last_used_location = dt.preferences.read("module_OpenInPS", "export_path", "string")



-- FUNCTION --
local function build_execute_command(cmd, args, file_list)
	local result = false
	result = cmd.." "..args.." "..file_list
	return result
end
local function show_status(storage, image, format, filename, --Store: Called on each exported image
  number, total, high_quality, extra_data)
     dt.print('Export to Photoshop: '..tostring(number).."/"..tostring(total))   
end
local function OpenInPS() --OPEN in Photoshop 
	--Ensure Proper Software Installed--
	if not_installed == 1 then
		dt.print_log("Required software not found")
		dt.print("Required software not found")
		return
	end	
	dt.print_log("Opening in Photoshop")
	dt.print("Opening In Photoshop")
	
	--Inits--
	local images = dt.gui.selection()
	local curr_image = ""
	local images_to_open = ""
	
	for _,image in pairs(images) do 
		curr_image = image.path..os_path_seperator..image.filename
		images_to_open = images_to_open.." "..curr_image
	end
	run_cmd = build_execute_command(bin_path, "" , images_to_open)
	dt.print_log("OpenInPS run_cmd = "..run_cmd)
	dt.print("Opening in Photoshop")
	--resp = dt.control.execute(run_cmd)
	resp = dsys.external_command(run_cmd)
end
local function ExportToPS(storage, image_table, extra_data) --EXPORT to Photoshop
	--Ensure Proper Software Installed--
	if not_installed == 1 then
		dt.print_log("Required software not found")
		dt.print("Required software not found")
		return
	end

	--Inits--
	local images_to_open = ""
	if (PS_file_chooser_button_path.value == nil) and not(PS_chkbtn_source_location.value) then   --Check that output path selected
		dt.print('ERROR: no target directory selected')
		return
	end
	dt.preferences.write("module_OpenInPS", "export_path", "string", PS_file_chooser_button_path.value)
	
	dt.print_log("Opening exported images in Photoshop")
	dt.print("Opening exported images in Photoshop")
	
	for source_image,temp_path in pairs(image_table) do
		local new_path=PS_file_chooser_button_path.value
		if (PS_chkbtn_source_location.value) then
			new_path = source_image.path 
		end
		new_path = new_path..os_path_seperator..df.get_filename(temp_path)
		new_path = df.create_unique_filename(new_path)
		result = df.file_move(temp_path, new_path)
		images_to_open = images_to_open..new_path.." "
	end
	run_cmd = build_execute_command(bin_path, "" , images_to_open)
	dt.print_log("ExportToPS run_cmd = "..run_cmd)
	resp = dsys.external_command(run_cmd)
end

-- GUI --
OpenInPS_btn_run = dt.new_widget("button"){
	label = "Open",
	tooltip = "Opens selected image in Photoshop",
	clicked_callback = function() OpenInPS() end
	}
dt.register_lib( --OpenInPS
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

PS_file_chooser_button_path = dt.new_widget("file_chooser_button"){
    title = 'Select export path',  -- The title of the window when choosing a file
    value = last_used_location,
	is_directory = true,             -- True if the file chooser button only allows directories to be selected
    tooltip ='select the target directory for the image(s)',
}
PS_chkbtn_source_location = dt.new_widget("check_button"){
    label = 'save to source image location', 
    value = false,
    tooltip ='If checked ignores the location below and saves output image(s) to the same location as the source images.',  
	reset_callback = function(self) 
       self.value = true
    end 
}
dt.register_storage(
	"ExportToPS_Storage", --Module name
	"Export to Photoshop", --Name
	show_status, --store: called once per exported image
	ExportToPS,  --finalize: called once when all images are exported and store calls complete
	nil, --supported: 
	nil, --initialize: 
	dt.new_widget("box"){
		orientation = "vertical",
		PS_file_chooser_button_path,
		PS_chkbtn_source_location
		}
	)

-- PREFERENCES --
if not bin_path then 
	bin_path = ""
end
PS_path_widget = dt.new_widget("file_chooser_button"){
	title = "Select Photoshop executable",
	value = bin_path,
	is_directory = false,
}
dt.preferences.register("executable_paths", "photoshop",	-- name
	"file",	-- type
	'OpenInPS: Photoshop exe location',	-- label
	'Location of Photoshop executable. Requires restart to take effect.',	-- tooltip
	"Please Select",	-- default
	PS_path_widget
)
