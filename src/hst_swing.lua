local an, hst = ...

local swing_start_time = 0
local last_csaa_procced_hopo = false
local most_recent_swing_timestamp = 0
hst.impl_on_combat_event = function(self, event, ...)
	local timestamp, evt_t, _, _, caster_name, _, _, _, _, _, _, spell_id = CombatLogGetCurrentEventInfo()
	if(caster_name ~= UnitName("player")) then
		return
	end

	-- we only care about melee swing or csaa
	local care = (spell_id == 6603 or spell_id == 408385 or spell_id == 406834)
	if(not care) then
		return
	end
	--print(spell_id .. " - " .. select(1, GetSpellInfo(spell_id)))
	if(spell_id == 6603 or spell_id == 408385) then -- 6603 = auto attack, 408385 = csaa
		swing_start_time = GetTime()
		if(most_recent_swing_timestamp + 0.1 < timestamp) then
			print('swing detected')
			most_recent_swing_timestamp = timestamp
			last_csaa_procced_hopo = false
		end
	end
	if(spell_id == 406834) then-- csaa but with a hopo
		print('hopo generated')
		last_csaa_procced_hopo = true
	end
end

--[[
	Return the amount of time that has elapsed since the most recent swing.
	@note Returns 0 if no swing has yet taken place
	@author harrand
--]]
hst.get_swing_time = function()
	if swing_start_time > 0 then
		local current_time = GetTime()
		local swing_time = (current_time - swing_start_time)
		return swing_time
	end
	return 0
end


--[[
	Returns a normalised value (0.0 - 1.0) representing the progress of the current swing.
	@note Returns 0 if no swing has yet taken place
	@author harrand
--]]
hst.get_swing_progress = function()
	return hst.get_swing_time() / UnitAttackSpeed("player")
end

hst.csaa = {}
hst.csaa.get_will_next_swing_generate_hopo = function()
	-- todo: if csaa is changed to not proc every other hit, this needs to change.
	return not last_csaa_procced_hopo
end
