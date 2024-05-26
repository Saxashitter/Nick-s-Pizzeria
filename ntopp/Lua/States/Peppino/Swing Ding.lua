fsmstates[ntopp_v2.enums.SWINGDING]['npeppino'] = {
	name = "Swing Ding",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_SWINGDING
		player.pvars.drawangle = player.drawangle // used so we can force a angle during skidding :DD
		player.pvars.thrustangle = player.drawangle
		player.pvars.pressed = nil
		player.pvars.killed = nil
		player.pvars.killtime = 10
	end,
	playerthink = function(self, player)
		if not (player.pvars.grabbedenemy and player.pvars.grabbedenemy.valid) then
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
		
		if (player.pvars.grabbedenemy.type == MT_PLAYER) then
			local x = player.mo.x + (32*cos(player.drawangle))
			local y = player.mo.y + (32*sin(player.drawangle))
			P_MoveOrigin(player.pvars.grabbedenemy, x, y, player.mo.z+player.mo.height)
			player.pvars.grabbedenemy.momx = 0
			player.pvars.grabbedenemy.momy = 0
			player.pvars.grabbedenemy.momz = 0
			player.pvars.grabbedenemy.player.pflags = $|PF_FULLSTASIS
			player.pvars.grabbedenemy.player.powers[pw_carry] = CR_PLAYER
			player.pvars.grabbedenemy.state = S_PLAY_PAIN
		end
		

		if player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1) then
			player.pvars.pressed = true
		end

		if (player.pvars.movespeed <= 12*FU) then
			if (player.pvars.pressed) then
				if not player.pvars.killed then
					player.pvars.forcedstate = nil
					player.mo.state = S_PEPPINO_SWINGDINGEND
					L_ZLaunch(player.mo, 6*FU)
					P_InstaThrust(player.mo, player.drawangle, -8*FU)
					if player.pvars.grabbedenemy.type ~= MT_PLAYER then
						player.pvars.grabbedenemy.killed = true
						P_AddPlayerScore(player, 100)
						IncreaseSuperTauntCount(player)
						player.pvars.grabbedenemy.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY
					else
						P_InstaThrust(player.pvars.grabbedenemy, player.mo.angle, 64*FU)
						player.pvars.grabbedenemy.momz = (3*FU)*P_MobjFlip(player.pvars.grabbedenemy)
						IncreaseSuperTauntCount(player)
						player.pvars.grabbedenemy.player.powers[pw_carry] = 0
						player.pvars.grabbedenemy.player.grabbed = false
					end
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