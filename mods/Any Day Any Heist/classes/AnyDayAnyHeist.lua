AnyDayAnyHeist = AnyDayAnyHeist or class(ModCore)

function AnyDayAnyHeist:loaded_call_back()
	self.loaded = true
end

function AnyDayAnyHeist:apply_blacklist_call_back()
		if Global.random_jobs.show_debug == true then
			log("ADAH apply blacklist")
		end

		if Utils:IsInGameState() == false and not managers.network:session() then
			Global.random_jobs.randomized = false
			MissionAssetsManager:randomize_jobs()
		else
			local title = managers.localization:text("ADAHWarnTitleBlacklistUpdate_id")
			local message = managers.localization:text("ADAHWarnMessageBlacklistUpdate_id")
			local warn = QuickMenu:new(title, message, {}, true)
			local Net = _G.LuaNetworking
			
			if Net:IsHost() then
				Global.random_jobs.randomized = false
				Global.random_jobs.needs_update = true
			end
		end
end

function AnyDayAnyHeist:reset_random_blacklist_call_back()
	if Global.random_jobs.show_debug == true then
		log("ADAH reset random blacklist")
	end

	self.Options:ResetToDefaultValues("ADAHRandomOptions", false, true)
end

function AnyDayAnyHeist:reset_stealth_blacklist_call_back()
	if Global.random_jobs.show_debug == true then
		log("ADAH reset stealth blacklist")
	end

	self.Options:ResetToDefaultValues("ADAHStealthOptions", false, true)
end

-- Next want to add an escape chance option here, if enabled it'll blacklist the escapes from the days
function AnyDayAnyHeist:apply_escape_chance()
	if Global.random_jobs.show_debug == true then
		log("ADAH apply escape chance")
	end

	if not self.heists then
		self:init_heist_data()
	end
	
	if self.Options then
		Global.random_jobs.escape.enabled = self.Options:GetValue("RBL_use_escape_chance")
		Global.random_jobs.escape.chance = self.Options:GetValue("RBL_escape_chance")
	end
	
	if Global.random_jobs.escape.enabled == true then
		for k,v in pairs(self.heists.escapes) do
			self.blacklist[k] = 1
			self.stealth_blacklist[k] = 1
		end
	end
end

function AnyDayAnyHeist:check_escape()
	if Global.random_jobs.show_debug == true then
		log("ADAH check_escape")
	end

	if Global.game_settings.job_id and string.sub(Global.game_settings.job_id,1,-4) == "dayselect_random_" then
		if not self.heists then
			self:init_heist_data()
		end

		if Global.random_jobs.escape.enabled == true then
			local escape_chance = Global.random_jobs.escape.chance
			local escape_roll = math.random(100)
			
			if escape_roll <= escape_chance then
				local escapes = {}
				
				local n=1
				for k,v in pairs(self.heists.escapes) do
					escapes[n] = k
					n=n+1
				end
			
				local e = math.random(table.getn(escapes))
				managers.job:set_next_interupt_stage(escapes[e])
			else 
				managers.job:set_next_interupt_stage(nil)
			end
		end
		
		Global.random_jobs.interupt = managers.job._global.next_interupt_stage
		
	end
end

function AnyDayAnyHeist:reset_all_options_call_back()
	if Global.random_jobs.show_debug == true then
		log("ADAH reset all")
	end
	
	self.Options:ResetToDefaultValues("", false, true)
	self:reset_random_blacklist_call_back()
	self:reset_stealth_blacklist_call_back()
end

function AnyDayAnyHeist:load_blacklist()
	if Global.random_jobs.show_debug == true then
		log("ADAH load blacklist")
	end

	if not self.heists then
		self:init_heist_data()
	end
	
	self.blacklist = {}
	self.stealth_blacklist = {}
	
	self:apply_escape_chance()
	
	self:add_non_heists()
	
	if self.Options and self.Options:GetValue("RBL_use_blacklist") then
		self:add_options()
	end
	
	return { self.blacklist, self.stealth_blacklist }
