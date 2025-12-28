if not Global.random_jobs then
	Global.random_jobs = { 
		randomized = false, 
		needs_update = false,
		stealth = false,
		show_debug = false,
		secured = {},
		stage = 0,
		num_of_stages = -1,
		interupt = nil,
		chain = {}, 
		keys = {},
		stealth_chain = {},
		stealth_keys = {},
		contacts = deep_clone(tweak_data.narrative.contacts),
		filter_added = false,
		escape = {
			enabled = false,
			chance = 0
		},
		job_ids = {
			dayselect_random_s_1 = 1,
			dayselect_random_s_2 = 2,
			dayselect_random_s_3 = 3,
			dayselect_random_s_4 = 4,
			dayselect_random_s_5 = 5,
			dayselect_random_s_6 = 6,
			dayselect_random_s_7 = 7
		},
		pro_job_ids = {
			dayselect_random_p_1 = 1,
			dayselect_random_p_2 = 2,
			dayselect_random_p_3 = 3,
			dayselect_random_p_4 = 4,
			dayselect_random_p_5 = 5,
			dayselect_random_p_6 = 6,
			dayselect_random_p_7 = 7
		},
		stealth_job_ids = {
			dayselect_random_t_1 = 1,
			dayselect_random_t_2 = 2,
			dayselect_random_t_3 = 3,
			dayselect_random_t_4 = 4,
			dayselect_random_t_5 = 5,
			dayselect_random_t_6 = 6,
			dayselect_random_t_7 = 7
		},
		stealth_pro_job_ids = {
			dayselect_random_r_1 = 1,
			dayselect_random_r_2 = 2,
			dayselect_random_r_3 = 3,
			dayselect_random_r_4 = 4,
			dayselect_random_r_5 = 5,
			dayselect_random_r_6 = 6,
			dayselect_random_r_7 = 7
		}
	}
end

Hooks:PreHook(MissionAssetsManager, "_setup", "hook_mission_assets_setup", function(self)
	if Global.random_jobs.show_debug == true then
		log("mission assets setup")
	end
	
	if not Global.random_jobs then
		self:init_random_jobs()
	else
		Global.random_jobs.filter_added = false
	end
	
	self:randomize_jobs()
end)

function MissionAssetsManager:randomize_jobs()
	if Global.random_jobs.show_debug == true then
		log("mission assets randomize")
	end

	if Global.random_jobs.randomized == false then
		local blacklists = AnyDayAnyHeist:load_blacklist()
		
		math.randomseed(os.time())
		local randomized = self:generate_random_job_chain(blacklists[1])
		local stealth_randomized = self:generate_random_job_chain(blacklists[2])
		
		self:update_random_job_chains({ randomized[1], stealth_randomized[1] })
		
		Global.random_jobs.chain = randomized[1]
		Global.random_jobs.keys = randomized[2]
		
		Global.random_jobs.stealth_chain = stealth_randomized[1]
		Global.random_jobs.stealth_keys = stealth_randomized[2]
		
		Global.random_jobs.randomized = true
		Global.random_jobs.needs_update = false
		
		if Global.random_jobs.show_debug then
			_G.PrintTable(Global.random_jobs.keys)
			_G.PrintTable(Global.random_jobs.stealth_keys)
		end
	else
		self:update_random_job_chains({ Global.random_jobs.chain, Global.random_jobs.stealth_chain })
	end
end

function MissionAssetsManager:update_random_job_chains(random_chain)
	if Global.random_jobs.show_debug == true then
		log("mission assets update chains")
	end
	
	for k,v in pairs(Global.random_jobs.job_ids) do
		for i=1,v do
			tweak_data.narrative.jobs[k].chain[i] = random_chain[1][i]
		end
	end
	for k,v in pairs(Global.random_jobs.pro_job_ids) do
		for i=1,v do
			tweak_data.narrative.jobs[k].chain[i] = random_chain[1][i]
		end
	end
	for k,v in pairs(Global.random_jobs.stealth_job_ids) do
		for i=1,v do
			tweak_data.narrative.jobs[k].chain[i] = random_chain[2][i]
		end
	end
	for k,v in pairs(Global.random_jobs.stealth_pro_job_ids) do
		for i=1,v do
			tweak_data.narrative.jobs[k].chain[i] = random_chain[2][i]
		end
	end
end

