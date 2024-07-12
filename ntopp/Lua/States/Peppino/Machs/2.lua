local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

local accel = FixedMul(L_PTDecimalFixed("0.1"), FixedDiv(60*FU, 35*FU))

fsmstates[ntopp_v2.enums.MACH2]['npeppino'] = {
	name = "Mach 2",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_MACH2
		player.pvars.breakdance = false
		player.pvars.drawangle = player.drawangle
		player.pvars.thrustangle = player.drawangle
		player.charflags = $|SF_RUNONWATER
		player.runspeed = ntopp_v2.machs[3] -- yay
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
		
		if player.mo.skin == "nthe_noise" and player.cmd.buttons & BT_CUSTOM3 then
			player.pflags = $|PF_JUMPSTASIS
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
		
		if (not (player.cmd.buttons & BT_SPIN) and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.SKID)
			return
		end
		
		if (player.cmd.buttons & BT_CUSTOM2) and not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
		end
		
		if player.mo.skin == "nthe_noise" then
			if (P_IsObjectOnGround(player.mo) and not (player.gotflag) or
			not P_IsObjectOnGround(player.mo))
			and (player.cmd.buttons & BT_CUSTOM3)
			and ((player.cmd.buttons & BT_JUMP) and not (player.pvars.prevkeys & BT_JUMP)) then
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
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1))) then
			if (player.cmd.buttons & BT_CUSTOM3) then
				fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
				return
			end
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		if (player.cmd.buttons & BT_CUSTOM2 and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.ROLL)
		end
		
		if P_IsObjectOnGround(player.mo) and (player.pvars.movespeed >= ntopp_v2.machs[3]) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH3)
			ntopp_v2.WhiteFlash(player)
		end
		
		if NerfAbility() then return end
		if player.pvars.breakdance then return end
		
		if player.pvars.supertauntready and player.cmd.buttons & BT_CUSTOM3 and (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
		
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
	end,
	think = function(self, p)
		local thrust,angle,slang = PT_ButteredSlope(p.mo)
		local pang = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy)
		if (P_IsObjectOnGround(p.mo)) then
			local add = p.powers[pw_sneakers] and FU or 0
			add = $ + (angle ~= nil and pang >= slang-32*ANG1 and pang <= slang+32*ANG1 and FU or 0)
			p.pvars.movespeed = $+accel+add
			if (not p.pvars.forcedstate or (p.pvars.forcedstate == S_PEPPINO_WALLJUMP or p.pvars.forcedstate == S_PEPPINO_BREAKDANCELAUNCH or p.pvars.forcedstate == S_PEPPINO_LONGJUMP or p.pvars.forcedstate == S_PEPPINO_SLOPEJUMP))
				p.pvars.forcedstate = S_PEPPINO_MACH2
			end
		elseif (p.pvars.forcedstate
		and p.pvars.forcedstate ~= S_PEPPINO_WALLJUMP
		and p.pvars.forcedstate ~= S_PEPPINO_BREAKDANCELAUNCH
		and p.pvars.forcedstate ~= S_PEPPINO_LONGJUMP
		and p.pvars.forcedstate ~= S_NOISE_SPIN -- for noisey
		and p.pvars.forcedstate ~= S_PEPPINO_SLOPEJUMP) then
			p.pvars.forcedstate = nil
			p.mo.state = S_PEPPINO_SECONDJUMP
		end
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