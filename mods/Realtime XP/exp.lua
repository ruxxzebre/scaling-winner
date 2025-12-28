local Void_UI = VoidUI and VoidUI.loaded
local Custom_HUDs = Void_UI
blt.xaudio.setup()
local buff = XAudio.Buffer
local src = XAudio.Source
local PD2old = buff:new(ModPath .. "PD2.ogg")
local PDTH = buff:new(ModPath .. "PDTH.ogg")

tweak_data.infamy.infamy_icons[5].color = Color("B68B19")
tweak_data.hud_icons.rep_upgrade = {
	texture = "guis/textures/pd2/endscreen/rep_upgrade",
	texture_rect = {0, 0, 128, 128}
}
tweak_data.hud_icons.ace_symbol = {
	texture = "guis/textures/pd2/skilltree_2/ace_symbol",
	texture_rect = {0, 0, 128, 128}
}
tweak_data.hud_icons.empty = {
	texture = "guis/textures/empty",
	texture_rect = {0, 0, 128, 128}
}

local function keep_width(text, width)
	local _, _, w, _ = text:text_rect()
	while w > width do
		text:set_font_size(text:font_size() * 0.99)
		_, _, w, _ = text:text_rect()
	end
end

if string.lower(RequiredScript) == "lib/managers/localizationmanager" then
	Hooks:Add("LocalizationManagerPostInit", "RealtimeXP_loc", function(...)				
		LocalizationManager:add_localized_strings({
			menu_RealtimeXP_name = "Realtime XP",
			RXP_allow_bottom_tab = "Tab XP info",
			RXP_allow_bottom_tab_desc = "Show information about current reputation level, amount of exp gained and infamy pool.",
			RXP_allow_save = "Progress Save",
			RXP_allow_save_desc = "Keep your progress saved every time you get experience. Disable it if you getting stutters and freezes.",
			RXP_selected_jingle = "Level Up jingle",
			RXP_selected_jingle_desc = "Select level up sound.",
			menu_reached_level_title = "Level Up!",
			menu_reached_level_desc = "Reputation Level Reached",
			menu_current_level_reached = "Reputation Level Reached:   $CURRENT_LVLUP",
			hud_total_xp_gained = "Total XP gained: $XP",
			hud_total_xp_left = "Next rank in: ##$XP##",
			hud_level_ups = "Reputation Levels Reached: $LEVELS",
			hud_ingame_rewarded_xp = "XP gained: $REWARD",
			rxp_selected_jingle_0 = "None",
			rxp_selected_jingle_1 = "Default",
			rxp_selected_jingle_2 = "Aldstone",
			rxp_selected_jingle_3 = "Level Up",
			rxp_selected_jingle_4 = "Side Job (Long)",
			rxp_selected_jingle_5 = "Side Job (Short)",
			rxp_selected_jingle_6 = "Infamy",
			rxp_selected_jingle_7 = "Infamy (Old)",
			rxp_selected_jingle_8 = "Level Up (PAYDAY: The Heist)",
			rxp_selected_jingle_9 = "Current Infamy Stinger",
			menu_reached_rank_title = "Rank reached!",
			menu_reached_rank_desc = "Infamy Rank Reached",
		})
			
		if Idstring("russian"):key() == SystemInfo:language():key() then
			LocalizationManager:add_localized_strings({
				RXP_allow_bottom_tab = "Информация об опыте во кладке TAB",
				RXP_allow_bottom_tab_desc = "Показывает информацию от текущем уровне, количестве опыта, количества полученых уровней и резверве бесславия.",
				RXP_allow_save = "Сохранение прогресса",
				RXP_allow_save_desc = "Сохраняет ваш прогресс каждый раз когда вы получаете опыт. Отключить эту опцию если оно вызывает зависания и фризы.",
				RXP_selected_jingle = "Звук поднятия уровня",
				RXP_selected_jingle_desc = "Выбрать звук повышения уровня.",
				menu_reached_level_title = "Уровень получен!",
				menu_reached_level_desc = "Достигнут уровень репутации",
				menu_current_level_reached = "Достигнут уровень репутации:   $CURRENT_LVLUP",
				hud_total_xp_gained = "Всего получено опыта: $XP",
				hud_total_xp_left = "Следующий ранг через: ##$XP##",
				hud_level_ups = "Уровней репутации достигнуто: $LEVELS",
				hud_ingame_rewarded_xp = "Получено опыта: $REWARD",
				rxp_selected_jingle_0 = "Нет",
				rxp_selected_jingle_1 = "По умолчанию",
				rxp_selected_jingle_9 = "Выбранный звук присоединения",
				menu_reached_rank_title = "Ранг получен!",
				menu_reached_rank_desc = "Достигнут ранг Бесславия",
			})
		end
		
		if Idstring("schinese"):key() == SystemInfo:language():key() then
			LocalizationManager:add_localized_strings({
				menu_RealtimeXP_name = "实时经验值",
				RXP_allow_bottom_tab = "TAB界面中显示实时经验",
				RXP_allow_bottom_tab_desc = "实时显示你的声望等级，已经获得的经验和恶名池进度",
				RXP_allow_save = "保存进度",
				RXP_allow_save_desc = "在你每次获得经验时保存进度。如果遇到卡顿或者保存缓慢请禁用这个功能",
				RXP_selected_jingle = "升级音效",
				RXP_selected_jingle_desc = "选择升级提示音效",
				menu_reached_level_title = "升级!",
				menu_reached_level_desc = "声望等级上升",
				menu_current_level_reached = "声望等级已达:   $CURRENT_LVLUP",
				hud_total_xp_gained = "总计获得经验: $XP",
				hud_total_xp_left = "距离下一级还要: ##$XP##",
				hud_level_ups = "当前声望等级已达: $LEVELS",
				hud_ingame_rewarded_xp = "已获得经验: $REWARD",
				rxp_selected_jingle_0 = "禁用",
				rxp_selected_jingle_1 = "默认",
				rxp_selected_jingle_2 = "奥斯通",
				rxp_selected_jingle_3 = "升级音效",
				rxp_selected_jingle_4 = "任务音效(长)",
				rxp_selected_jingle_5 = "任务音效 (短)",
				rxp_selected_jingle_6 = "恶名晋级",
				rxp_selected_jingle_7 = "恶名晋级 (旧版)",
				rxp_selected_jingle_8 = "升级音效 (收获日；掠夺)",
				rxp_selected_jingle_9 = "当前恶名音效",
				menu_reached_rank_title = "恶名晋级！",
				menu_reached_rank_desc = "恶名等级上升",
			})
		end

	end)

	_G.RealtimeXP = _G.RealtimeXP or {}
	RealtimeXP._mod_path = RealtimeXP._mod_path or ModPath
	RealtimeXP._setting_path = SavePath .. "realtimexp_save.json"
	RealtimeXP.settings = RealtimeXP.settings or {}
	RealtimeXP.stingers = {
		"stinger_feedback_positive",
		"chill_upgrade_stinger",
		"stinger_levelup",
		"sidejob_stinger_long",
		"sidejob_stinger_short",
		"infamous_stinger_generic"
	}

	function RealtimeXP:Save()
		local file = io.open(self._setting_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end

	function RealtimeXP:Load()
		local file = io.open(self._setting_path, "r")
		if file then
			for k, v in pairs(json.decode(file:read("*all")) or {}) do
				self.settings[k] = v
			end
			file:close()
		else
			self.settings = {
				allow_become_infamous = 2,
				allow_bottom_tab = true,
				allow_save = true,
				selected_jingle = 2
			}
			self:Save()
		end
	end

	Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_RealtimeXP", function(...)
		RealtimeXP:Load()
		MenuCallbackHandler.RXP_become_infamous_callback = function(self, item)
			RealtimeXP.settings.allow_become_infamous = tonumber(item:value()) or 2
			RealtimeXP:Save()
		end
		
		MenuCallbackHandler.RXP_allow_save_callback = function(self, item)
			RealtimeXP.settings.allow_save = item:value() == "on" and true or false
			RealtimeXP:Save()
		end
		
		MenuCallbackHandler.RXP_allow_bottom_tab_callback = function(self, item)
			RealtimeXP.settings.allow_bottom_tab = item:value() == "on" and true or false
			RealtimeXP:Save()
		end
		
		MenuCallbackHandler.RXP_selected_jingle_callback = function(self, item)
			RealtimeXP.settings.selected_jingle = tonumber(item:value()) or 2
			RealtimeXP:Save()
			
			local jingle = RealtimeXP.settings.selected_jingle
			if jingle == 8 then
				src:new(PD2old)
			elseif jingle == 9 then
				src:new(PDTH)
			elseif jingle == 10 then
				managers.menu:play_join_stinger_by_index(managers.infamy:selected_join_stinger())
			else
				managers.menu:post_event(RealtimeXP.stingers[RealtimeXP.settings.selected_jingle - 1 or 1])
			end
		end
		
		MenuHelper:LoadFromJsonFile(RealtimeXP._mod_path .. "options.json", RealtimeXP, RealtimeXP.settings)
	end)
