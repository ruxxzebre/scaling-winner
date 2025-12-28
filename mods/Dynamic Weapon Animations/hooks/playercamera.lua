
local disabled_shakers = {
    "player_land"
}

Hooks:OverrideFunction(PlayerCamera, "play_shaker", function(self, effect, amplitude, frequency, offset)
	if _G.IS_VR then
		return
	end

    for shaker_id, shaker_name in pairs(disabled_shakers) do
        if (effect == shaker_name) then
            return self._shaker:play("", 0, 0, 0)
        end
    end
    
	return self._shaker:play(effect, amplitude or 1, frequency or 1, offset or 0)
end)

Hooks:OverrideFunction(PlayerCamera, "set_shaker_parameter", function(self, effect, parameter, value)
	if not self._shakers then
		return
	end

    for shaker_id, shaker_name in pairs(disabled_shakers) do
        if (effect == shaker_name) then
            value = 0
        end
    end

	if self._shakers[effect] then
		self._shaker:set_parameter(self._shakers[effect], parameter, value)
	end
end)
