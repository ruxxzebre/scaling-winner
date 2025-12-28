Hooks:PostHook(JobManager, "deactivate_current_job", "hook_post_activate_job", function(self)
	if Global.random_jobs.show_debug == true then
		log("job manager deactivate current job")
	end

	local Net = _G.LuaNetworking
	
	Global.random_jobs.secured = {}
	Global.random_jobs.stage = 0
	Global.random_jobs.num_of_stages = -1
	Global.game_settings.job_id = nil
	
	if Net:IsHost() then
		Global.random_jobs.randomized = false
		managers.assets:randomize_jobs()
	end
end)

Hooks:PreHook(JobManager, "next_stage", "hook_pre_next_stage", function(self)
	if Global.random_jobs.show_debug == true then
		log("job manager next stage")
	end

	local Net = _G.LuaNetworking
	
	if Net:IsHost() and Global.game_settings.job_id then
		local job_id = Global.game_settings.job_id
		local interupt = self._global.next_interupt_stage
		Global.random_jobs.stage = self:current_stage()+1
		
		if string.sub(job_id,1,-4) == "dayselect_random_" and interupt == nil then
			self:carry_over_bags(managers.loot._global.secured)
			managers.loot._global.secured = {}
		end
	end
end)

function JobManager:carry_over_bags(bags)
	if self:on_last_stage() == false then
		for k,v in pairs(bags) do
			table.insert(Global.random_jobs.secured, { carry_id = v.carry_id })
		end
	end
end