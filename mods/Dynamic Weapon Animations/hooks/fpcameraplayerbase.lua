
local fp_stance_mod = {}

Hooks:PostHook(FPCameraPlayerBase, "clbk_stance_entered", "immersive_fpcamera_stance_entered", function(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration, head_duration_multiplier, head_duration)
	fp_stance_mod = stance_mod
end)

Hooks:PostHook(FPCameraPlayerBase, "update", "immersive_fpcamera", function(self, unit, t, dt)

	-- BASE VARS --
	
	local ply = self._parent_unit
	local mvmnt = ply:movement()
	local curr_state = mvmnt:current_state()
	local cam = ply:camera()
	local equipped = ply:inventory():equipped_unit()

	if not equipped then return end

	local wep = equipped:base()
	local wep_id = wep:get_name_id()

	local insight_mul = curr_state:in_steelsight() and .25 or 1

	local input_axis = ply:base():controller():get_input_axis("move")

	local deltaTime = dt

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- SETTING UP STANCES + MELEE POS FIX --

	mvector3.set(self._vel_overshot.translation, Vector3())
	mvector3.set(self._vel_overshot.rotation, Rotation())

	local stance_name = "standard"
	if curr_state:_is_using_bipod() then
		stance_name = "bipod"
	elseif curr_state:in_steelsight() then
		stance_name = "steelsight"
	elseif curr_state:ducking() then
		stance_name = "crouched"
	end
	
	if (wep_id == "saw_secondary") then
    wep_id = "saw"
    end
	
	if (wep_id == "type54_underbarrel") then
	wep_id = "type54"
	end
	
	if (wep_id == "type54_underbarrel") then
	wep_id = "type54"
	end
	
	if (wep_id == "x_type54_underbarrel") then
	wep_id = "x_type54"
	end
		
	if (wep_id == "groza_underbarrel") then
	wep_id = "groza"
	end
		
	if (wep_id == "contraband_m203") then
	wep_id = "contraband"
	end
	
	if (wep_id == "kacchainsaw_flamethrower") then
	wep_id = "kacchainsaw"
	
	
	end
	
	local stances = tweak_data.player.stances[wep_id]
	local wep_stance = stances[stance_name].shoulders

	local lp_st_spd = deltaTime * (stance_name == "steelsight" and 8 or 4)

	stance_pos = stance_pos or Vector3()
	if curr_state:_is_meleeing() or curr_state:_is_throwing_projectile() then
		mvector3.lerp(stance_pos, stance_pos, Vector3(wep_stance.translation.x, 2, wep_stance.translation.z), lp_st_spd)
	else
		mvector3.lerp(stance_pos, stance_pos, wep_stance.translation, lp_st_spd)
	end

	
	mvector3.lerp(stance_pos, stance_pos, wep_stance.translation, lp_st_spd)

	stance_ang = stance_ang or Rotation()
	mrotation.slerp(stance_ang, stance_ang, wep_stance.rotation, lp_st_spd)

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- PERMIT STANCE CHANGE --

	local lp_st_mod_spd = deltaTime * 30

	local stance_mod = fp_stance_mod or wep:stance_mod()

	stance_mod_pos = stance_mod_pos or Vector3()
	mvector3.lerp(stance_mod_pos, stance_mod_pos, curr_state:in_steelsight() and stance_mod.translation or Vector3(), lp_st_mod_spd)
	
	stance_mod_ang = stance_mod_ang or Rotation()
	mrotation.slerp(stance_mod_ang, stance_mod_ang, curr_state:in_steelsight() and stance_mod.rotation or Rotation(), lp_st_mod_spd)
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- STANCES MODS --
	
	local unit_rot = unit:rotation()
	last_unit_rot = last_unit_rot or Rotation()

	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- SWAY --

	local lp_sway_spd = deltaTime * 12

	local unit_rot_diff = Rotation(unit_rot:yaw() - last_unit_rot:yaw(), unit_rot:pitch() - last_unit_rot:pitch(), unit_rot:roll() - last_unit_rot:roll())
	unit_rot_diff_yaw = unit_rot_diff_yaw and math.clamp(unit_rot_diff:yaw(), -5, 5)  * insight_mul * .35 or 0
	unit_rot_diff_pitch = unit_rot_diff_pitch and math.clamp(unit_rot_diff:pitch(), -5, 5) * insight_mul * .35 or 0

    sway_yaw = sway_yaw or 0
	invert_sway_yaw = invert_sway_yaw and math.lerp(invert_sway_yaw, sway_yaw, lp_sway_spd) or 0
    sway_yaw = math.lerp(sway_yaw, unit_rot_diff_yaw + (sway_yaw - invert_sway_yaw), lp_sway_spd)

	sway_pitch = sway_pitch or 0
	invert_sway_pitch = invert_sway_pitch and math.lerp(invert_sway_pitch, sway_pitch, lp_sway_spd) or 0
    sway_pitch = math.lerp(sway_pitch, unit_rot_diff_pitch + (sway_pitch - invert_sway_pitch), lp_sway_spd)

	last_unit_rot = unit_rot

	sway_pos = sway_pos or Vector3()
	mvector3.lerp(sway_pos, sway_pos, Vector3(sway_yaw / 2, -sway_yaw / 2, -sway_pitch / 4), lp_sway_spd)

	sway_ang = sway_ang or Rotation()
	mrotation.slerp(sway_ang, sway_ang, Rotation(sway_yaw * 2, sway_pitch * 2, 0), lp_sway_spd)
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- LOOK UP AND DOWN --

	local updown_pos = Vector3(0, 0, curr_state:in_steelsight() and 0 or -unit_rot:pitch() / 32)

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- JUMP --

	local lp_jump_spd = deltaTime * 24
	local jump_vel = math.clamp(ply:velocity().z / 200, -5, 5)

	jump_wobble = jump_wobble or 0
	invert_jump_wobble = invert_jump_wobble and math.lerp(invert_jump_wobble, jump_wobble, lp_jump_spd / 2) or 0
    jump_wobble = math.lerp(jump_wobble, jump_vel + (jump_wobble - invert_jump_wobble), lp_jump_spd / 2)

	jump_pos = jump_pos or Vector3()
	mvector3.lerp(jump_pos, jump_pos, Vector3(0, 0, -jump_wobble * insight_mul - .1), lp_jump_spd)

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- HEADBOB --

	local lp_headbob_spd = deltaTime * 4

	local ply_in_walk = mvmnt:in_air() == false and mvector3.length(input_axis) ~= 0
	local ply_max_spd = 0
	if not mvmnt:in_air() and (mvmnt:current_state_name() ~= "jerry1" and mvmnt:current_state_name() ~= "jerry2" and mvmnt:current_state_name() ~= "player_turret") and (stance_name == "standard") then
	ply_max_spd = curr_state:_get_max_walk_speed(t) / 500
	end
	local walk_frequency = ply_in_walk and ply_max_spd or 0
	local walk_amplitude = walk_frequency * ply_max_spd

	walk_phase = (walk_phase or 0) + (deltaTime * 540 * walk_frequency)
	if walk_phase >= 540 then
		walk_phase = walk_phase - 540
	end
	
	local headbob_sin = math.sin(walk_phase) * walk_amplitude * insight_mul
	local headbob_sin_2 = math.sin(walk_phase * 0) * walk_amplitude * insight_mul

	headbob_pos = headbob_pos or Vector3()
	mvector3.lerp(headbob_pos, headbob_pos, Vector3(-headbob_sin / 1.5, headbob_sin / 1.5, headbob_sin), lp_headbob_spd)

	headbob_ang = headbob_ang or Rotation()
	mrotation.slerp(headbob_ang, headbob_ang, Rotation(-headbob_sin / 0.5, -headbob_sin, headbob_sin), lp_headbob_spd)

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- WEAPON TILT --

	local lp_tilt_spd = deltaTime * 9
	local tilt_val = input_axis.x * insight_mul

	tilt_wobble = tilt_wobble or 0
	invert_tilt_wobble = invert_tilt_wobble and math.lerp(invert_tilt_wobble, tilt_wobble, lp_tilt_spd / 2.5) or 0
    tilt_wobble = math.lerp(tilt_wobble, tilt_val + (tilt_wobble - invert_tilt_wobble), lp_tilt_spd / 2.5)

	tilt_pos = tilt_pos or Vector3()
	mvector3.lerp(tilt_pos, tilt_pos, Vector3(stance_name == "steelsight" and (tilt_wobble / 10) or tilt_wobble, 0, tilt_wobble / 1), lp_tilt_spd)

	tilt_ang = tilt_ang or Rotation()
	mrotation.slerp(tilt_ang, tilt_ang, Rotation(0, 0, tilt_wobble * 5), lp_tilt_spd)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- INSIGHT OFFSET --

	local lp_offset_spd = deltaTime * 12

	offset_pos_lerp = offset_pos_lerp or Vector3() 
	offset_ang_lerp = offset_ang_lerp or Rotation()

	if not wep.akimbo then
		stance_name_dump = stance_name_dump or stance_name
		last_stance_name = last_stance_name or stance_name

		if stance_name_dump ~= stance_name then
			last_stance_name = stance_name_dump
			stance_name_dump = stance_name
		end

		local stance_pcsi = 1000
		local stance_progress = (last_stance_name == "steelsight" or stance_name == "steelsight") and (math.round(((stance_pos.x - stances[last_stance_name].shoulders.translation.x) / (stances[stance_name].shoulders.translation.x - stances[last_stance_name].shoulders.translation.x)) * stance_pcsi) / stance_pcsi) or 1
		local stance_offset = 1 - math.round(math.sin(90 * stance_progress) * stance_pcsi) / stance_pcsi

		local offset_pos = Vector3(-5.5 * stance_offset, -9 * stance_offset, -10.5 * stance_offset)
		local offset_ang = Rotation(-2.5 * stance_offset, 5.5 * stance_offset, -40 * stance_offset)

		mvector3.lerp(offset_pos_lerp, offset_pos_lerp, offset_pos, lp_offset_spd)
		mrotation.slerp(offset_ang_lerp, offset_ang_lerp, offset_ang, lp_offset_spd)
	else
		mvector3.lerp(offset_pos_lerp, offset_pos_lerp, Vector3(), lp_offset_spd)
		mrotation.slerp(offset_ang_lerp, offset_ang_lerp, Rotation(), lp_offset_spd)
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- WALL PUSH --

	local lp_wall_spd = deltaTime * 8
	wall_pos = wall_pos or Vector3()

	if equipped then
		local from = cam:position() + cam:forward()
		local to = cam:position() + cam:forward() * 100

		local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

		mvector3.lerp(wall_pos, wall_pos, ray and (-math.Y * (10 - ray.distance / 10)) or Vector3(), lp_wall_spd)
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- APPLY STANCES MODS --

	mvector3.set(self._shoulder_stance.translation, wall_pos + offset_pos_lerp + tilt_pos + headbob_pos + jump_pos + updown_pos + sway_pos + stance_pos + stance_mod_pos)
	mrotation.set_zero(self._shoulder_stance.rotation)
	mrotation.multiply(self._shoulder_stance.rotation, offset_ang_lerp * tilt_ang * headbob_ang * sway_ang * stance_ang * stance_mod_ang)

	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- SYNC FOV CHANGE WITH STANCE CHANGE SPEED --

	local lp_fov_spd = deltaTime * 18
	lerp_fov = lerp_fov and math.lerp(lerp_fov, curr_state:get_zoom_fov(stances[stance_name]), lp_fov_spd) or 0
	cam:set_FOV(lerp_fov)

end)
