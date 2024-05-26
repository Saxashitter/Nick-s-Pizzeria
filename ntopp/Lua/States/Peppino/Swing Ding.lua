fsmstates[ntopp_v2.enums.SWINGDING]['npeppino'] = {
	name = "Swing Ding",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_SWINGDING
		player.pvars.drawangle = player.drawangle // used so we can force a angle during skidding :DD
		player.pvars.thrustangle = player.drawangle
		player.pvars.pressed = nil
		player.pvars.killed = nil
		player.pvars.killtime = 10
		player.pvars.ntoppv2_grabbed.setz = player.mo.height/2
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
			player.pvars.drawangle = $ + (ANG1*(player.speed/FU))
		end
		player.drawangle = player.pvars.drawangle
		player.pvars.ntoppv2_grabbed.setx = 32*cos(player.drawangle)
		player.pvars.ntoppv2_grabbed.sety = 32*sin(player.drawangle)

		if player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1) then
			player.pvars.pressed = true
		end

		if (player.pvars.movespeed <= 12*FU) then
			if (player.pvars.pressed) then
				if not player.pvars.killed then
					player.pvars.forcedstate = nil
					player.drawangle = player.mo.angle
					player.mo.state = S_PEPPINO_SWINGDINGEND
					player.pvars.ntoppv2_grabbed.setx = FixedMul(player.mo.radius, cos(player.drawangle))
					player.pvars.ntoppv2_grabbed.sety = FixedMul(player.mo.radius, sin(player.drawangle))
					P_InstaThrust(player.pvars.ntoppv2_grabbed, player.drawangle, 30*FU)
					L_ZLaunch(player.pvars.ntoppv2_grabbed, 8*FU)
					L_ZLaunch(player.mo, 6*FU)
					P_InstaThrust(player.mo, player.drawangle, -8*FU)
					player.pvars.ntoppv2_grabbed.killed = true
					
					IncreaseSuperTauntCount(player)
					player.pvars.ntoppv2_grabbed.flags = 0
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