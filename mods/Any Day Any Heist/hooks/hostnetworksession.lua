Hooks:PostHook(HostNetworkSession, "chk_all_handshakes_complete", "peer_joined_update_random_chain", function(self)
	if Global.random_jobs.show_debug == true then
		log("host network update random chain")
	end

	local Net = _G.LuaNetworking
	if Net:IsHost() then
		self:sync_update_random_chain()
	end
	
	if Global.random_jobs.show_debug == true then
		log("host network random job chain synced")
	end
end)

function HostNetworkSession:sync_update_random_chain()
	if Global.random_jobs.show_debug == true then
		log("host network sync update random chain")
	end

	local Net = _G.LuaNetworking
	local job_id = Global.game_settings.job_id
	
	if job_id ~= nil and string.sub(job_id,1,-4) == "dayselect_random_" and Net:IsHost() then
		if table.getn(Global.random_jobs.chain) > 0 and table.getn(Global.random_jobs.stealth_chain) > 0 then
			local num_of_days = tonumber(string.sub(job_id,-1,-1))
			local is_stealth = Global.random_jobs.stealth
			local chain_data = job_id.."|"..num_of_days.."|"..tostring(is_stealth).."|"
			
			local chain_to_send = nil
			if is_stealth == false then
				chain_to_send = deep_clone(Global.random_jobs.keys)
			elseif is_stealth == true then
				chain_to_send = deep_clone(Global.random_jobs.stealth_keys)
			end
			
			for k,v in pairs(chain_to_send) do
				chain_data = chain_data..v.."|"
			end
			Net:SendToPeers("update_random_job_chain", chain_data)
		end
	end
end

Hooks:Add("NetworkReceivedData", "network_update_random_job_chain", function(sender, id, data)
	if id == "update_random_job_chain" then
		if Global.random_jobs.show_debug == true then
			log("host network random chain received")
		end
	
		local split_data = string.split(data, "|")
		local job_id = split_data[1]
		local num_of_days = tonumber(split_data[2])
		local is_stealth = split_data[3]
		
		local new_chain = {}
		local new_keys = {}
		local t = 3 -- table offset
		for i=1,num_of_days do
			if split_data[i+t] ~= "" then
				new_chain[i] = tweak_data.narrative.stages[split_data[i+t]]
				new_keys[i] = split_data[i+t]
			end
		end
		
		if is_stealth == "false" then
			Global.random_jobs.chain = new_chain
			Global.random_jobs.keys = new_keys
			tweak_data.narrative.jobs[job_id].chain = Global.random_jobs.chain
		else
			Global.random_jobs.stealth_chain = new_chain
			Global.random_jobs.stealth_keys = new_keys
			tweak_data.narrative.jobs[job_id].chain = Global.random_jobs.stealth_chain
		end
	end
end)