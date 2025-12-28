Hooks:PreHook(LootManager, "init", "hook_lootmanager_init", function(self)
	if Global.random_jobs.show_debug == true then
		log("loot manager init")
	end
	
	local Net = _G.LuaNetworking
	
	if Net:IsHost() and Global.game_settings.job_id and Global.game_settings.job_id ~= nil then
		local job_id = Global.game_settings.job_id
		local level_id = Global.game_settings.level_id

		self:dayselect_check_job_other(job_id, level_id)
	end
end)

Hooks:PreHook(LootManager, "_repossess_bags_for_distribution", "hook_repossess_bags_for_distribution", function(self)
	if Global.random_jobs.show_debug == true then
		log("loot manager repossess bags")
	end

	local Net = _G.LuaNetworking
	
	if Net:IsHost() and Global.game_settings.job_id and Global.game_settings.job_id ~= nil then
		local job_id = Global.game_settings.job_id
		local level_id = Global.game_settings.level_id

		self:dayselect_check_job_bags(job_id, level_id)
	end
end)

Hooks:PostHook(LootManager, "init", "post_hook_lootmanager_init", function(self)
	if Global.random_jobs.show_debug == true then
		log("loot manager post_init")
	end
	
	local Net = _G.LuaNetworking
	
	if Net:IsHost() and Global.random_jobs.secured then
		self:dayselect_insert_carry_over_bags()
	end
end)

function LootManager:dayselect_insert_carry_over_bags()
	if Global.random_jobs.show_debug == true then
		log("loot manager insert carry over bags")
		_G.PrintTable(Global.random_jobs.secured)
	end

	if Global.random_jobs.stage ~= 0 and Global.random_jobs.stage == Global.random_jobs.num_of_stages then
		for k,v in pairs(Global.random_jobs.secured) do
			self:dayselect_insert_bags(v.carry_id, 1)
		end
	end
end

function LootManager:dayselect_insert_bags(carry_id, num_of_bags)
	if Global.random_jobs.show_debug == true then
		log("loot manager insert bags", num_of_bags, carry_id)
	end

	for i=1,num_of_bags do
		table.insert(self._global.secured, { carry_id = carry_id, multiplier = 1, peer_id = 1 })
	end
end

function LootManager:dayselect_check_job_other(cur_job_id, cur_stage_id)
	if Global.random_jobs.show_debug == true then
		log("loot manager check job other")
	end
	
	if string.sub(cur_job_id,1,6) == "escape" or (string.sub(cur_stage_id,1,6) == "escape" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		Global.mission_manager.stage_job_values["reqLoot"] = 0
	end
	
	if cur_job_id == "framing_frame_s_3" or (cur_stage_id == "framing_frame_3" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		local frames = math.random(4, 9)
		Global.mission_manager.stage_job_values["framesTraded"] = frames
	
	elseif cur_job_id == "alex_s_3" or (cur_stage_id == "alex_3" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		Global.mission_manager.stage_job_values["ratCode"] = 1
	end
end

function LootManager:dayselect_check_job_bags(cur_job_id, cur_stage_id)
	if Global.random_jobs.show_debug == true then
		log("loot manager check job")
	end

	local c_ids = { 
		"coke",
		"gold",
		"meth",
		"money",
		"painting",
		"weapon"
	}
	
	if string.sub(cur_job_id,1,6) == "escape" or (string.sub(cur_stage_id,1,6) == "escape" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		if Global.random_jobs.interupt == nil then
			local loot_type = math.random(6)
			local bags = math.random(4, 8)
			self:dayselect_insert_bags(c_ids[loot_type], bags)
		end
		
		Global.mission_manager.stage_job_values["reqLoot"] = 0
	end
	
	if string.sub(cur_job_id,1,13) == "watchdogs_s_2" or (string.sub(cur_stage_id,1,11) == "watchdogs_2" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		local wd_escapes = {
			"car",
			"heli"
		}
		
		local escape = math.random(2)
		self:dayselect_insert_bags("coke", 4)
		Global.mission_manager.stage_job_values["lootInTruck"] = 4
		Global.mission_manager.stage_job_values["escape"] = wd_escapes[escape]
	
	elseif cur_job_id == "framing_frame_s_2" or (cur_stage_id == "framing_frame_2" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		self:dayselect_insert_bags("painting", 4)
		Global.mission_manager.stage_job_values["stage1Alarm"] = 1
	
	elseif cur_job_id == "alex_s_2" or (cur_stage_id == "alex_2" and string.sub(cur_job_id,1,-4) == "dayselect_random_") then
		self:dayselect_insert_bags("meth", 3)
	end
end
