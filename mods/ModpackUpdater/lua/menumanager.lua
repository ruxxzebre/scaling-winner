-- Modpack Updater
-- Adds a menu on main menu to pull the latest modpack from git

ModpackUpdater = ModpackUpdater or {}
ModpackUpdater.repo_path = ModPath .. "../../"
ModpackUpdater.menu_id = "modpack_updater_menu"

-- Get current commit hash (first 4 chars)
function ModpackUpdater:get_version()
	local cmd = string.format('git -C "%s" rev-parse HEAD 2>&1', self.repo_path)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	result = result:gsub("%s+", "") -- trim whitespace
	if result and #result >= 4 then
		return result:sub(1, 4)
	end
	return "????"
end

-- Pull latest
function ModpackUpdater:pull_modpack()
	local cmd = string.format('git -C "%s" pull 2>&1', self.repo_path)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()

	QuickMenu:new("Modpack Updater", result ~= "" and result or "Done", {{text = "OK", is_cancel_button = true}}, true)
end

-- Check status
function ModpackUpdater:check_status()
	local cmd = string.format('git -C "%s" status --short 2>&1', self.repo_path)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()

	local message = result ~= "" and result or "No changes detected"
	QuickMenu:new("Git Status", message, {{text = "OK", is_cancel_button = true}}, true)
end

-- Fetch and show if updates available
function ModpackUpdater:check_updates()
	-- Fetch first
	local cmd = string.format('git -C "%s" fetch 2>&1', self.repo_path)
	local handle = io.popen(cmd)
	handle:read("*a")
	handle:close()

	-- Check difference
	cmd = string.format('git -C "%s" log HEAD..origin/main --oneline 2>&1', self.repo_path)
	handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()

	local message = result ~= "" and ("Updates available:\n" .. result) or "Already up to date!"
	QuickMenu:new("Check Updates", message, {{text = "OK", is_cancel_button = true}}, true)
end

-- Get version on load
ModpackUpdater.version = ModpackUpdater:get_version()

-- Localization
Hooks:Add("LocalizationManagerPostInit", "ModpackUpdater_Loc", function(loc)
	LocalizationManager:add_localized_strings({
		["modpack_updater_menu_title"] = "Modpack [" .. ModpackUpdater.version .. "]",
		["modpack_updater_menu_desc"] = "Modpack updater menu",
		["modpack_updater_pull_title"] = "Update Modpack",
		["modpack_updater_pull_desc"] = "Pull latest changes from git",
		["modpack_updater_status_title"] = "Check Local Changes",
		["modpack_updater_status_desc"] = "Show uncommitted local changes",
		["modpack_updater_check_title"] = "Check for Updates",
		["modpack_updater_check_desc"] = "Fetch and check if updates are available",
	})
end)

-- Add callbacks
Hooks:Add("MenuManagerInitialize", "ModpackUpdater_Init", function(menu_manager)
	MenuCallbackHandler.modpack_updater_pull = function(self, item)
		ModpackUpdater:pull_modpack()
	end
	MenuCallbackHandler.modpack_updater_status = function(self, item)
		ModpackUpdater:check_status()
	end
	MenuCallbackHandler.modpack_updater_check = function(self, item)
		ModpackUpdater:check_updates()
	end
end)

-- Build the menu
Hooks:Add("MenuManagerSetupCustomMenus", "ModpackUpdater_Setup", function(menu_manager, nodes)
	MenuHelper:NewMenu(ModpackUpdater.menu_id)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "ModpackUpdater_Populate", function(menu_manager, nodes)
	MenuHelper:AddButton({
		id = "modpack_updater_pull_btn",
		title = "modpack_updater_pull_title",
		desc = "modpack_updater_pull_desc",
		callback = "modpack_updater_pull",
		menu_id = ModpackUpdater.menu_id,
		priority = 3
	})
	MenuHelper:AddButton({
		id = "modpack_updater_check_btn",
		title = "modpack_updater_check_title",
		desc = "modpack_updater_check_desc",
		callback = "modpack_updater_check",
		menu_id = ModpackUpdater.menu_id,
		priority = 2
	})
	MenuHelper:AddButton({
		id = "modpack_updater_status_btn",
		title = "modpack_updater_status_title",
		desc = "modpack_updater_status_desc",
		callback = "modpack_updater_status",
		menu_id = ModpackUpdater.menu_id,
		priority = 1
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ModpackUpdater_Build", function(menu_manager, nodes)
	nodes[ModpackUpdater.menu_id] = MenuHelper:BuildMenu(ModpackUpdater.menu_id, {back_callback = "menu_back"})

	-- Add menu entry to options menu
	local options_node = nodes.options
	if options_node then
		MenuHelper:AddMenuItem(options_node, ModpackUpdater.menu_id, "modpack_updater_menu_title", "modpack_updater_menu_desc")
	end
end)
