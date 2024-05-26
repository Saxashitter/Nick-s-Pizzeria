local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.MACH1]['npeppino'] = {
	name = "Mach 1",
	enter = function(self, player, state)
		player.pvars.movespeed = max(ntopp_v2.machs[1], $)
		if state == ntopp_v2.enums.BASE and player.speed > player.normalspeed then
			player.pvars.movespeed = ntopp_v2.machs[1]
		end
		player.pvars.forcedstate = S_PEPPINO_MACH1
		player.ntoppv2_machtime = 0
	end,
	playerthink = function(self, player)
		if not (player.mo)
		or (player.pflags & PF_SLIDING) then return end
		if not (player.pvars or player.playerstate == PST_DEAD) then
			player.pvars = Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		if player.mo.skin == "nthe_noise" and player.cmd.buttons & BT_CUSTOM3 then
			player.pflags = $|PF_JUMPSTASIS
		end
		
		local thrust,angle = PT_ButteredSlope(player.mo)
		
		if (P_IsObjectOnGround(player.mo)) then
			local add = player.powers[pw_sneakers] and FU or 0
			add = $ + (angle ~= nil and angle > 0 and angle <= 32*ANG1 and FU or 0)
			player.pvars.movespeed = $+(FU/3)+add
			if (not player.pvars.forcedstate)
				player.pvars.forcedstate = S_PEPPINO_MACH1
			end
		elseif (player.pvars.forcedstate)
			player.pvars.forcedstate = nil
			player.mo.state = S_PEPPINO_SECONDJUMP
		end
		
		if player.mo.flags2 & MF2_TWOD and not P_IsObjectOnGround(player.mo) then
			player.pflags = $|PF_STASIS
		end
		
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		P_InstaThrust(player.mo, player.drawangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
		
		if (not (player.cmd.buttons & BT_SPIN) and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
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
		
		if (player.pvars.movespeed >= ntopp_v2.machs[2]) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
		end
		
		if NerfAbility() then return end
		
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
		p.ntoppv2_machtime = $+1
	end,
	exit = function(self, player, state)
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
	end
}