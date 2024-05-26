fsmstates[ntopp_v2.enums.PAIN]['npeppino'] = {
	name = "Pain",
	enter = function(self, player, laststate)
		player.pvars.time = TICRATE+(TICRATE/2)
		player.pvars.forcedstate = S_PLAY_PAIN
		player.pvars.movespeed = ntopp_v2.machs[1]
		ntopp_v2.WhiteFlash(player)
	end,
	think = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		player.pflags = $|PF_FULLSTASIS
		if (not P_PlayerInPain(player) and player.playerstate == PST_LIVE)
		then 
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
		end
	end
}