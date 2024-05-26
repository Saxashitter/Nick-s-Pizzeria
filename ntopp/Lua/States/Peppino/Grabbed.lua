fsmstates[ntopp_v2.enums.GRABBED]['npeppino'] = {
	name = "Grabbed",
	enter = function(self, player)
		P_InstaThrust(player.mo, player.drawangle, -16*FU)
		player.pvars.forcedstate = L_Choose(S_PEPPINO_KUNGFU_1, S_PEPPINO_KUNGFU_2, S_PEPPINO_KUNGFU_3)
		player.pvars.time = 20
	end,
	think = function(self, player)
		player.pflags = $|PF_FULLSTASIS
		
		if not (leveltime % 4) then TGTLSGhost(player) end
		
		if player.pvars.time then player.pvars.time = $-1 return end
		
		fsm.ChangeState(player, ntopp_v2.enums.BASE)
	end
}