end
if string.lower(RequiredScript) == "lib/managers/hud/hudchallengenotification" then
	local data = HudChallengeNotification.init
	function HudChallengeNotification:init(title, text, icon, rewards, queue)
		data(self, title, text, icon, rewards, queue)
		if not Custom_HUDs then
			local level = text and text.level or false
			local rank = text and text.rank or false
			if level then
				local box = ExtendedPanel:new(self)
				box:set_y(20)
				local size = 68
				local player_level_panel = box:panel({
					vertical = "center",
					align = "center",
					name = "player_level_panel",
					y = 10,
					x = 10,
					w = size,
					h = size
				})
				local function exp_ring(color)
					local exp_ring = player_level_panel:bitmap({
						texture = "guis/textures/pd2/endscreen/exp_ring",
						alpha = 0.4,
						texture_rect = {
							16,
							16,
							224,
							224
						},
						w = size,
						h = size,
						color = Color.white
					})
					if color then
						exp_ring:set_alpha(1)
						exp_ring:set_render_template(Idstring("VertexColorTexturedRadial"))
						exp_ring:set_color(color)
					end
				end
				
				exp_ring(Color(tonumber(level) * 0.01, 1, 1))
				exp_ring()
				
				player_level_panel:text({
					vertical = "center",
					align = "center",
					y = 2,
					text = tostring(level),
					font = tweak_data.menu.pd2_massive_font,
					font_size = 29
				})
				local desc = box:text({
					vertical = "center",
					text = managers.localization:to_upper_text("menu_reached_level_desc"),
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size,
					y = -10
				})
				desc:set_left(player_level_panel:right() + 10)
				keep_width(desc, 230)
			elseif rank then
				local box = ExtendedPanel:new(self)
				box:set_y(20)
				local player_level_panel = box:panel({
					vertical = "center",
					align = "center",
					name = "player_level_panel",
					y = 10,
					x = 10,
					w = 50,
					h = 70
				})
				
				local infamy_card = player_level_panel:bitmap({
					texture = "guis/textures/pd2/specialization/perk_icon_card",
					texture_rect = {
						0,
						0,
						64,
						92
					},
					w = 50,
					h = 70
				})
				
				local rank_icon, icon_texture_rect = managers.experience:rank_icon_data(rank)
				local icon_color = (Color.white - (managers.experience:rank_icon_color(rank) or Color(0, 0, 0))):with_alpha(1)

				local tx, ty, tw, th = unpack(icon_texture_rect)
				local icon_data = {
					layer = 2,
					blend_mode = "sub",
					texture = rank_icon,
					texture_rect = {
						tx,
						ty,
						tw,
						th
					},
					color = icon_color,
					w = 7,
					h = 7
				}
				
				local left_top_icon = player_level_panel:bitmap(icon_data)
				local right_top_icon = player_level_panel:bitmap(icon_data)
				left_top_icon:set_position(4, 6)
				right_top_icon:set_rightbottom(infamy_card:right() - 4, infamy_card:bottom() - 6)
				right_top_icon:set_rotation(180)
				
				local text = player_level_panel:text({
					layer = 2,
					vertical = "center",
					align = "center",
					text = managers.experience:rank_string(rank),
					font = tweak_data.menu.pd2_massive_font,
					font_size = 29,
					color = managers.experience:rank_icon_color(rank)
				})
				managers.hud:make_fine_text(text)
				text:set_center(infamy_card:center())
				keep_width(text, infamy_card:w() - 10)
				
				local desc = box:text({
					vertical = "center",
					text = managers.localization:to_upper_text("menu_reached_rank_desc"),
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size,
					y = -10
				})
				managers.hud:make_fine_text(desc)
				desc:set_center(player_level_panel:center())
				desc:set_left(player_level_panel:right() + 10)
				keep_width(desc, 230)
			end
		end
	end
	
	Hooks:PostHook(HudChallengeNotification, "close", "RealtimeXP_play_jingle_again", function()
		managers.experience._message_is_active = false
	end)
