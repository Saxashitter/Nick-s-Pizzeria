fsmstates[ntopp_v2.enums.TAUNT]['npeppino'] = {
	name = "Standard",
	enter = function(self, player, state)
		if (player.pvars) then
			player.pvars.forcedstate = nil
			player.pvars.landanim = false
			player.pvars.forcedstate = S_PEPPINO_TAUNT
			player.pvars.tauntframe = P_RandomRange(A, skins[player.mo.skin].sprites[SPR2_TAUN].numframes-1)
			player.mo.frame = player.pvars.tauntframe
			player.pvars.time = states[player.pvars.forcedstate].tics
			player.pvars.last_state = state
			
			player.pvars.savedmoms = {}
			player.pvars.savedmoms.x = player.mo.momx
			player.pvars.savedmoms.y = player.mo.momy
			player.pvars.savedmoms.z = player.mo.momz
			player.pvars.savedpflags = player.pflags & ~PF_FINISHED
			player.pvars.savedstate = player.mo.state
			S_StartSound(player.mo, sfx_taunt)
			
			local taunt = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_NTOPP_EFFECTFOLLOWPLAYER)
			taunt.fsmstate = ntopp_v2.enums.TAUNT
			taunt.target = player.mo
			taunt.state = S_NTOPPEFFECTS_TAUNTEFFECT
			taunt.dispoffset = -1
			taunt.offsetz = -18*FU
		end
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		player.mo.frame = player.pvars.tauntframe
		player.mo.momx = 0
		player.mo.momy = 0
		player.mo.momz = 0
		
		player.pflags = $|PF_FULLSTASIS
		
		if player.pvars.supertauntready and PT_FindPressed(player, "up", player.cmd.buttons) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
		
		if player.pvars.time then player.pvars.time = $-1
		else
			fsm.ChangeState(player, player.pvars.last_state)
		end
	end,
	exit = function(self, player)
		player.mo.momx = player.pvars.savedmoms.x
		player.mo.momy = player.pvars.savedmoms.y
		player.mo.momz = player.pvars.savedmoms.z
		player.pflags = $|player.pvars.savedpflags
		if player.playerstate == PST_DEAD
			player.mo.state = S_PLAY_DEAD
		else
			player.mo.state = player.pvars.savedstate
		end
		P_MovePlayer(player)
	end
}