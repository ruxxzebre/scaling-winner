local row_count = 1
local move_amount = 22
Hooks:PreHook(HUDStageEndScreen, "anim_count_experience", "anim_count_experience_show_all_lines", function(self,o,stat)
    row_count = row_count + 1
    local sign = stat > 0 and "+ " or "- "
    local text_xp = self._bonuses_panel:text({rotation = 360, layer = 3, alpha = 1, font = tweak_data.menu.pd2_small_font, font_size = tweak_data.menu.pd2_small_font_size, color = o:child("stat"):color(), text = sign .. managers.money:add_decimal_marks_to_string(tostring(math.abs(stat)))})
	local text_name = self._bonuses_panel:text({rotation = 360, layer = 3, alpha = 1, font = tweak_data.menu.pd2_small_font, font_size = tweak_data.menu.pd2_small_font_size, color = o:child("stat"):color(), text = o:child("title"):text()})
    text_xp:set_size(self._experience_text_panel:child("stat"):size())
	text_xp:set_world_position(self._experience_text_panel:child("stat"):world_position())
    text_xp:set_y(row_count * o:h())
    text_xp:move((stat > 0) and -16 or -12,0)
    text_name:set_size(self._experience_text_panel:child("title"):size())
	text_name:set_world_position(self._experience_text_panel:child("title"):world_position())
    text_name:set_y(row_count * o:h())
    text_name:set_x(0)
	if row_count > 7 then
		self._foreground_layer_safe:child("skip_forepanel"):move(0,move_amount)
		self._lp_forepanel:set_h(self._lp_forepanel:h()+move_amount)
		self._lp_curr_xp:move(0,move_amount)
		self._lp_xp_gained:move(0,move_amount)
		self._lp_next_level:move(0,move_amount)
		self._lp_skill_points:move(0,move_amount)
		self._lp_xp_curr:move(0,move_amount)
		self._lp_xp_gain:move(0,move_amount)
		self._lp_xp_nl:move(0,move_amount)
		self._lp_sp_gain:move(0,move_amount)
		self._lp_sp_info:move(0,move_amount)
		move_amount = 17
	end
end)