function MissionAssetsManager:generate_random_job_chain(blacklist)
	if Global.random_jobs.show_debug == true then
		log("mission assets generate chain")
		_G.PrintTable(blacklist)
	end

	local num_of_days = 7 -- always generate all 7 days
	
	-- make a list of tables to easily connect ownership
	local chain_keys = {}
	for k,v in pairs(tweak_data.narrative.stages) do
		if v ~= nil then
			chain_keys[v] = k
		end
	end
	
	-- check all DLCs for ownership and create a searchable table for owned DLCs
	local owned = {}
	for k,v in pairs(tweak_data.narrative.jobs) do
		for i,c in pairs(v.chain) do
			local dlc = v.dlc or c.dlc or nil
			if chain_keys[c] ~= nil then
				if dlc == nil or managers.dlc:is_dlc_unlocked(dlc) then
					owned[chain_keys[c]] = 1
				else
					owned[chain_keys[c]] = 0
				end
			end
		end
	end
	
	-- get list of possible stages for a random heist (only owned and not blacklisted)
	local stage_keys = {}
	local n = 0
	for k,v in pairs(tweak_data.narrative.stages) do
		if blacklist[k] ~= 1 and owned[k] == 1 then
			n=n+1
			stage_keys[n] = k
		end
	end
	
	-- incase they blacklist every heist, throw in Bank Heist Random to avoid crashes
	if table.getn(stage_keys) == 0 then
		stage_keys = {
			"branchbank_random",
			"branchbank_random",
			"branchbank_random",
			"branchbank_random",
			"branchbank_random",
			"branchbank_random",
			"branchbank_random"
		}
	elseif table.getn(stage_keys) < 7 then
		local c = 7-table.getn(stage_keys)
		for i=1,c do
			local n = math.random(table.getn(stage_keys))
			table.insert(stage_keys, stage_keys[n])
		end
	end
	
	local random_chain = {}
	local random_keys = {}
	local duplicates = {}
	math.random(table.getn(stage_keys)) -- for some reason the first number is always the same.
	for i=1,num_of_days do
		local n = math.random(table.getn(stage_keys))
		
		duplicates[n] = duplicates[n] and duplicates[n]+1 or 1
		while duplicates[n] > 1 do
			local l = n
			duplicates[n] = duplicates[n]-1
			n=math.random(table.getn(stage_keys))
			duplicates[n] = duplicates[n] and duplicates[n]+1 or 1
		end
		
		random_keys[i] = stage_keys[n]
		random_chain[i] = tweak_data.narrative.stages[stage_keys[n]]
	end
	
	return { random_chain, random_keys }
end

function MissionAssetsManager:init_random_jobs()
	Global.random_jobs = { 
		randomized = false, 
		needs_update = false,
		stealth = false,
		show_debug = false,
		secured = {},
		stage = 0,
		num_of_stages = -1,
		interupt = nil,
		chain = {}, 
		keys = {},
		stealth_chain = {},
		stealth_keys = {},
		contacts = deep_clone(tweak_data.narrative.contacts),
		escape = {
			enabled = false,
			chance = 0
		},
		job_ids = {
			dayselect_random_s_1 = 1,
			dayselect_random_s_2 = 2,
			dayselect_random_s_3 = 3,
			dayselect_random_s_4 = 4,
			dayselect_random_s_5 = 5,
			dayselect_random_s_6 = 6,
			dayselect_random_s_7 = 7
		},
		pro_job_ids = {
			dayselect_random_p_1 = 1,
			dayselect_random_p_2 = 2,
			dayselect_random_p_3 = 3,
			dayselect_random_p_4 = 4,
			dayselect_random_p_5 = 5,
			dayselect_random_p_6 = 6,
			dayselect_random_p_7 = 7
		},
		stealth_job_ids = {
			dayselect_random_t_1 = 1,
			dayselect_random_t_2 = 2,
			dayselect_random_t_3 = 3,
			dayselect_random_t_4 = 4,
			dayselect_random_t_5 = 5,
			dayselect_random_t_6 = 6,
			dayselect_random_t_7 = 7
		},
		stealth_pro_job_ids = {
			dayselect_random_r_1 = 1,
			dayselect_random_r_2 = 2,
			dayselect_random_r_3 = 3,
			dayselect_random_r_4 = 4,
			dayselect_random_r_5 = 5,
			dayselect_random_r_6 = 6,
			dayselect_random_r_7 = 7
		}
	}
end