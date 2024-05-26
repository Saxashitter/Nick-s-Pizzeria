fsmstates[ntopp_v2.enums.BREAKDANCE]['npeppino'] = {
	name = "Breakdance",
	enter = function(self,player)
		player.pvars.forcedstate = S_PEPPINO_BREAKDANCE1
		player.pvars.getjiggy = false
		player.pvars.time = TICRATE
		S_StartSound(player.mo, sfx_breda)
	end,
	playerthink = function(self,player)
		if not S_SoundPlaying(player.mo, sfx_brdam) and player.pvars.getjiggy then
			S_StartSound(player.mo, sfx_brdam)
		end
	
		--player.pflags = $|PF_JUMPSTASIS
		
		if player.pvars.getjiggy then
			player.mo.tics = min($, 1)
		end
		
		if player.pvars.time then
			player.pvars.time = $-1
		else
			if not player.pvars.getjiggy then
				player.pvars.getjiggy = true
			else
				player.pvars.forcedstate = (player.pvars.forcedstate == S_PEPPINO_BREAKDANCE1) 
				and S_PEPPINO_BREAKDANCE2 
				or S_PEPPINO_BREAKDANCE1
			end
			player.pvars.time = TICRATE-TICRATE/3
		end
	
		if not (player.cmd.buttons & BT_TOSSFLAG)
		or not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
	end,
	exit = function(self,player)
		S_StopSoundByID(player.mo, sfx_brdam)
	end
}