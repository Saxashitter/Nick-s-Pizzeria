local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.MACH2]['npeppino'] = {
	name = "Mach 2",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_MACH2
		player.pvars.breakdance = false
		player.pvars.drawangle = player.drawangle
		player.pvars.thrustangle = player.drawangle
		player.charflags = $|SF_RUNONWATER
		player.runspeed = 50*FU
		player.ntoppv2_machtime = 0
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars or player.playerstate == PST_DEAD) then
			player.pvars = Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		if player.mo.z >= player.mo.watertop
			player.charflags = $1|SF_RUNONWATER
		else
			player.charflags = $ & ~SF_RUNONWATER
		end
		
		if P_IsObjectOnGround(player.mo) then
			player.pvars.thrustangle = player.drawangle
		end
		
		if player.mo.skin == "nthe_noise" and PT_FindPressed(player, "up", player.cmd.buttons) then
			player.pflags = $|PF_JUMPSTASIS
		end
		
		local thrust,angle = PT_ButteredSlope(player.mo)
		
		if (P_IsObjectOnGround(player.mo)) then
			local add = player.powers[pw_sneakers] and FU or 0
			add = $ + (angle ~= nil and angle > 0 and angle <= 32*ANG1 and FU or 0)
			player.pvars.movespeed = $+(FU-(FU/4))+add
			if (not player.pvars.forcedstate or (player.pvars.forcedstate == S_PEPPINO_WALLJUMP or player.pvars.forcedstate == S_PEPPINO_BREAKDANCELAUNCH or player.pvars.forcedstate == S_PEPPINO_LONGJUMP or player.pvars.forcedstate == S_PEPPINO_SLOPEJUMP))
				player.pvars.forcedstate = S_PEPPINO_MACH2
			end
		elseif (player.pvars.forcedstate
		and player.pvars.forcedstate ~= S_PEPPINO_WALLJUMP
		and player.pvars.forcedstate ~= S_PEPPINO_BREAKDANCELAUNCH
		and player.pvars.forcedstate ~= S_PEPPINO_LONGJUMP
		and player.pvars.forcedstate ~= S_NOISE_SPIN -- for noisey
		and player.pvars.forcedstate ~= S_PEPPINO_SLOPEJUMP) then
			player.pvars.forcedstate = nil
			player.mo.state = S_PEPPINO_SECONDJUMP
		end
		
		/*if player.pvars.forcedstate == S_NOISE_SPIN then
			print "yea is spinning time"
		end*/
		
		if player.mo.flags2 & MF2_TWOD and not P_IsObjectOnGround(player.mo) then
			player.pflags = $|PF_STASIS
		end
		
		player.pvars.drawangle = player.drawangle
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		
		if player.pvars.breakdance and P_IsObjectOnGround(player.mo) then player.pvars.breakdance = nil end
		
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
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		P_InstaThrust(player.mo, player.pvars.thrustangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
		
		if (not (PT_FindPressed(player, "run", player.cmd.buttons)) and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.SKID)
			return
		end
		
		if PT_FindPressed(player, "down", player.cmd.buttons) and not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
		end
		
		if player.mo.skin == "nthe_noise" then
			if (P_IsObjectOnGround(player.mo) and not (player.gotflag) or
			not P_IsObjectOnGround(player.mo))
			and (PT_FindPressed(player, "up", player.cmd.buttons))
			and ((player.cmd.buttons & BT_JUMP) and not (player.prevkeys & BT_JUMP)) then
				if (P_IsObjectOnGround(player.mo)
				or player.ntoppv2_midairsj) then
					fsm.ChangeState(player, ntopp_v2.enums.SUPERJUMPSTART)
					return
				elseif player.pvars.cancrusher then
					fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
					L_ZLaunch(player.mo, 40*FU)
					player.pvars.savedmomz = player.mo.momz
					player.pvars.forcedstate = S_NOISE_CRUSHER
					return
				end
			end
		end
		
		if not (player.gotflag) and ((PT_FindPressed(player, "atk", player.cmd.buttons) and not (player.prevkeys and PT_FindPressed(player, "atk", player.prevkeys)))) then
			if (PT_FindPressed(player, "up", player.cmd.buttons)) then
				fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
				return
			end
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		if (PT_FindPressed(player, "down", player.cmd.buttons) and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.ROLL)
		end
		
		if P_IsObjectOnGround(player.mo) and (player.pvars.movespeed >= ntopp_v2.machs[3]) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH3)
			ntopp_v2.WhiteFlash(player)
		end
		
		if NerfAbility() then return end
		if player.pvars.breakdance then return end
		
		if player.pvars.supertauntready and PT_FindPressed(player, "up", player.cmd.buttons)
		and (PT_FindPressed(player, "taunt", player.cmd.buttons)) and not (player.prevkeys and PT_FindPressed(player, "taunt", player.prevkeys)) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
		
		if (PT_FindPressed(player, "taunt", player.cmd.buttons))
		and not (player.prevkeys and PT_FindPressed(player, "taunt", player.prevkeys)) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
	end,
	think = function(self, p)
		p.ntoppv2_machtime = $+1
	end,
	exit = function(self, player, state)
		player.runspeed = skins[player.mo.skin].runspeed
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
	end
}