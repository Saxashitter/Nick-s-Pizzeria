fsmstates[ntopp_v2.enums.BELLYSLIDE]['npeppino'] = {
	name = "Belly Slide",
	enter = function(self, player)
		player.ntoppjump = false
		player.pvars.forcedstate = S_PEPPINO_BELLYSLIDE
		player.pvars.drawangle = player.mo.angle
		player.pflags = $|PF_SPINNING
		player.pvars.slidetime = 20
		player.pvars.movespeed = ntopp_v2.machs[3]+(3*FU)
	end,
	playerthink = function(self, player)
		player.pflags = $|PF_FULLSTASIS|PF_SPINNING

		if (player.pvars.drawangle) then
			player.drawangle = player.pvars.drawangle
		end
		
		if not (leveltime % 4) then
			TGTLSGhost(player)
		end

		P_InstaThrust(player.mo, player.drawangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
		
		if (player.pvars.slidetime) then
			player.pvars.slidetime = $-1
		end
		
		if not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			return
		end
		
		if not (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) and not (player.pvars.slidetime) then
			fsm.ChangeState(player, GetMachSpeedEnum(player.pvars.movespeed))
		end
	end,
	think = function(self, player)
		if P_IsObjectOnGround(player.mo) and not (leveltime%2) then
			local p = player
			local me = p.mo //luigi budd is lazy
			
			local dist = -20
			local d1 = P_SpawnMobjFromMobj(me, dist*cos(p.drawangle + ANGLE_45), dist*sin(p.drawangle + ANGLE_45), 0, MT_LINEPARTICLE)
			local d2 = P_SpawnMobjFromMobj(me, dist*cos(p.drawangle - ANGLE_45), dist*sin(p.drawangle - ANGLE_45), 0, MT_LINEPARTICLE)
			
			d1.state = S_INVISIBLE
			d2.state = S_INVISIBLE
			
			d1.angle = p.drawangle
			d2.angle = p.drawangle
		end
	end,
	exit = function(self, player, state)
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
		player.pflags = $ & ~PF_SPINNING
		player.pvars.drawangle = nil
	end
}