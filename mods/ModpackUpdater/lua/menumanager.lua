-- Modpack Updater

ModpackUpdater = ModpackUpdater or {}
ModpackUpdater._mod_path = ModPath -- Capture at load time
ModpackUpdater.repo_path = ModpackUpdater._mod_path .. "../../"
ModpackUpdater.menu_id = "modpack_updater_menu"

-- TODO: Cleanup old batch files on load
-- os.remove(ModpackUpdater._mod_path .. "check_version.bat")
-- os.remove(ModpackUpdater._mod_path .. "update_modpack.bat")

-- Localization
Hooks:Add("LocalizationManagerPostInit", "ModpackUpdater_Loc", function(loc)
	loc:add_localized_strings({
		modpack_updater_title = "Modpack Updater",
		modpack_updater_desc = "Update or check modpack version"
	})
end)

-- Check version - opens terminal showing version info
function MenuCallbackHandler:ModpackUpdater_CheckVersion()
	local repo = ModpackUpdater.repo_path:gsub("/", "\\")
	local bat = ModpackUpdater._mod_path .. "check_version.bat"
	local f = io.open(bat, "w")
	f:write("@echo off\n")
	f:write('cd /d "' .. repo .. '"\n')
	f:write("echo.\n")
	f:write("echo === MODPACK VERSION ===\n")
	f:write("echo.\n")
	f:write("echo Version:\n")
	f:write("git rev-parse --short=4 HEAD\n")
	f:write("echo.\n")
	f:write("echo Commit:\n")
	f:write("git log -1 --format=%s\n")
	f:write("echo.\n")
	f:write("echo === LOCAL CHANGES ===\n")
	f:write("git status --short\n")
	f:write("echo.\n")
	f:write("pause\n")
	f:close()
	os.execute('start cmd /c "' .. bat .. '"')
end

-- Update modpack - opens terminal and runs git pull
function MenuCallbackHandler:ModpackUpdater_Update()
	local repo = ModpackUpdater.repo_path:gsub("/", "\\")
	local bat = ModpackUpdater._mod_path .. "update_modpack.bat"
	local f = io.open(bat, "w")
	f:write("@echo off\n")
	f:write('cd /d "' .. repo .. '"\n')
	f:write("echo.\n")
	f:write("echo === UPDATING MODPACK ===\n")
	f:write("echo.\n")
	f:write("git pull\n")
	f:write("echo.\n")
	f:write("echo === NEW VERSION ===\n")
	f:write("echo.\n")
	f:write("echo Version:\n")
	f:write("git rev-parse --short=4 HEAD\n")
	f:write("echo.\n")
	f:write("echo Commit:\n")
	f:write("git log -1 --format=%s\n")
	f:write("echo.\n")
	f:write("echo Update complete. Restart game to apply changes.\n")
	f:write("echo.\n")
	f:write("pause\n")
	f:close()
	os.execute('start cmd /c "' .. bat .. '"')
end

-- Setup menu
Hooks:Add("MenuManagerSetupCustomMenus", "ModpackUpdater_SetupMenus", function(menu_manager, nodes)
	MenuHelper:NewMenu(ModpackUpdater.menu_id)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "ModpackUpdater_PopulateMenus", function(menu_manager, nodes)
	MenuHelper:AddButton({
		id = "modpack_check_version",
		title = "Check Version",
		desc = "Show current modpack version and local changes",
		callback = "ModpackUpdater_CheckVersion",
		menu_id = ModpackUpdater.menu_id,
		priority = 2,
		localized = false
	})

	MenuHelper:AddButton({
		id = "modpack_update",
		title = "Update Modpack",
		desc = "Pull latest changes from git repository",
		callback = "ModpackUpdater_Update",
		menu_id = ModpackUpdater.menu_id,
		priority = 1,
		localized = false
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ModpackUpdater_BuildMenus", function(menu_manager, nodes)
	nodes[ModpackUpdater.menu_id] = MenuHelper:BuildMenu(ModpackUpdater.menu_id)
	MenuHelper:AddMenuItem(nodes.options, ModpackUpdater.menu_id, "modpack_updater_title", "modpack_updater_desc")
end)
