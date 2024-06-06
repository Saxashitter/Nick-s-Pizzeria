fsmstates[ntopp_v2.enums.GRAB_KILLENEMY]['npeppino'] = {
	name = "Kill Enemy",
	enter = function(self, player, state)
		player.pvars.killtime = 10*2
		player.pvars.killed = false
		local mo = player.pvars.ntoppv2_grabbed
		if mo.type ~= MT_PLAYER then
			mo.setx = 32*cos(player.mo.angle)
			mo.sety = 32*sin(player.mo.angle)
			mo.setz = player.mo.height/2
		elseif mo.player.ntoppv2_plyrgrab then
			mo.player.ntoppv2_plyrgrab.x = 32*cos(player.mo.angle)
			mo.player.ntoppv2_plyrgrab.y = 32*sin(player.mo.angle)
			mo.player.ntoppv2_plyrgrab.z = player.mo.height/2
		end
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
		
		if (player.pvars.killtime <= 10 and not player.pvars.killed) then
			L_ZLaunch(player.mo, 6*player.jumpfactor)
			P_InstaThrust(player.mo, player.drawangle, -8*FU)
			
			local mo = player.pvars.ntoppv2_grabbed
			if player.pvars.forcedstate ~= S_PEPPINO_FINISHINGBLOWUP then
				mo.momx = 32*cos(player.mo.angle)
				mo.momy = 32*sin(player.mo.angle)
				mo.momz = 8*(FU*P_MobjFlip(player.mo))
			else
				mo.momx = 0*cos(player.mo.angle)
				mo.momy = 0*sin(player.mo.angle)
				mo.momz = 32*(FU*P_MobjFlip(player.mo))
			end
			
			if mo.type ~= MT_PLAYER then
				mo.killed = true
				player.pvars.ntoppv2_grabbed.flags = 0
			elseif mo.player.ntoppv2_plyrgrab then
				mo.player.ntoppv2_plyrgrab = nil
			end
			
			S_StartSound(player.pvars.ntoppv2_grabbed, sfx_kenem)
			player.pvars.killed = true
		end
	end,
	exit = function(self, player, state)
		player.pvars.ntoppv2_grabbed = nil
		player.pvars.killed = nil
	end
}