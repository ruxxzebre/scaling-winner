-- Modpack Updater

ModpackUpdater = ModpackUpdater or {}
ModpackUpdater._mod_path = ModPath
ModpackUpdater.repo_path = ModpackUpdater._mod_path .. "../../"

-- Helper: trim whitespace
local function trim(s)
	return s and s:match("^%s*(.-)%s*$") or ""
end

-- Helper: run git command and capture output
local function run_git(args)
	local repo = Path:Normalize(ModpackUpdater.repo_path)
	local cmd = string.format('cd /d "%s" && git %s 2>&1', repo, args)
	local handle = io.popen(cmd)
	if not handle then
		return nil, "Failed to execute command"
	end
	local result = handle:read("*a")
	local success, exit_type, code = handle:close()
	if not success then
		return result, string.format("Command failed (exit %s)", tostring(code or "?"))
	end
	return result, nil
end

-- Helper: show dialog
local function show_dialog(title, message)
	BeardLib.Managers.Dialog:Simple():Show({
		title = title,
		message = message,
		no = false
	})
end

-- Check version - shows dialog with version info
function MenuCallbackHandler:ModpackUpdater_CheckVersion()
	local version, ver_err = run_git("rev-parse --short=4 HEAD")
	local commit, com_err = run_git("log -1 --format=%s")
	local status, stat_err = run_git("status --short")

	if ver_err then
		show_dialog("Error", "Failed to get version:\n" .. (version or ver_err))
		return
	end

	local changes = trim(status)
	if changes == "" then
		changes = "(no local changes)"
	end

	local msg = string.format(
		"Version: %s\nCommit: %s\n\nLocal Changes:\n%s",
		trim(version),
		trim(commit),
		changes
	)

	show_dialog("Modpack Version", msg)
end

-- Update modpack - runs git pull and shows result
function MenuCallbackHandler:ModpackUpdater_Update()
	local pull_result, pull_err = run_git("pull")

	if pull_err then
		show_dialog("Update Failed", "Git pull failed:\n\n" .. (pull_result or pull_err))
		return
	end

	-- Get new version info
	local version = trim(run_git("rev-parse --short=4 HEAD") or "?")
	local commit = trim(run_git("log -1 --format=%s") or "?")

	local msg = string.format(
		"Pull Result:\n%s\n\nNew Version: %s\nCommit: %s\n\nRestart game to apply changes.",
		trim(pull_result),
		version,
		commit
	)

	show_dialog("Update Complete", msg)
end

-- Localization
Hooks:Add("LocalizationManagerPostInit", "ModpackUpdater_Loc", function(loc)
	loc:add_localized_strings({
		modpack_updater_title = "Modpack Updater",
		modpack_updater_desc = "Update or check modpack version"
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
		desc = "Show current modpack version and local changes",
		callback = "ModpackUpdater_CheckVersion",
		menu_id = "modpack_updater_menu",
		priority = 2,
		localized = false
	})

	MenuHelper:AddButton({
		id = "modpack_update",
		title = "Update Modpack",
		desc = "Pull latest changes from git repository",
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
