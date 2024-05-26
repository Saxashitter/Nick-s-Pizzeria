local function canPVP(pmo, pmo2)
	if not PTV3:isPTV3() then return 0 end
	if pmo2.player.powers[pw_flashing]
	or pmo2.player.powers[pw_invulnerability]
	or P_PlayerInPain(pmo2.player) then
		return 0
	end
	
	if (pmo.player.ptv3
	and pmo.player.ptv3.swapModeFollower)
	or (pmo2.player.ptv3
	and pmo2.player.ptv3.swapModeFollower) then
		return 0
	end
	
	
	-- Return values:
	-- 0 = None
	-- 1 = Normal pain animation
	-- 2 = Sent flying forwards
	-- 3 = Sent upwards

	if pmo.player.pflags & PF_JUMPED then
		if pmo.player.speed > 30*FU then
			return 2
		end
		return 1
	end
	if pmo.player.pflags & PF_SPINNING then
		return 3
	end

	return 0
end

local function hurtPlayer(pmo, mo2, value)
	if value == 1 then
		mo2.player.drawangle = R_PointToAngle2(mo2.x, mo2.y, pmo.x, pmo.y)
		P_DoPlayerPain(mo2.player)
	elseif value == 2 then
		mo2.player.drawangle = R_PointToAngle2(mo2.x, mo2.y, pmo.x, pmo.y)+ANGLE_180
		P_InstaThrust(mo2, mo2.player.drawangle, pmo.player.speed)
		mo2.momz = $+((2*FU)*P_MobjFlip(mo2))
		mo2.player.pflags = $|PF_JUMPED & ~(PF_SPINNING|PF_THOKKED)
		mo2.state = S_PLAY_JUMP
	elseif value == 3 then
		mo2.player.drawangle = R_PointToAngle2(mo2.x, mo2.y, pmo.x, pmo.y)+ANGLE_180
		P_InstaThrust(mo2, mo2.player.drawangle, pmo.player.speed)
		mo2.momz = $+((16*FU)*P_MobjFlip(mo2))
		mo2.player.pflags = $|PF_JUMPED & ~(PF_SPINNING|PF_THOKKED)
		mo2.state = S_PLAY_JUMP
	end
end

local function choose(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end

addHook('MobjMoveCollide', function(pmo, mo2)
	if mo2.type ~= MT_PLAYER then return end
	if pmo.z > mo2.z+mo2.height then return end
	if mo2.z > pmo.z+pmo.height then return end

	local value = canPVP(pmo, mo2)
	local value_2 = canPVP(mo2, pmo)
	if value and value_2 then
		local p = choose(pmo, mo2)
		local p2 = (p == pmo) and mo2 or pmo
		local val = (p == pmo) and value or value_2

		hurtPlayer(p, p2, val)
	elseif value then
		hurtPlayer(pmo, mo2, value)
	end
end, MT_PLAYER)