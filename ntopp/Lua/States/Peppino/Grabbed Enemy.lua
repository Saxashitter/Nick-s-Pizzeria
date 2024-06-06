fsmstates[ntopp_v2.enums.BASE_GRABBEDENEMY]['npeppino'] = {
	name = "Grabbed Enemy",
	enter = function(self, player)
		player.mo.momx = 0
		player.mo.momy = 0
		local mo = player.pvars.ntoppv2_grabbed
		if mo.type ~= MT_PLAYER then
			mo.setx = 0
			mo.sety = 0
			mo.setz = player.mo.height
		elseif mo.player.ntoppv2_plyrgrab then
			mo.player.ntoppv2_plyrgrab.x = 0
			mo.player.ntoppv2_plyrgrab.y = 0
			mo.player.ntoppv2_plyrgrab.z = player.mo.height
		end
			
		if (player.pvars) then
			player.pvars.forcedstate = S_PEPPINO_HAULINGIDLE
			player.pvars.landanim = false
			player.pvars.killtime = false
		end
	end,
	playerthink = function(self, player)
		if not (player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
		
		local spinpressed = (player.cmd.buttons & BT_SPIN) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_SPIN)
		local grabpressed = (player.cmd.buttons & BT_CUSTOM1) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1)
		
		if (spinpressed or grabpressed) then
			fsm.ChangeState(player, ntopp_v2.enums.GRAB_KILLENEMY)
		end
	end,
	think = function(self, player)
		if (not P_IsObjectOnGround(player.mo)) then
			if (player.pvars.forcedstate ~= S_PEPPINO_HAULINGFALL) then
				player.pvars.forcedstate = S_PEPPINO_HAULINGFALL
				if not (player.pvars.landanim) then
					player.pvars.landanim = true
				end
			end
		else
			local supposedstate = S_PEPPINO_HAULINGIDLE
			if (player.mo.momx ~= 0 or player.mo.momy ~= 0) then supposedstate = S_PEPPINO_HAULINGWALK end
			if (player.pvars.forcedstate ~= supposedstate) then
				player.pvars.forcedstate = supposedstate
			end
		end
		
		local spinpressed = (player.cmd.buttons & BT_SPIN) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_SPIN)
		local grabpressed = (player.cmd.buttons & BT_CUSTOM1) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1)
		
		if (player.cmd.buttons & BT_CUSTOM2 and not P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.PILEDRIVER)
		end
	end
}