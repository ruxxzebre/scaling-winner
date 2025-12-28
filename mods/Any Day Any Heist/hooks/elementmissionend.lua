Hooks:PreHook(ElementMissionEnd, "on_executed", "pre_hook_on_executed", function(self)
	if Global.random_jobs.show_debug == true then
		log("element mission end on_executed")
	end

	local Net = _G.LuaNetworking
	
	if Net:IsHost() then
		AnyDayAnyHeist:check_escape()
	end
end)