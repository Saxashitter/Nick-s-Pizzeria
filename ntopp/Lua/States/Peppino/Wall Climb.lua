local function NerfAbility(player)
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
		and (gametyperules & GTR_RACE 
		or ((G_RingSlingerGametype() 
			and gametype ~= GT_CTF) 
		or (gametype == GT_CTF 
			and player.gotflag))))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.WALLCLIMB]['npeppino'] = {
	name = "Wall Climb",
	enter = function(self, player, state)
		player.pvars.forcedstate = S_PEPPINO_WALLCLIMB
		player.pvars.wallruntime = (state == ntopp_v2.enums.GRAB) and 12 or 0
		if state == ntopp_v2.enums.GRAB and not NerfAbility(player) then player.pvars.movespeed = 8*FU end
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		player.pflags = $|PF_STASIS
		local atwall = WallCheckHelper(player)
		if not atwall then
			fsm.ChangeState(player, GetMachSpeedEnum(player.pvars.movespeed))
			player.mo.momz = 0
			return
		end
		
		if not (NerfAbility(player)) then
			if player.pvars.movespeed < ntopp_v2.machs[4] then
				player.pvars.movespeed = $+(FU/2)
			else
				player.pvars.movespeed = $+FU
			end
		else
			player.pvars.movespeed = max(6*FU, $-(FU-(FU/3)))
		end
		player.mo.momx = 0
		player.mo.momy = 0
		if player.mo.momz*P_MobjFlip(player.mo) >= 10*FU then
			player.mo.tics = min($,1)
		end
		
		L_ZLaunch(player.mo, player.pvars.movespeed/2)
		P_MovePlayer(player)
		
		if (player.cmd.buttons & BT_JUMP and not (player.prevkeys and player.prevkeys & BT_JUMP)) then
			L_ZLaunch(player.mo, 8*player.jumpfactor)
			player.pflags = $|PF_JUMPED|PF_STARTJUMP
			
			player.drawangle = $+ANGLE_180
			player.mo.angle = player.drawangle
			
			player.pvars.savedline = nil
			player.pvars.mobjblocked = nil
			
			P_InstaThrust(player.mo, player.drawangle, FixedMul(22*FU, player.mo.scale))
			player.pvars.movespeed = 22*FU
			
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_PEPPINO_WALLJUMP
			return
		end

	end,
	think = function(self, player)
		local height = player.mo.eflags & MFE_VERTICALFLIP and player.mo.floorz or player.mo.ceilingz
		if player.mo.z+player.mo.height == height then fsm.ChangeState(player, ntopp_v2.enums.STUN) return end
		
		if player.pvars.wallruntime then player.pvars.wallruntime = $-1 return end
		
		if (not (player.cmd.buttons & BT_SPIN)) then
			player.ntoppjump = true
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
	end,
	exit = function(self, player, state)
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
	end
}