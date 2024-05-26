fsmstates[ntopp_v2.enums.ROLL]['npeppino'] = {
	name = "Roll",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_ROLL
		player.pvars.drawangle = player.drawangle
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		player.pflags = $|PF_SPINNING|PF_JUMPSTASIS
		
		if (player.pvars.slidetime) then
			player.pvars.slidetime = $-1
		end
		
		player.drawangle = player.pvars.drawangle
		
		if not (leveltime % 4) then
			TGTLSGhost(player)
		end
		P_InstaThrust(player.mo, player.drawangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
	end,
	think = function(self, player)
		local p = player
		local ch = (p.mo.eflags & MFE_VERTICALFLIP) and p.mo.floorz or p.mo.ceilingz
		local spingap = false
		if p.mo.z+skins[p.mo.skin].height > ch
			spingap = true
		end
		
		if not (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) and not (player.pvars.slidetime) and not spingap then
			fsm.ChangeState(player, GetMachSpeedEnum(player.pvars.movespeed))
			return
		end
		if not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			return
		end
	end,
	exit = function(self, player, state)
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = ntopp_v2.machs[1]
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
		player.pflags = $ & ~PF_SPINNING
		player.pvars.drawangle = nil
	end
}