end
if string.lower(RequiredScript) == "lib/managers/gageassignmentmanager" then
	local data = GageAssignmentManager.present_progress
	function GageAssignmentManager:present_progress(assignment, peer_name)
		data(self, assignment, peer_name)
		DelayedCalls:Add("Delay_for_calculating_xp_from_gage_packs", 0.1, function()
			managers.experience:add_exp()
		end)
	end
end
if string.lower(RequiredScript) == "lib/managers/experiencemanager" then
	function ExperienceManager:add_exp()
		if not self:_instant_xp_allowed() or managers.crime_spree:is_active() then
			return
		end
		
		local total = self:_total_xp()
		local xp_gained = self._total_xp_gained
		if total > xp_gained then
			self:add_instant_xp(total - xp_gained)
		end
	end
	
	Hooks:PostHook(ExperienceManager, "mission_xp_award", "add_mission_xp", function(self)
		self:add_exp()
	end)
	
	Hooks:PostHook(ExperienceManager, "init", "initial_thingies", function(self)
		self._levels_reached = 0
		self._total_xp_gained = 0
		self._message_is_active = false
	end)
	
	function ExperienceManager:_instant_xp_allowed()
		return managers.job:has_active_job()
	end
	
	function ExperienceManager:_total_xp()
		local players = managers.network:session() and managers.network:session():amount_of_alive_players() or 0
		return managers.experience:get_xp_dissected(true, players, not Utils:IsInCustody())
	end
	
	function ExperienceManager:add_instant_xp(xp)
		if not self:_instant_xp_allowed() then
			return
		end
		
		self._total_xp_gained = self._total_xp_gained + xp
		
		managers.experience:add_points(xp, true)
		
		if managers.hud then
			managers.hud:on_ext_inventory_changed()
		end
		
		if _G.RealtimeXP.settings.allow_save then
			MenuCallbackHandler:save_progress()
			managers.savefile._gui_script:set_text(managers.localization:to_upper_text("hud_ingame_rewarded_xp", {REWARD = managers.money:add_decimal_marks_to_string(tostring(xp))}))
		end
		
		self:realtime_infamy_rank()
	end
	
	function ExperienceManager:realtime_infamy_rank()
		local prank = managers.experience:current_rank()
		local rank = prank + 1
		local max_pool = managers.experience:get_prestige_xp_percentage_progress() == 1
		local offshore_cost = managers.money:get_infamous_cost(rank)
		
		local function allowed(value)
			if value == 1 then
				return managers.money:offshore() >= offshore_cost
			elseif value == 2 then
				return offshore_cost <= 0
			else
				return false
			end
		end
		
		if max_pool and allowed(_G.RealtimeXP.settings.allow_become_infamous) then
			if offshore_cost > 0 then
				managers.money:deduct_from_total(managers.money:total(), TelemetryConst.economy_origin.increase_infamous)
				managers.money:deduct_from_offshore(offshore_cost)
			end
			
			local max_rank = tweak_data.infamy.ranks
			if managers.experience:current_level() < 100 or max_rank <= prank then
				return
			end

			managers.experience:set_current_rank(rank)
			managers.experience:set_current_prestige_xp(0)
			managers.savefile:save_progress()
			managers.savefile:save_setting(true)
			
			if managers.hud then
				local function check()
					if Custom_HUDs then
						return managers.localization:to_upper_text("menu_infamy_rank", {
							rank = prank
						}), "rep_upgrade"
					else
						return {rank = prank}, "empty"
					end
				end

				local desc, texture = check()
				managers.hud:custom_ingame_popup_text(
					managers.localization:to_upper_text("menu_reached_rank_title"),
					desc,
					texture 
				)
			end
			
			managers.menu:post_event("infamous_player_join_stinger")

			if SystemInfo:distribution() == Idstring("STEAM") then
				managers.statistics:publish_level_to_steam()
			end
		end
	end
	
	function ExperienceManager:level_up_message()		
		if managers.hud then
			local plevel = managers.experience:current_level()
			local function check()
				if Custom_HUDs then
					return managers.localization:to_upper_text("menu_current_level_reached", {
						CURRENT_LVLUP = tostring(plevel)
					}), "ace_symbol"
				else
					return {level = tostring(plevel)}, "empty"
				end
			end
			
			local desc, texture = check()
			managers.hud:custom_ingame_popup_text(
				managers.localization:to_upper_text("menu_reached_level_title"),
				desc,
				texture 
			)
		end
		
		if not self._message_is_active then
			local jingle = RealtimeXP.settings.selected_jingle
			if jingle == 8 then
				src:new(PD2old)
			elseif jingle == 9 then
				src:new(PDTH)
			elseif jingle == 10 then
				managers.menu:play_join_stinger_by_index(managers.infamy:selected_join_stinger())
			else
				managers.menu:post_event(RealtimeXP.stingers[RealtimeXP.settings.selected_jingle - 1 or 1])
			end
		end
		
		self._message_is_active = true
	end
	
	Hooks:PostHook(ExperienceManager, "_level_up", "RTX_get_level_up_message", function(self)
		self._levels_reached = self._levels_reached + 1
		self:level_up_message()
	end)
		
	local data = ExperienceManager.give_experience
	function ExperienceManager:give_experience(xp, force_or_debug)
		local allowed_xp = not self:_instant_xp_allowed() and xp or 0
		if self:_instant_xp_allowed() then
			managers.skilltree:give_specialization_points(xp)
			managers.custom_safehouse:give_upgrade_points(xp)
		end
		return data(self, allowed_xp, force_or_debug)
	end
