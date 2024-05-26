fsmstates[ntopp_v2.enums.DIVE]['npeppino'] = {
	name = "Dive",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_DIVE
		player.pvars.drawangle = player.drawangle
		player.charflags = $ & ~SF_RUNONWATER -- no bugging out on water anymore bud!!!!
		if player.mo.momz > -16*skins[player.mo.skin].jumpfactor then
			L_ZLaunch(player.mo, -16*skins[player.mo.skin].jumpfactor)
		end
	end,
	playerthink = function(self, player)
		if (player.pvars.slidetime) then
			player.pvars.slidetime = $-1
		end
		
		player.drawangle = player.pvars.drawangle
		if not (leveltime % 4) then
			TGTLSGhost(player)
		end
		P_InstaThrust(player.mo, player.drawangle, player.pvars.movespeed)
		P_MovePlayer(player)
		if not (player.gotflag) and ((player.cmd.buttons & BT_JUMP) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_JUMP)) and not P_IsObjectOnGround(player.mo)
			player.pflags = $ & ~PF_FULLSTASIS
			fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
			player.pvars.forcedstate = S_PEPPINO_DIVEBOMB
			return
		end
	end,
	think = function(self, player)
		if P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.ROLL)
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