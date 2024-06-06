
-- yes i am reusing already existing enums

fsmstates[ntopp_v2.enums.GRAB]["ngustavo"] = {
	name = "Spin Move thing i dont know does nick even use this name thing",
	-- no i dont it was used originally for the tv lol
	enter = function(self, player, state)
		if (player.pvars.movespeed < ntopp_v2.machs[3]-(10*FU)) then
			player.pvars.movespeed = ntopp_v2.machs[3]-(10*FU)
		end
		player.ntoppv2_hasbrick = false
		player.pvars.forcedstate = S_PEPPINO_ROLL
		player.pvars.laststate = state
		
		player.pvars.drawangle = player.drawangle
		player.pvars.thrustangle = player.drawangle
		
		player.pvars.grabtime = 25 -- equivalent to ratmountpunchtimer
		player.pvars.gustavohitwall = false
		/*player.pvars.groundedgrab = P_IsObjectOnGround(player.mo)
		player.pvars.wasgrounded = P_IsObjectOnGround(player.mo)
		
		player.pvars.forcedstate = (player.pvars.groundedgrab and S_PEPPINO_SUPLEXDASH)
		player.pvars.cancelledgrab = false*/
		
		S_StartSound(player.mo, sfx_pgrab)
	end,
	think = function(self, player)
		local p = player
		local pv = p.pvars
		if P_IsObjectOnGround(p.mo)
			pv.movespeed = PT_Approach($, (p.mo.scale * 4), FixedDiv(1, 10))
		end
		
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		
		p.powers[pw_strong] = $1|STR_ATTACK|STR_WALL|STR_ANIM
		P_InstaThrust(p.mo, pv.thrustangle, pv.movespeed)
		pv.grabtime = $-1
		if (pv.grabtime < 0 and (not (p.cmd.buttons & BT_CUSTOM1) or pv.gustavohitwall))
			--sprite_index = spr_lonegustavo_walk
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			if (p.speed != 0)
				p.drawangle = pv.thrustangle
			end
			return
		end
	end,
	exit = function(self, player, state)
		local p = player
		player.pvars.forcedstate = nil
		player.mo.state = S_PLAY_WALK
		p.powers[pw_strong] = 0
		/*if (player.pvars.cancelledgrab) then
			print("hi")
			player.pvars.movespeed = 8*FU
			player.mo.momx = 0
			player.mo.momy = 0
		end
		player.pvars.cancelledgrab = nil*/
	end
}

addHook("MobjMoveBlocked", function(pmo)
	local p = pmo.player
	
	if not pmo
	or pmo.skin ~= "ngustavo"
	or not p.fsm
	or not p.pvars
	or p.fsm.state ~= ntopp_v2.enums.GRAB return end -- i love copying code
	
	local pv = p.pvars
	S_StartSound(pmo, sfx_mabmp)
	pv.grabtime = 10
	pv.gustavohitwall = true
	pv.thrustangle = $+ANGLE_180
	--pv.thrustangle = R_PointToAngle2(0, 0, pmo.x, pmo.y)
	pv.movespeed = FixedDiv($, FU+FU/2)
end, MT_PLAYER)