end

function AnyDayAnyHeist:add_options()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_options")
	end

	self:add_single_heists()
	self:add_contact_heists()
	self:add_custom_heists()
	self:add_type_heists()
end

function AnyDayAnyHeist:add_non_heists()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_non_heists")
	end

	for k,v in pairs(self.heists.non) do
		self.blacklist[k] = 1
		self.stealth_blacklist[k] = 1
	end
end

function AnyDayAnyHeist:add_single_heists()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_single_heists")
	end

	for k,v in pairs(self.heists.stealth) do
		if self.Options:GetValue("ADAHRandomOptions/ADAHSingleStealthBlacklist/RBL_" .. k) then
			self.blacklist[k] = 1
		end
		if self.Options:GetValue("ADAHStealthOptions/ADAHSingleStealthBlacklistStealth/RBL_" .. k .. "_stealth") then
			self.stealth_blacklist[k] = 1
		end
	end
	for k,v in pairs(self.heists.stealthable) do
		if self.Options:GetValue("ADAHRandomOptions/ADAHSingleStealthableBlacklist/RBL_" .. k) then
			self.blacklist[k] = 1
		end
		if self.Options:GetValue("ADAHStealthOptions/ADAHSingleStealthableBlacklistStealth/RBL_" .. k .. "_stealth") then
			self.stealth_blacklist[k] = 1
		end
	end
	for k,v in pairs(self.heists.loud) do
		if self.Options:GetValue("ADAHRandomOptions/ADAHSingleLoudBlacklist/RBL_" .. k) then
			self.blacklist[k] = 1
		end
		if self.Options:GetValue("ADAHStealthOptions/ADAHSingleLoudBlacklistStealth/RBL_" .. k .. "_stealth") then
			self.stealth_blacklist[k] = 1
		end
	end
end

function AnyDayAnyHeist:add_contact_heists()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_contact_heists")
	end

	for k,v in pairs(self.disable.contacts) do
		if self.Options:GetValue("ADAHRandomOptions/ADAHContactBlacklist/RBL_" .. k) then
			for i,c in pairs(self.heists[k]) do
				self.blacklist[i] = 1
			end
		end

		if self.Options:GetValue("ADAHStealthOptions/ADAHStealthContactBlacklist/RBL_" .. k .. "_stealth") then
			for i,c in pairs(self.heists[k]) do
				self.stealth_blacklist[i] = 1
			end
		end
	end
end

function AnyDayAnyHeist:add_type_heists()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_type_heists")
	end

	for k,v in pairs(self.disable.types) do
		if self.Options:GetValue("ADAHRandomOptions/ADAHTypeBlacklist/RBL_" .. k) then
			for i,c in pairs(self.heists[k]) do
				self.blacklist[i] = 1
			end
		end
		
		if self.Options:GetValue("ADAHStealthOptions/ADAHStealthTypeBlacklist/RBL_" .. k .. "_stealth") then
			for i,c in pairs(self.heists[k]) do
				self.stealth_blacklist[i] = 1
			end
		end
	end
end

function AnyDayAnyHeist:add_custom_heists()
	if Global.random_jobs.show_debug == true then
		log("ADAH add_custom_heists")
	end
	
	local custom_stages = {}

	for k,v in pairs(tweak_data.narrative.jobs) do
		if v.custom == true and self.heists.adah[k] == nil then
			for i,c in pairs(tweak_data.narrative.jobs[k].chain) do
				for p,q in pairs(tweak_data.narrative.stages) do
					if c.level_id == q.level_id then
						local level_tweak = tweak_data.levels[c.level_id]
						custom_stages[p] = {
							ghostable = level_tweak.ghost_bonus and level_tweak.ghost_bonus > 0 or false,
							ghost_required = level_tweak.ghost_required and level_tweak.ghost_required == true or false
						}
					end
				end
			end
		end
	end
	
	if self.Options:GetValue("RBL_custom") == false then
		for k,v in pairs(custom_stages) do
			self.blacklist[k] = 1
			self.stealth_blacklist[k] = 1
		end
	elseif self.Options:GetValue("RBL_custom") == true then
		for k,v in pairs(custom_stages) do
			if v.ghost_required == true then
				self.heists.stealth[k] = 1
			elseif v.ghostable == false then
				self.heists.loud[k] = 1
			elseif v.ghostable == true and v.ghost_required == false then
				self.heists.stealthable[k] = 1
			end
		end
	end