end
if string.lower(RequiredScript) == "lib/managers/hud/hudstageendscreen" then
	local data = HUDStageEndScreen.update
	function HUDStageEndScreen:update(t, dt)
		data(self, t, dt)
		if managers.experience._total_xp_gained ~= 0 and managers.experience:current_level() < 100 then
			self._lp_xp_gain:set_color(tweak_data.screen_colors.skill_color)
			self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(managers.experience._total_xp_gained)))
		end
	end
end
if string.lower(RequiredScript) == "lib/managers/hud/newhudstatsscreen" then
	local data = HUDStatsScreen.recreate_right
	function HUDStatsScreen:recreate_right()
		data(self)
		self:exp_progress(self._right)
	end
	
	local data = HUDStatsScreen.on_ext_inventory_changed
	function HUDStatsScreen:on_ext_inventory_changed()
		data(self)
		self:recreate_right()
	end

	function HUDStatsScreen:_animate_text_pulse(text, exp_gain_ring, exp_ring, bg_ring)
		local t = 0
		local c = text:color()
		local w, h = text:size()
		local cx, cy = text:center()
		local ecx, ecy = exp_gain_ring:center()

		while true do
			local dt = coroutine.yield()
			t = t + dt
			local alpha = math.abs(math.sin(t * 180 * 1))

			text:set_size(math.lerp(w * 2, w, alpha), math.lerp(h * 2, h, alpha))
			text:set_font_size(math.lerp(25, tweak_data.menu.pd2_small_font_size, alpha * alpha))
			text:set_center_y(cy)
			exp_gain_ring:set_size(math.lerp(72, 64, alpha * alpha), math.lerp(72, 64, alpha * alpha))
			exp_gain_ring:set_center(ecx, ecy)
			exp_ring:set_size(exp_gain_ring:size())
			exp_ring:set_center(exp_gain_ring:center())
			bg_ring:set_size(exp_gain_ring:size())
			bg_ring:set_center(exp_gain_ring:center())
		end
	end

	function HUDStatsScreen:exp_progress(exp_panel)
		if not _G.RealtimeXP.settings.allow_bottom_tab or managers.crime_spree:is_active() or Custom_HUDs then
			return
		end
		
		local profile_wrapper_panel = exp_panel:panel({name = "profile_wrapper_panel", x = 15, y = -45})

		local next_level_data = managers.experience:next_level_data() or {}
		local current_progress = (next_level_data.current_points or 1) / (next_level_data.points or 1)
		
		local size = 72
		local bg_ring = profile_wrapper_panel:bitmap({
			texture = "guis/textures/pd2/level_ring_small",
			w = size,
			h = size,
			alpha = 0.4,
			color = Color.black
		})
		local exp_ring = profile_wrapper_panel:bitmap({
			texture = "guis/textures/pd2/level_ring_small",
			render_template = "VertexColorTexturedRadial",
			w = size,
			h = size,
			blend_mode = "add",
			rotation = 360,
			layer = 1,
			color = Color(current_progress, 1, 1)
		})

		bg_ring:set_bottom(profile_wrapper_panel:h())
		exp_ring:set_bottom(profile_wrapper_panel:h())

		local reached = managers.experience._levels_reached
		local prank = managers.experience:current_rank()
		local plevel = managers.experience:current_level()
		local gain_xp = managers.experience._total_xp_gained
		local at_max_level = plevel == managers.experience:level_cap()
		local can_lvl_up = plevel ~= 0 and not at_max_level and next_level_data.current_points <= gain_xp
		local progress = (next_level_data.current_points or 1) / (next_level_data.points or 1)
		local below = reached > 0 and current_progress or (gain_xp or 1) / (next_level_data.points or 1)
		local above = managers.experience:get_prestige_xp_percentage_progress()
		local gain_progress = at_max_level and above or below
		local hw = at_max_level and size + 6 or size
		local exp_gain_ring = profile_wrapper_panel:bitmap({
			texture = at_max_level and "guis/textures/pd2/exp_ring_purple" or "guis/textures/pd2/level_ring_potential_small",
			h = hw,
			w = hw,
			render_template = "VertexColorTexturedRadial",
			blend_mode = "normal",
			rotation = 360,
			layer = 2,
			color = Color(gain_progress, 1, 1)
		})
		if not at_max_level and reached < 1 then
			exp_gain_ring:rotate(360 * (progress - gain_progress))
		end
		
		exp_gain_ring:set_center(exp_ring:center())

		local font_size = tweak_data.menu.pd2_small_font_size
		local is_infamous = prank > 0
		local level_string = tostring(plevel)

		local player_level_panel = profile_wrapper_panel:panel({})
		
		if is_infamous then
			local max_w = 0
			local rank_string = managers.experience:rank_string(prank)
			local use_linebreak = true
			local rank_text, level_text = nil

			if use_linebreak then
				rank_text = player_level_panel:text({
					vertical = "top",
					align = "center",
					rotation = 360,
					layer = 1,
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size - 5,
					text = "[" .. rank_string .. "]",
					color = tweak_data.screen_colors.infamy_color
				})
				level_text = player_level_panel:text({
					vertical = "top",
					align = "center",
					rotation = 360,
					layer = 1,
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size - 5,
					text = level_string,
					color = tweak_data.screen_colors.text
				})

				managers.hud:make_fine_text(rank_text)
				managers.hud:make_fine_text(level_text)

				max_w = math.max(max_w, rank_text:w(), level_text:w())
			else
				local text_string, name_color_ranges = managers.experience:gui_string(player_level, plevel)
				level_text = player_level_panel:text({
					vertical = "top",
					align = "center",
					rotation = 360,
					layer = 1,
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size - 5,
					text = text_string,
					color = tweak_data.screen_colors.text
				})

				for _, color_range in ipairs(name_color_ranges) do
					level_text:set_range_color(color_range.start, color_range.stop, color_range.color)
				end

				managers.hud:make_fine_text(level_text)

				max_w = math.max(max_w, level_text:w())
			end

			local scale = math.min(font_size * 2 / max_w, 1)
			local height_reduction = 4 * scale

			level_text:set_w(max_w)
			level_text:set_font_size(level_text:font_size() * scale)

			local x, y, w, h = level_text:text_rect()

			level_text:set_h(math.ceil(h - height_reduction))

			if rank_text then
				rank_text:set_w(max_w)
				keep_width(rank_text, 28)

				local x, y, w, h = rank_text:text_rect()
				rank_text:set_h(math.ceil(h - height_reduction))
				rank_text:set_y(level_text:bottom())
			end

			player_level_panel:set_w(max_w)

			local panel_h = (rank_text or level_text):bottom() + 2

			player_level_panel:set_h(panel_h)
			player_level_panel:set_center(exp_ring:center())
		else
			local level_text = player_level_panel:text({
				vertical = "center",
				align = "center",
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size,
				text = level_string,
				color = tweak_data.screen_colors.text
			})

			managers.hud:make_fine_text(level_text)
			level_text:set_font_size(level_text:font_size() * math.min(font_size * 2 / level_text:w(), 1))
			player_level_panel:set_size(level_text:size())
		end
		
		player_level_panel:set_center(exp_ring:center())

		local text_offset = 4
		local prestige_xp_left = managers.experience:get_max_prestige_xp() - managers.experience:get_current_prestige_xp()
		
		local prestige_allowed = managers.experience:get_prestige_xp_percentage_progress() < 1 and prank > 0
		local below_max = plevel < 100 or prestige_allowed
		if not below_max then
			local at_max_level_text = profile_wrapper_panel:text({
				name = "at_max_level_text",
				text = managers.localization:to_upper_text("hud_at_max_level"),
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.hud_stats.potential_xp_color
			})

			managers.hud:make_fine_text(at_max_level_text)
			at_max_level_text:set_left(math.round(exp_ring:right() + text_offset))
			at_max_level_text:set_center_y(math.round(exp_ring:center_y()) + 0)
		else
			local next_level_in = profile_wrapper_panel:text({
				text = "",
				name = "next_level_in",
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text
			})
			local points = next_level_data.points - next_level_data.current_points
			
			if at_max_level then
				next_level_in:set_text(managers.localization:to_upper_text("hud_total_xp_left", {XP = managers.money:add_decimal_marks_to_string(tostring(prestige_xp_left))}))
			else
				next_level_in:set_text(managers.localization:to_upper_text("menu_es_next_level") .. " " .. managers.money:add_decimal_marks_to_string(tostring(points)))
			end
			
			managers.menu_component:make_color_text(next_level_in, tweak_data.screen_colors.infamy_color)
			
			managers.hud:make_fine_text(next_level_in)
			next_level_in:set_left(math.round(exp_ring:right() + text_offset))
			next_level_in:set_center_y(math.round(exp_ring:center_y()) - 20)
				
			local text = managers.localization:to_upper_text("hud_total_xp_gained", {XP = managers.money:add_decimal_marks_to_string(tostring(gain_xp))})
			local gain_xp_text = profile_wrapper_panel:text({
				name = "gain_xp_text",
				text = text,
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.hud_stats.potential_xp_color
			})

			managers.hud:make_fine_text(gain_xp_text)
			gain_xp_text:set_left(math.round(exp_ring:right() + text_offset))
			gain_xp_text:set_center_y(math.round(exp_ring:center_y()) + 0)

			local potential_level_up_text = profile_wrapper_panel:text({
				vertical = "center",
				name = "potential_level_up_text",
				blend_mode = "normal",
				align = "left",
				layer = 3,
				text = "",
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font
			})


			if at_max_level then
				potential_level_up_text:set_text(managers.localization:to_upper_text("menu_infamy_infamy_panel_prestige_level") .. " " .. math.floor(managers.experience:get_prestige_xp_percentage_progress() * 100) .. "%")
				potential_level_up_text:set_color(tweak_data.screen_colors.infamy_color)
			else
				if reached > 0 then
					potential_level_up_text:set_text(managers.localization:to_upper_text("hud_level_ups", {LEVELS = tostring(reached)}))
					potential_level_up_text:set_color(tweak_data.hud_stats.potential_xp_color)
				end
			end
			
			managers.hud:make_fine_text(potential_level_up_text)
			potential_level_up_text:set_left(math.round(exp_ring:right() + 4))
			potential_level_up_text:set_center_y(math.round(exp_ring:center_y()) + 20)
			
			if not at_max_level and reached > 0 then
				potential_level_up_text:animate(callback(self, self, "_animate_text_pulse"), exp_gain_ring, exp_ring, bg_ring)
			end
		end	
	end
end