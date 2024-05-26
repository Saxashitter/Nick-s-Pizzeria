fsmstates[ntopp_v2.enums.GRAB_KILLENEMY]['npeppino'] = {
	name = "Kill Enemy",
	enter = function(self, player, state)
		player.pvars.killtime = 10*2
		player.pvars.killed = false
		player.pvars.forcedstate = L_Choose(S_PEPPINO_FINISHINGBLOW1, S_PEPPINO_FINISHINGBLOW2, S_PEPPINO_FINISHINGBLOW3, S_PEPPINO_FINISHINGBLOW4, S_PEPPINO_FINISHINGBLOW5)
	end,
	playerthink = function(self, player)
		if not (player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
		if (player.pvars.killtime) then
			player.pvars.killtime = $-1
		else
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
		
		player.drawangle = player.mo.angle
		player.pflags = $|PF_FULLSTASIS
		
		if (player.pvars.killtime <= 10 and player.pvars.ntoppv2_grabbed) then
			L_ZLaunch(player.mo, 6*player.jumpfactor)
			P_InstaThrust(player.mo, player.drawangle, -8*FU)
			player.pvars.ntoppv2_grabbed.ntoppv2_deathcollide = player.mo
			
			player.pvars.ntoppv2_grabbed.momx = 32*cos(player.mo.angle)
			player.pvars.ntoppv2_grabbed.momy = 32*sin(player.mo.angle)
			player.pvars.ntoppv2_grabbed.momz = 8*(FU*P_MobjFlip(player.mo))
			
			player.pvars.ntoppv2_grabbed.ntoppv2_grabbed = nil
			player.pvars.ntoppv2_grabbed = nil
			S_StartSound(player.pvars.grabbedenemy, sfx_kenem)
		end
	end,
	exit = function(self, player, state)
		player.pvars.killed = nil
	end
}