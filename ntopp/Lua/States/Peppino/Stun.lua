fsmstates[ntopp_v2.enums.STUN]['npeppino'] = {
	name = "Stun",
	enter = function(self, player, state)
		player.pvars.forcedstate = S_PEPPINO_MACH2STUN
		
		if state == ntopp_v2.enums.MACH3 then
			player.pvars.forcedstate = S_PEPPINO_MACH3STUN
			S_StartSound(player.mo, sfx_grpo)
			P_InstaThrust(player.mo, player.drawangle, -8*FU)
			player.mo.momz = 4*FU
		elseif state == ntopp_v2.enums.SUPERJUMP
		or state == ntopp_v2.enums.WALLCLIMB then
			player.pvars.forcedstate = S_PEPPINO_UPSTUN
			S_StartSound(player.mo, sfx_grpo)
		else
			S_StartSound(player.mo, sfx_mabmp)
		end
		
		player.pvars.movespeed = ntopp_v2.machs[1]
		player.pvars.time = states[player.pvars.forcedstate].tics
		player.pepbonkframe = A
	end,
	playerthink = function(self, player)
		if player.pvars.forcedstate ~= S_PEPPINO_MACH3STUN then
			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
		end
		if player.mo.state == S_PEPPINO_MACH3STUN then
			if player.mo.frame > player.pepbonkframe then
				player.pepbonkframe = player.mo.frame
			elseif player.mo.frame < player.pepbonkframe then
				player.mo.frame = player.pepbonkframe
			end
		end
		player.pflags = $|PF_FULLSTASIS
		if player.pvars.time then player.pvars.time = $-1 return end
		
		player.pvars.movespeed = 8*FU
		fsm.ChangeState(player, ntopp_v2.enums.BASE)
	end
}

addHook('MobjMoveBlocked', function(mo, mobj, line)
	local player = mo.player
	if not NTOPP_Check(player) then return end
	
	if not line then return end
	
	if player.fsm.state ~= ntopp_v2.enums.MACH1 
	and player.fsm.state ~= ntopp_v2.enums.MACH2 
	and player.fsm.state ~= ntopp_v2.enums.MACH3
	and (player.fsm.state ~= ntopp_v2.enums.GRAB or player.mo.skin == "ngustavo")
	and player.fsm.state ~= ntopp_v2.enums.LONGJUMP
	and player.fsm.state ~= ntopp_v2.enums.DIVE
	and player.fsm.state ~= ntopp_v2.enums.SKID
	and player.fsm.state ~= ntopp_v2.enums.ROLL
	then return end
	
	if player.mo.skin == "nthe_noise" and player.fsm.state == ntopp_v2.enums.DIVE then
		return
	end
	
	if (not P_IsObjectOnGround(mo) and not (player.fsm.state == ntopp_v2.enums.DIVE or player.fsm.state == ntopp_v2.enums.SKID))
	or (P_IsObjectOnGround(mo) and player.mo.standingslope and not (line and line.flags & ML_NOCLIMB)) 
	then return end
	
	local linex,liney = P_ClosestPointOnLine(player.mo.x,player.mo.y,line)
	local lineangle = R_PointToAngle2(player.mo.x,player.mo.y,linex,liney)
	local diff = player.mo.angle - lineangle
	
	if diff <= ANG1*35 and diff >= -ANG1*35 then
		fsm.ChangeState(player, ntopp_v2.enums.STUN)
	end
end, MT_PLAYER)