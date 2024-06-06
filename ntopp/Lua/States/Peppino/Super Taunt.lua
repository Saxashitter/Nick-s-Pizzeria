fsmstates[ntopp_v2.enums.SUPERTAUNT]['npeppino'] = {
	name = "Super Taunt",
	enter = function(self, player, state)
		if (player.pvars) then
			player.pvars.forcedstate = nil
			player.pvars.landanim = false
			if player.mo.skin ~= "ngustavo"
				player.pvars.forcedstate = L_Choose(S_PEPPINO_SUPERTAUNT1, S_PEPPINO_SUPERTAUNT2, S_PEPPINO_SUPERTAUNT3, S_PEPPINO_SUPERTAUNT4)
			else
				player.pvars.forcedstate = S_PEPPINO_SUPERTAUNT1
			end
			player.pvars.time = states[player.pvars.forcedstate].tics
			
			player.pvars.savedmoms = {}
			player.pvars.savedmoms.x = player.mo.momx
			player.pvars.savedmoms.y = player.mo.momy
			player.pvars.savedmoms.z = player.mo.momz
			player.pvars.savedpflags = player.pflags & ~PF_FINISHED
			player.pvars.savedstate = player.mo.state
			if state ~= ntopp_v2.enums.TAUNT then
				player.pvars.last_state = state
			end
			S_StartSound(player.mo, sfx_staunt)
		end
		P_Earthquake(player.mo, player.mo,1500*FU)
	end,
	playerthink = function(self, player)
		player.mo.momx = 0
		player.mo.momy = 0
		player.mo.momz = 0
		player.pflags = $|PF_FULLSTASIS
		
		if player.pvars.time then player.pvars.time = $-1 end
		if not player.pvars.time then
			fsm.ChangeState(player, player.pvars.last_state)
		end
	end,
	exit = function(self, player)
		player.mo.momx = player.pvars.savedmoms.x
		player.mo.momy = player.pvars.savedmoms.y
		player.mo.momz = player.pvars.savedmoms.z
		player.pflags = $|player.pvars.savedpflags
		player.mo.state = player.pvars.savedstate
		player.pvars.supertauntcount = 0
		player.pvars.supertauntready = false
		P_MovePlayer(player)
	end
}