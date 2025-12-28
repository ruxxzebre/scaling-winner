Hooks:PreHook(MenuCallbackHandler, "start_job", "hook_start_job", function(self, job_data)
	if Global.random_jobs.show_debug == true then
		log("menu manager start_job")
	end
	
	local Net = _G.LuaNetworking
	
	Global.game_settings.job_id = job_data.job_id
	Global.random_jobs.num_of_stages = tonumber(string.sub(job_data.job_id,-1,-1))
	Global.random_jobs.stealth = string.sub(job_data.job_id, -3, -3) == "t" or string.sub(job_data.job_id, -3, -3) == "r"

	if Net:IsHost() then
		if Global.random_jobs.needs_update and Utils:IsInGameState() == false then
			MissionAssetsManager:randomize_jobs()
		end
		
		HostNetworkSession:sync_update_random_chain()
	end
end)

Hooks:PreHook(MenuCallbackHandler, "start_single_player_job", "hook_start_single_player_job", function(self, job_data)
	if Global.random_jobs.show_debug == true then
		log("menu manager start_single_player_job")
	end
	
	Global.game_settings.job_id = job_data.job_id
	Global.random_jobs.num_of_stages = tonumber(string.sub(job_data.job_id,-1,-1))
	Global.random_jobs.stealth = string.sub(job_data.job_id, -3, -3) == "t" or string.sub(job_data.job_id, -3, -3) == "r"
end)