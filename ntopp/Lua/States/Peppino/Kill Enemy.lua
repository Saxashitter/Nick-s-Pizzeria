fsmstates[ntopp_v2.enums.GRAB_KILLENEMY]['npeppino'] = {
	name = "Kill Enemy",
	enter = function(self, player, state)
		player.pvars.killtime = 10*2
		player.pvars.killed = false
		player.pvars.ntoppv2_grabbed.setx = 32*cos(player.mo.angle)
		player.pvars.ntoppv2_grabbed.sety = 32*sin(player.mo.angle)
		player.pvars.ntoppv2_grabbed.setz = player.mo.height/2
		player.pvars.forcedstate = L_Choose(S_PEPPINO_FINISHINGBLOW1, S_PEPPINO_FINISHINGBLOW2, S_PEPPINO_FINISHINGBLOW3, S_PEPPINO_FINISHINGBLOW4, S_PEPPINO_FINISHINGBLOW5)
		if player.cmd.buttons & BT_CUSTOM3 then
			player.pvars.forcedstate = S_PEPPINO_FINISHINGBLOWUP
		end
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
		
		if (player.pvars.killtime <= 10 and not player.pvars.ntoppv2_grabbed.killed) then
			L_ZLaunch(player.mo, 6*player.jumpfactor)
			P_InstaThrust(player.mo, player.drawangle, -8*FU)
	
			if player.pvars.forcedstate ~= S_PEPPINO_FINISHINGBLOWUP then
				player.pvars.ntoppv2_grabbed.momx = 32*cos(player.mo.angle)
				player.pvars.ntoppv2_grabbed.momy = 32*sin(player.mo.angle)
				player.pvars.ntoppv2_grabbed.momz = 8*(FU*P_MobjFlip(player.mo))
			else
				player.pvars.ntoppv2_grabbed.momx = 0*cos(player.mo.angle)
				player.pvars.ntoppv2_grabbed.momy = 0*sin(player.mo.angle)
				player.pvars.ntoppv2_grabbed.momz = 32*(FU*P_MobjFlip(player.mo))
			end
			player.pvars.ntoppv2_grabbed.killed = true
			
			player.pvars.ntoppv2_grabbed.flags = 0
			S_StartSound(player.pvars.ntoppv2_grabbed, sfx_kenem)
		end
	end,
	exit = function(self, player, state)
		player.pvars.ntoppv2_grabbed = nil
		player.pvars.killed = nil
	end
}