end

function AnyDayAnyHeist:init_heist_data()
	if Global.random_jobs.show_debug == true then
		log("ADAH init_heist_data")
	end

	self.blacklist = {}
	self.stealth_blacklist = {}
	
	self.contact_options = {
		randoms = 1,
		random_pros = 1,
		random_stealth = 1,
		random_stealth_pros = 1,
		dayselect = 1,
		escapes = 1
	}
	
	self.disable = {}
	self.disable.contacts = {
		bain = 1,
		blaine = 1,
		classics = 1,
		mcshay = 1,
		hector = 1,
		jimmy = 1,
		jiu = 1,
		locke = 1,
		shayu = 1,
		butcher = 1,
		continental = 1,
		dentist = 1,
		elephant = 1,
		vlad = 1
	}
	self.disable.types = {
		holdout = 1,
		escapes = 1,
		events = 1,
		transport = 1,
		branchbank = 1,
		stealth = 1,
		loud = 1,
		stealthable = 1,
		trades = 1, -- Framing Frame / Rats day 2
		short = 1,
		medium = 1,
		long = 1
		-- custom heists will be in this sub menu
	}
	
	self.heists = {}
	self.heists.non = {
		peta_1 = 1,
		peta_2 = 1,
		rvd1 = 1,
		rvd2 = 1,
		welcome_to_the_jungle_1_n = 1,
		welcome_to_the_jungle_1_d = 1,
		election_day_3_skip1 = 1,
		election_day_3_skip2 = 1,
		escape_overpass_night = 1,
		chill = 1,
		watchdogs_1_n = 1,
		watchdogs_1_d = 1,
		watchdogs_2_n = 1,
		watchdogs_2_d = 1,
		bossp = 1,
		lbe_lobby = 1,
		lbe_lobby_end = 1,
		short_1_1 = 1,
		short_1_2 = 1,
		short_2_1 = 1,
		short_2_2 = 1,
		safehouse = 1
	}
	self.heists.bain = {
		gallery = 1,
		branchbank_cash = 1,
		branchbank_deposit = 1,
		branchbank_gold = 1,
		branchbank_random = 1,
		cage = 1,
		rat = 1,
		family = 1,
		roberts = 1,
		jewelry_store = 1,
		rvd_1 = 1,
		rvd_2 = 1,
		kosugi = 1,
		arena = 1,
		arm_cro = 1,
		arm_hcm = 1,
		arm_fac = 1,
		arm_par = 1,
		arm_for = 1,
		arm_und = 1
	}
	self.heists.classics = {
		dah = 1,
		red2 = 1,
		glace = 1,
		run = 1,
		nmh = 1,
		flat = 1,
		dinner = 1,
		pal = 1,
		man = 1
	}
	self.heists.events = {
		hvh = 1,
		nail = 1,
		help = 1,
		haunted = 1
	}
	self.heists.hector = {
		firestarter_1 = 1,
		firestarter_2 = 1,
		firestarter_3 = 1,
		alex_1 = 1,
		alex_2 = 1,
		alex_3 = 1,
		watchdogs_1_night = 1,
		watchdogs_1 = 1,
		watchdogs_2 = 1,
		watchdogs_2_day = 1
	}
	self.heists.locke = {
		wwh = 1,
		tag = 1,
		brb = 1,
		bph = 1,
		des = 1,
		sah = 1,
		vit = 1,
		pbr = 1,
		pbr2 = 1,
		mex = 1,
		mex_cooking = 1,
		pex = 1
	}
	self.heists.butcher = {
		crojob1 = 1,
		crojob2_d = 1,
		crojob2_n = 1,
		friend = 1
	}
	self.heists.dentist = {
		hox_1 = 1,
		hox_2 = 1,
		hox_3 = 1,
		big = 1,
		mus = 1,
		kenaz = 1,
		mia_1 = 1,
		mia_2 = 1
	}
	self.heists.elephant = {
		welcome_to_the_jungle_1_night = 1,
		welcome_to_the_jungle_1 = 1,
		welcome_to_the_jungle_2 = 1,
		election_day_1 = 1,
		election_day_2 = 1,
		election_day_3 = 1,
		framing_frame_1 = 1,
		framing_frame_2 = 1,
		framing_frame_3 = 1,
		born = 1,
		chew = 1
	}
	self.heists.vlad = {
		jolly = 1,
		four_stores = 1,
		mallcrasher = 1,
		shoutout_raid = 1,
		nightclub = 1,
		cane = 1,
		moon = 1,
		ukrainian_job = 1,
		pines = 1,
		peta = 1,
		peta2 = 1,
		bex = 1,
		fex = 1,
		chca = 1
	}
	self.heists.blaine = {
		corp = 1,
		deep = 1
	}
	self.heists.mcshay = {
		ranc = 1,
		trai = 1
	}
	self.heists.jimmy = {
		mad = 1,
		dark = 1
	}
	self.heists.jiu = {
		chas = 1,
		sand = 1
	}
	self.heists.shayu = {
		pent = 1
	}
	self.heists.continental = {
		spa = 1,
		fish = 1
	}
	self.heists.holdout = {
		skm_red2 = 1,
		skm_cas = 1,
		skm_run = 1,
		skm_mallcrasher = 1,
		skm_bex = 1,
		skm_arena = 1,
		skm_big2 = 1,
		skm_mus = 1,
		skm_watchdogs_stage2 = 1,
		chill_combat = 1
	}
	self.heists.escapes = {
		escape_cafe_day = 1,
		escape_cafe = 1,
		escape_garage = 1,
		escape_overpass = 1,
		escape_park_day = 1,
		escape_park = 1,
		escape_street = 1
	}
	self.heists.transport = {
		arm_cro = 1,
		arm_hcm = 1,
		arm_fac = 1,
		arm_par = 1,
		arm_for = 1,
		arm_und = 1
	}
	self.heists.branchbank = {
		branchbank_random = 1,
		branchbank_deposit = 1,
		branchbank_cash = 1,
		branchbank_gold = 1
	}
	self.heists.trades = {
		framing_frame_2 = 1,
		alex_2 = 1
	}
	self.heists.adah = {
		alex_s_1 = 1,
		alex_s_2 = 1,
		alex_s_3 = 1,
		born_s_1 = 1,
		born_s_2 = 1,
		dayselect_random_p_1 = 1,
		dayselect_random_p_2 = 1,
		dayselect_random_p_3 = 1,
		dayselect_random_p_4 = 1,
		dayselect_random_p_5 = 1,
		dayselect_random_p_6 = 1,
		dayselect_random_p_7 = 1,
		dayselect_random_r_1 = 1,
		dayselect_random_r_2 = 1,
		dayselect_random_r_3 = 1,
		dayselect_random_r_4 = 1,
		dayselect_random_r_5 = 1,
		dayselect_random_r_6 = 1,
		dayselect_random_r_7 = 1,
		dayselect_random_s_1 = 1,
		dayselect_random_s_2 = 1,
		dayselect_random_s_3 = 1,
		dayselect_random_s_4 = 1,
		dayselect_random_s_5 = 1,
		dayselect_random_s_6 = 1,
		dayselect_random_s_7 = 1,
		dayselect_random_t_1 = 1,
		dayselect_random_t_2 = 1,
		dayselect_random_t_3 = 1,
		dayselect_random_t_4 = 1,
		dayselect_random_t_5 = 1,
		dayselect_random_t_6 = 1,
		dayselect_random_t_7 = 1,
		election_day_s_1 = 1,
		election_day_s_2 = 1,
		election_day_s_3 = 1,
		escape_cafe_day_s = 1,
		escape_cafe_s = 1,
		escape_garage_s = 1,
		escape_overpass_s = 1,
		escape_park_day_s = 1,
		escape_park_s = 1,
		escape_street_s = 1,
		firestarter_s_1 = 1,
		firestarter_s_2 = 1,
		firestarter_s_3 = 1,
		framing_frame_s_1 = 1,
		framing_frame_s_2 = 1,
		framing_frame_s_3 = 1,
		hl_miami_s_1 = 1,
		hl_miami_s_2 = 1,
		hox_s_1 = 1,
		hox_s_2 = 1,
		peta_s_1 = 1,
		peta_s_2 = 1,
		rvd_s_1 = 1,
		rvd_s_2 = 1,
		watchdogs_s_1 = 1,
		watchdogs_s_1n = 1,
		watchdogs_s_2 = 1,
		watchdogs_s_2n = 1,
		welcome_to_the_jungle_s_1 = 1,
		welcome_to_the_jungle_s_1n = 1,
		welcome_to_the_jungle_s_2 = 1
	}
	self.heists.stealth = {
		tag = 1,
		cage = 1,
		dark = 1,
		kosugi = 1,
		fish = 1
	}
	self.heists.loud = {
		jolly = 1,
		wwh = 1,
		pbr = 1,
		welcome_to_the_jungle_2 = 1,
		pbr2 = 1,
		mad = 1,
		mex_cooking = 1,
		spa = 1,
		brb = 1,
		rat = 1,
		pal = 1,
		hvh = 1,
		election_day_3 = 1,
		escape_cafe_day = 1,
		escape_cafe = 1,
		escape_garage = 1,
		escape_overpass = 1,
		escape_park_day = 1,
		escape_park = 1,
		escape_street = 1,
		firestarter_1 = 1,
		peta = 1,
		peta2 = 1,
		glace = 1,
		run = 1,
		bph = 1,
		des = 1,
		skm_red2 = 1,
		skm_cas = 1,
		skm_run = 1,
		skm_mallcrasher = 1,
		skm_bex = 1,
		skm_arena = 1,
		skm_big2 = 1,
		skm_mus = 1,
		skm_watchdogs_stage2 = 1,
		mia_1 = 1,
		mia_2 = 1,
		hox_1 = 1,
		hox_2 = 1,
		nail = 1,
		shoutout_raid = 1,
		nmh = 1,
		flat = 1,
		help = 1,
		alex_1 = 1,
		alex_2 = 1,
		alex_3 = 1,
		rvd_1 = 1,
		rvd_2 = 1,
		haunted = 1,
		chill_combat = 1,
		cane = 1,
		dinner = 1,
		moon = 1,
		born = 1,
		chew = 1,
		crojob2_d = 1,
		crojob2_n = 1,
		safehouse = 1,
		arm_cro = 1,
		arm_hcm = 1,
		arm_fac = 1,
		arm_par = 1,
		arm_und = 1,
		man = 1,
		watchdogs_1_night = 1,
		watchdogs_1 = 1,
		watchdogs_2 = 1,
		watchdogs_2_day = 1,
		pines = 1
	}
	self.heists.stealthable = {
		gallery = 1,
		branchbank_cash = 1,
		branchbank_deposit = 1,
		branchbank_gold = 1,
		branchbank_random = 1,
		welcome_to_the_jungle_1_night = 1,
		welcome_to_the_jungle_1 = 1,
		chca = 1,
		mex = 1,
		pex = 1,
		fex = 1,
		deep = 1,
		dah = 1,
		family = 1,
		chas = 1,
		election_day_1 = 1,
		election_day_2 = 1,
		firestarter_2 = 1,
		firestarter_3 = 1,
		red2 = 1,
		four_stores = 1,
		framing_frame_1 = 1,
		framing_frame_2 = 1,
		framing_frame_3 = 1,
		roberts = 1,
		kenaz = 1,
		corp = 1,
		hox_3 = 1,
		jewelry_store = 1,
		trai = 1,
		mallcrasher = 1,
		ranc = 1,
		pent = 1,
		nightclub = 1,
		bex = 1,
		friend = 1,
		sah = 1,
		arena = 1,
		big = 1,
		crojob1 = 1,
		mus = 1,
		sand = 1,
		vit = 1,
		arm_for = 1,
		ukrainian_job = 1
	}
	self.heists.short = {
	}
	self.heists.medium = {
	}
	self.heists.long = {
	}
	self.heists.single = {
		jolly = 1,
		wwh = 1,
		gallery = 1,
		branchbank_cash = 1,
		branchbank_deposit = 1,
		branchbank_gold = 1,
		branchbank_random = 1,
		pbr = 1,
		welcome_to_the_jungle_1_night = 1,
		welcome_to_the_jungle_1 = 1,
		welcome_to_the_jungle_2 = 1,
		pbr2 = 1,
		chca = 1,
		mad = 1,
		mex = 1,
		mex_cooking = 1,
		pex = 1,
		tag = 1,
		spa = 1,
		brb = 1,
		fex = 1,
		cage = 1,
		rat = 1,
		pal = 1,
		deep = 1,
		hvh = 1,
		dah = 1,
		family = 1,
		chas = 1,
		election_day_1 = 1,
		election_day_2 = 1,
		election_day_3 = 1,
		escape_cafe_day = 1,
		escape_cafe = 1,
		escape_garage = 1,
		escape_overpass = 1,
		escape_park_day = 1,
		escape_park = 1,
		escape_street = 1,
		firestarter_1 = 1,
		firestarter_2 = 1,
		firestarter_3 = 1,
		red2 = 1,
		four_stores = 1,
		framing_frame_1 = 1,
		framing_frame_2 = 1,
		framing_frame_3 = 1,
		roberts = 1,
		peta = 1,
		peta2 = 1,
		kenaz = 1,
		glace = 1,
		run = 1,
		bph = 1,
		des = 1,
		skm_red2 = 1,
		skm_cas = 1,
		skm_run = 1,
		skm_mallcrasher = 1,
		skm_bex = 1,
		skm_arena = 1,
		skm_big2 = 1,
		skm_mus = 1,
		skm_watchdogs_stage2 = 1,
		corp = 1,
		mia_1 = 1,
		mia_2 = 1,
		hox_1 = 1,
		hox_2 = 1,
		hox_3 = 1,
		jewelry_store = 1,
		nail = 1,
		trai = 1,
		mallcrasher = 1,
		shoutout_raid = 1,
		ranc = 1,
		pent = 1,
		dark = 1,
		nightclub = 1,
		nmh = 1,
		flat = 1,
		help = 1,
		alex_1 = 1,
		alex_2 = 1,
		alex_3 = 1,
		rvd_1 = 1,
		rvd_2 = 1,
		haunted = 1,
		chill_combat = 1,
		bex = 1,
		cane = 1,
		friend = 1,
		sah = 1,
		kosugi = 1,
		dinner = 1,
		moon = 1,
		arena = 1,
		big = 1,
		born = 1,
		chew = 1,
		crojob1 = 1,
		crojob2_d = 1,
		crojob2_n = 1,
		mus = 1,
		safehouse = 1,
		sand = 1,
		vit = 1,
		fish = 1,
		arm_cro = 1,
		arm_hcm = 1,
		arm_fac = 1,
		arm_par = 1,
		arm_for = 1,
		arm_und = 1,
		ukrainian_job = 1,
		man = 1,
		watchdogs_1_night = 1,
		watchdogs_1 = 1,
		watchdogs_2 = 1,
		watchdogs_2_day = 1,
		pines = 1
	}
