-- Modpack Updater mod

ModpackUpdater = ModpackUpdater or {}
ModpackUpdater._mod_path = ModPath
ModpackUpdater.repo_path = ModpackUpdater._mod_path .. "../../"
ModpackUpdater.cache_file = ModpackUpdater._mod_path .. "version_cache.json"
ModpackUpdater.script_path = ModpackUpdater.repo_path .. "modpack_update.ps1"

-- Helper: trim whitespace
local function trim(s)
	return s and s:match("^%s*(.-)%s*$") or ""
end

-- Helper: show dialog
local function show_dialog(title, message)
	BeardLib.Managers.Dialog:Simple():Show({
		title = title,
		message = message,
		no = false
	})
end

-- Helper: load version info from cache file
local function load_cache()
	if not FileIO:Exists(ModpackUpdater.cache_file) then
		return nil
	end
	return FileIO:ReadScriptData(ModpackUpdater.cache_file, "json")
end

local function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end
	return false
end

local function run_update_script()
	local script = Path:Normalize(ModpackUpdater.script_path)
	local cmd = string.format('powershell -NoProfile -ExecutionPolicy Bypass -File "%s" 2>&1', script)
	local handle = io.popen(cmd)
	if not handle then
		return nil, "Failed to execute update script"
	end
	local result = handle:read("*a")
	local success, exit_type, code = handle:close()
	if not success then
		return result, string.format("Update script failed (exit %s)", tostring(code or "?"))
	end
	return result, nil
end

-- Check version - shows cached version info (instant, no git)
function MenuCallbackHandler:ModpackUpdater_CheckVersion()
	local cache = load_cache()

	if not cache then
		show_dialog("No Update Info", "No cached update info found.\n\nClick 'Update Modpack' to download the latest modpack.")
		return
	end

	local msg = string.format(
		"Version: %s\nDetails: %s\nDate: %s\n\nLast updated: %s",
		cache.version or "?",
		cache.commit or "?",
		cache.date or "?",
		cache.cached_at or "?"
	)

	show_dialog("Modpack Update Info", msg)
end

-- Update modpack - runs the update script
function MenuCallbackHandler:ModpackUpdater_Update()
	local script = Path:Normalize(ModpackUpdater.script_path)
	if not file_exists(script) then
		show_dialog("Update Failed", "Update script not found:\n\n" .. script)
		return
	end

	local update_result, update_err = run_update_script()
	if update_err then
		show_dialog("Update Failed", "Update script failed:\n\n" .. trim(update_result or update_err))
		return
	end

	local output = trim(update_result or "")
	local msg = output ~= "" and output or "Update completed."
	msg = msg .. "\n\nRestart game to apply changes."

	show_dialog("Update Complete", msg)
end

-- Localization
Hooks:Add("LocalizationManagerPostInit", "ModpackUpdater_Loc", function(loc)
	loc:add_localized_strings({
		modpack_updater_title = "Modpack Updater",
		modpack_updater_desc = "Update or check modpack info"
	})
end)

-- Setup menu
Hooks:Add("MenuManagerSetupCustomMenus", "ModpackUpdater_SetupMenus", function(menu_manager, nodes)
	MenuHelper:NewMenu("modpack_updater_menu")
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "ModpackUpdater_PopulateMenus", function(menu_manager, nodes)
	MenuHelper:AddButton({
		id = "modpack_check_version",
		title = "Check Version",
		desc = "Show last update info",
		callback = "ModpackUpdater_CheckVersion",
		menu_id = "modpack_updater_menu",
		priority = 2,
		localized = false
	})

	MenuHelper:AddButton({
		id = "modpack_update",
		title = "Update Modpack",
		desc = "Download and replace modpack files",
		callback = "ModpackUpdater_Update",
		menu_id = "modpack_updater_menu",
		priority = 1,
		localized = false
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ModpackUpdater_BuildMenus", function(menu_manager, nodes)
	nodes["modpack_updater_menu"] = MenuHelper:BuildMenu("modpack_updater_menu")
	MenuHelper:AddMenuItem(nodes.options, "modpack_updater_menu", "modpack_updater_title", "modpack_updater_desc")
end)
