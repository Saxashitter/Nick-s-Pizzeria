fsmstates[ntopp_v2.enums.GRAB]['npeppino'] = {
	name = "Grab",
	enter = function(self, player, state)
		if (player.pvars.movespeed < ntopp_v2.machs[3]-(10*FU)) then
			player.pvars.movespeed = ntopp_v2.machs[3]-(10*FU)
		end
		player.pvars.laststate = state
		
		player.pvars.drawangle = player.drawangle
		player.pvars.thrustangle = player.drawangle
		
		player.pvars.grabtime = 14*2
		player.pvars.groundedgrab = P_IsObjectOnGround(player.mo)
		player.pvars.wasgrounded = P_IsObjectOnGround(player.mo)
		
		player.pvars.forcedstate = (player.pvars.groundedgrab and S_PEPPINO_SUPLEXDASH)
		player.pvars.cancelledgrab = false
		
		S_StartSound(player.mo, sfx_pgrab)
	end,
	think = function(self, player)
		if player.powers[pw_carry]
		or player.powers[pw_nocontrol] return end
		
		if (not (player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid)) then
			player.pvars.thrustangle = player.drawangle
			
			local supposeddrawangle = player.pvars.drawangle
			if supposeddrawangle == nil then supposeddrawangle = player.pvars.thrustangle end
			
			local diff = supposeddrawangle - player.pvars.thrustangle
			local deaccelerating = (P_GetPlayerControlDirection(player) == 2)
			
			if diff >= 4*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle - 4*ANG1
			elseif diff <= -4*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle + 4*ANG1
			end
			
			player.pvars.drawangle = player.pvars.thrustangle
			P_InstaThrust(player.mo, player.pvars.thrustangle, FixedMul(player.pvars.movespeed, player.mo.scale))
			P_MovePlayer(player)
			
			if not (leveltime % 4) then
				TGTLSGhost(player)
			end
			
			if player.pvars.ntoppv2_grabbed and not player.pvars.ntoppv2_grabbed.valid then
				fsm.ChangeState(player, ntopp_v2.enums.BASE)
				player.pvars.ntoppv2_grabbed = nil
			end
			
			if not P_IsObjectOnGround(player.mo) and player.pvars.groundedgrab then
				player.pvars.groundedgrab = false
			end
			
			if (player.pvars.groundedgrab) then
				if (player.pvars.grabtime) then
					player.pvars.grabtime = $-1
					if (player.cmd.buttons & BT_CUSTOM2) then
						fsm.ChangeState(player, ntopp_v2.enums.ROLL)
						player.pvars.forcedstate = S_PEPPINO_BELLYSLIDE
						player.pvars.slidetime = 20
						player.pvars.movespeed = ntopp_v2.machs[3]+(3*FU)
						return
					end
				else
					if player.pvars.laststate == ntopp_v2.enums.BASE and player.cmd.buttons & BT_SPIN then
						player.pvars.laststate = GetMachSpeedEnum(player.pvars.movespeed)
					end
					fsm.ChangeState(player, player.pvars.laststate)
				end
			else
				if not (player.pvars.wasgrounded) then
					if player.pvars.forcedstate ~= S_PEPPINO_AIRSUPLEXDASH then
						player.pvars.forcedstate = S_PEPPINO_AIRSUPLEXDASH
					end
					
					if P_IsObjectOnGround(player.mo) then
						if (player.cmd.buttons & BT_CUSTOM2) then
							fsm.ChangeState(player, ntopp_v2.enums.ROLL)
							player.pvars.forcedstate = S_PEPPINO_BELLYSLIDE
							player.pvars.slidetime = 20
							player.pvars.movespeed = ntopp_v2.machs[3]+(3*FU)
							return
						end
						local statechange = ntopp_v2.enums.BASE
						if player.cmd.buttons & BT_SPIN then
							statechange = GetMachSpeedEnum(player.pvars.movespeed)
						end
						fsm.ChangeState(player, statechange)
					end
				else
					if player.pflags & PF_JUMPED then
						fsm.ChangeState(player, ntopp_v2.enums.MACH2)
						player.pvars.forcedstate = S_PEPPINO_LONGJUMP
					else
						player.pvars.wasgrounded = false
					end
				end
			end
		else
			local state = (not (player.cmd.buttons & BT_CUSTOM3)) and ntopp_v2.enums.BASE_GRABBEDENEMY or ntopp_v2.enums.PILEDRIVER
			if state == ntopp_v2.enums.BASE_GRABBEDENEMY
			and (player.pvars.laststate == ntopp_v2.enums.MACH2
				or player.pvars.laststate == ntopp_v2.enums.MACH3
			) then
				state = ntopp_v2.enums.SWINGDING
			end
			if (state ~= ntopp_v2.enums.SWINGDING) then
				player.pvars.cancelledgrab = true
			end
			fsm.ChangeState(player, state)
		end
	end,
	exit = function(self, player, state)
		if (player.pvars.cancelledgrab) then
			player.pvars.movespeed = 8*FU
			player.mo.momx = 0
			player.mo.momy = 0
		end
		player.pvars.cancelledgrab = nil
	end
}