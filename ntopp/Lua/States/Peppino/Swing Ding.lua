fsmstates[ntopp_v2.enums.SWINGDING]['npeppino'] = {
	name = "Swing Ding",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_SWINGDING
		player.pvars.drawangle = player.drawangle // used so we can force a angle during skidding :DD
		player.pvars.thrustangle = player.drawangle
		player.pvars.pressed = nil
		player.pvars.killed = nil
		player.pvars.killtime = 10
		local mo = player.pvars.ntoppv2_grabbed
		if mo.type ~= MT_PLAYER then
			mo.setz = player.mo.height/2
		elseif mo.player.ntoppv2_plyrgrab then
			mo.player.ntoppv2_plyrgrab.z = player.mo.height/2
		end
	end,
	playerthink = function(self, player)
		if not (player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
		
		player.pflags = $|PF_JUMPSTASIS
		
		player.pvars.movespeed = max(0, $-(FU))
		if not player.pvars.killed then
			P_InstaThrust(player.mo, player.pvars.thrustangle, FixedMul(player.pvars.movespeed, player.mo.scale))
			player.pvars.drawangle = $ + (ANG1*30)
		end
		player.drawangle = player.pvars.drawangle
		local mo = player.pvars.ntoppv2_grabbed
		if mo.type ~= MT_PLAYER then
			player.pvars.ntoppv2_grabbed.setx = 32*cos(player.drawangle)
			player.pvars.ntoppv2_grabbed.sety = 32*sin(player.drawangle)
		elseif mo.player.ntoppv2_plyrgrab then
			mo.player.ntoppv2_plyrgrab.x = 32*cos(player.drawangle)
			mo.player.ntoppv2_plyrgrab.y = 32*sin(player.drawangle)
		end

		if player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1) then
			player.pvars.pressed = true
		end

		if (player.pvars.movespeed <= 12*FU) then
			if (player.pvars.pressed) then
				if not player.pvars.killed then
					player.pvars.forcedstate = nil
					player.drawangle = player.mo.angle
					player.mo.state = S_PEPPINO_SWINGDINGEND
					if mo.type ~= MT_PLAYER then
						mo.setx = FixedMul(player.mo.radius, cos(player.drawangle))
						mo.sety = FixedMul(player.mo.radius, sin(player.drawangle))
						mo.flags = 0
						IncreaseSuperTauntCount(player)
						mo.killed = true
					elseif mo.player.ntoppv2_plyrgrab then
						mo.player.ntoppv2_plyrgrab.x = FixedMul(player.mo.radius, cos(player.drawangle))
						mo.player.ntoppv2_plyrgrab.y = FixedMul(player.mo.radius, sin(player.drawangle))
						mo.player.ntoppv2_plyrgrab = nil
					end
						
					P_InstaThrust(mo, player.drawangle, 30*FU)
					L_ZLaunch(mo, 8*FU)
					L_ZLaunch(player.mo, 6*FU)
					P_InstaThrust(player.mo, player.drawangle, -8*FU)
					
					player.pvars.killed = true
				end
				
				if player.mo.state ~= S_PEPPINO_SWINGDINGEND then
					fsm.ChangeState(player, ntopp_v2.enums.BASE)
				end
			else
				fsm.ChangeState(player, ntopp_v2.enums.BASE_GRABBEDENEMY)
			end
		end
	end,
	exit = function(self, player, state)
		player.pvars.movespeed = ntopp_v2.machs[1]
		player.pvars.drawangle = nil
	end
}