end

-- function AnyDayAnyHeist:test_all_stages_included()
	-- local all_stages = {}
	-- for k,v in pairs(self.heists.stealth) do
		-- if not all_stages[k] then
			-- all_stages[k] = v
		-- else
			-- log("duplicate? ", k)
		-- end
	-- end
	-- for k,v in pairs(self.heists.stealthable) do
		-- if not all_stages[k] then
			-- all_stages[k] = v
		-- else
			-- log("duplicate? ", k)
		-- end
	-- end
	-- for k,v in pairs(self.heists.loud) do
		-- if not all_stages[k] then
			-- all_stages[k] = v
		-- else
			-- log("duplicate? ", k)
		-- end
	-- end
	-- for k,v in pairs(self.heists.non) do
		-- if not all_stages[k] then
			-- all_stages[k] = v
		-- else
			-- log("duplicate? ", k)
		-- end
	-- end
	
	-- log(table.getn(tweak_data.narrative.stages), table.getn(all_stages))
	
	-- for k,v in pairs(tweak_data.narrative.stages) do
		-- if all_stages[k] then
			-- all_stages[k] = nil
		-- else
			-- log("does not have: ", k)
		-- end
	-- end
-- end

-- function AnyDayAnyHeist:calc_averages()
	-- for d=1,7 do
		-- log("dif", d)
		-- local averages = {
			-- payout = 0,
			-- xp_mul = 0,
			-- cost = 0,
			-- min_xp = 0,
			-- max_xp = 0,
			
			-- payout_c = 0,
			-- xp_mul_c = 0,
			-- cost_c = 0,
			-- min_xp_c = 0,
			-- max_xp_c = 0
		-- }
		
		-- for k,v in pairs(tweak_data.narrative.jobs) do
			-- if v.payout and v.payout[d] then
				-- averages.payout = averages.payout+v.payout[d]
				-- averages.payout_c = averages.payout_c+1
			-- end
			-- if v.experience_mul and v.experience_mul[d] then
				-- averages.xp_mul = averages.xp_mul+v.experience_mul[d]
				-- averages.xp_mul_c = averages.xp_mul_c+1
			-- end
			-- if v.contract_cost and v.contract_cost[d] then
				-- averages.cost = averages.cost+v.contract_cost[d]
				-- averages.cost_c = averages.cost_c+1
			-- end
			-- if v.contract_visuals then
				-- if v.contract_visuals.min_mission_xp and type(v.contract_visuals.min_mission_xp) == "table" and v.contract_visuals.min_mission_xp[d] then
					-- averages.min_xp = averages.min_xp+v.contract_visuals.min_mission_xp[d]
					-- averages.min_xp_c = averages.min_xp_c+1
				-- end
				-- if v.contract_visuals.max_mission_xp and type(v.contract_visuals.max_mission_xp) == "table" and v.contract_visuals.max_mission_xp[d] then
					-- averages.max_xp = averages.max_xp+v.contract_visuals.max_mission_xp[d]
					-- averages.max_xp_c = averages.max_xp_c+1
				-- end
			-- end
		-- end
		
		-- averages.payout = averages.payout/averages.payout_c
		-- averages.xp_mul = averages.xp_mul/averages.xp_mul_c
		-- averages.cost = averages.cost/averages.cost_c
		-- averages.min_xp = averages.min_xp/averages.min_xp_c
		-- averages.max_xp = averages.max_xp/averages.max_xp_c
		-- _G.PrintTable(averages)
	-- end
-- end