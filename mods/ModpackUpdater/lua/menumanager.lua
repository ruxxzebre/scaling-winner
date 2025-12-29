-- Modpack Updater mod

ModpackUpdater = ModpackUpdater or {}
ModpackUpdater._mod_path = ModPath
ModpackUpdater.repo_path = ModpackUpdater._mod_path .. "../../"
ModpackUpdater.cache_file = ModpackUpdater._mod_path .. "version_cache.json"

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

-- Helper: get current version info from git
local function get_version_info()
	local version = trim(run_git("rev-parse --short=4 HEAD") or "")
	local commit = trim(run_git("log -1 --format=%s") or "")
	local date = trim(run_git("log -1 --format=%ci") or "")
	return {
		version = version,
		commit = commit,
		date = date
	}
end

-- Helper: save version info to cache file
local function save_cache(info)
	local data = {
		version = info.version,
		commit = info.commit,
		date = info.date,
		cached_at = os.date("%Y-%m-%d %H:%M:%S")
	}
	FileIO:WriteScriptData(ModpackUpdater.cache_file, data, "json")
end

-- Helper: load version info from cache file
local function load_cache()
	if not FileIO:Exists(ModpackUpdater.cache_file) then
		return nil
	end
	return FileIO:ReadScriptData(ModpackUpdater.cache_file, "json")
end

-- Check version - shows cached version info (instant, no git)
function MenuCallbackHandler:ModpackUpdater_CheckVersion()
	local cache = load_cache()

	if not cache then
		show_dialog("No Version Data", "No cached version info found.\n\nClick 'Update Modpack' to fetch latest version.")
		return
	end

	local msg = string.format(
		"Version: %s\nCommit: %s\nDate: %s\n\nCached at: %s",
		cache.version or "?",
		cache.commit or "?",
		cache.date or "?",
		cache.cached_at or "?"
	)

	show_dialog("Modpack Version", msg)
end

-- Update modpack - runs git pull and regenerates cache
function MenuCallbackHandler:ModpackUpdater_Update()
	local pull_result, pull_err = run_git("pull")

	if pull_err then
		show_dialog("Update Failed", "Git pull failed:\n\n" .. (pull_result or pull_err))
		return
	end

	-- Get and cache new version info
	local info = get_version_info()
	save_cache(info)

	local msg = string.format(
		"Pull Result:\n%s\n\nNew Version: %s\nCommit: %s\nDate: %s\n\nRestart game to apply changes.",
		trim(pull_result),
		info.version,
		info.commit,
		info.date
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
